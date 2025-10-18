import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { PoolWithExecute } from '../config/database';
import { User, EmailVerificationToken, PasswordResetToken, RefreshToken, LoginHistory, SecuritySettings } from '../types/database.types';
import { createError } from '../utils/error';
import db from '../config/database';

/**
 * JWT Payload interface for token claims
 */
interface JWTPayload {
    id: number;
    email: string;
    name: string;
    is_premium: boolean;
    iat?: number;
    exp?: number;
}

/**
 * Registration payload
 */
interface RegisterPayload {
    email: string;
    password: string;
    name: string;
}

/**
 * Login payload
 */
interface LoginPayload {
    email: string;
    password: string;
    ipAddress?: string;
    userAgent?: string;
}

/**
 * Login response
 */
interface LoginResponse {
    user: {
        id: number;
        email: string;
        name: string;
        profile_pic_url?: string;
        is_premium: boolean;
        is_email_verified: boolean;
    };
    accessToken: string;
    refreshToken: string;
}

/**
 * Auth Service - Handles authentication, JWT tokens, passwords, and security
 * Converts JavaScript auth logic to TypeScript with proper types and security
 */
class AuthService {
    private db: PoolWithExecute = db;
    private readonly JWT_SECRET: string;
    private readonly JWT_EXPIRES_IN: string = '15m';
    private readonly REFRESH_TOKEN_EXPIRES_IN: string = '7d';
    private readonly SALT_ROUNDS: number = 10;
    private readonly MAX_FAILED_ATTEMPTS: number = 5;
    private readonly ACCOUNT_LOCK_DURATION_MINUTES: number = 30;

    constructor() {
        this.JWT_SECRET = process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production';
    }

    /**
     * Register new user with validation
     */
    async register(payload: RegisterPayload): Promise<{ id: number; email: string; name: string; message: string }> {
        try {
            const { email, password, name } = payload;

            // Validate input
            if (!email || !password || !name) {
                throw createError('Email, password, and name are required', 400);
            }

            // Validate email format
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                throw createError('Invalid email format', 400);
            }

            // Validate password strength
            if (password.length < 8) {
                throw createError('Password must be at least 8 characters', 400);
            }

            // Check if email already exists
            const [existing]: any = await this.db.execute(
                'SELECT id FROM users WHERE email = $1',
                [email]
            );

            if (existing.length > 0) {
                throw createError('Email already registered', 409);
            }

            // Hash password
            const password_hash = await bcrypt.hash(password, this.SALT_ROUNDS);

            // Create user
            const [result]: any = await this.db.execute(
                `INSERT INTO users (email, password_hash, name, status, created_at, updated_at)
         VALUES ($1, $2, $3, $4, NOW(), NOW())
         RETURNING id`,
                [email, password_hash, name, 'ACTIVE']
            );

            const userId = result[0].id;

            // Create security settings
            await this.db.execute(
                'INSERT INTO security_settings (user_id, created_at, updated_at) VALUES ($1, NOW(), NOW())',
                [userId]
            );

            // Generate email verification token
            const verificationToken = await this.generateEmailVerificationToken(userId);

            // TODO: Send verification email
            console.log(`Verification token for ${email}: ${verificationToken}`);

            return {
                id: userId,
                email,
                name,
                message: 'User registered successfully. Please verify your email.'
            };
        } catch (error) {
            console.error('Registration error:', error);
            throw error;
        }
    }

    /**
     * Login user with security checks
     */
    async login(payload: LoginPayload): Promise<LoginResponse> {
        try {
            const { email, password, ipAddress = 'unknown', userAgent = 'unknown' } = payload;

            // Get user by email with security settings
            const [users]: any = await this.db.execute(
                `SELECT u.*, ss.failed_login_attempts, ss.account_locked_until
         FROM users u
         LEFT JOIN security_settings ss ON u.id = ss.user_id
         WHERE u.email = $1`,
                [email]
            );

            const user = users[0];

            // Check if account is locked
            if (user && user.account_locked_until) {
                const now = new Date();
                const lockUntil = new Date(user.account_locked_until);

                if (now < lockUntil) {
                    const remainingMinutes = Math.ceil((lockUntil.getTime() - now.getTime()) / 60000);
                    throw createError(
                        `Account is locked. Try again in ${remainingMinutes} minutes.`,
                        423
                    );
                } else {
                    // Unlock account
                    await this.unlockAccount(user.id);
                }
            }

            // Verify user exists
            if (!user) {
                await this.recordLoginAttempt(null, ipAddress, userAgent, 'FAILED', 'User not found');
                throw createError('Invalid email or password', 401);
            }

            // Check if account is active
            if (user.status !== 'ACTIVE') {
                await this.recordLoginAttempt(user.id, ipAddress, userAgent, 'FAILED', 'Account not active');
                throw createError('Account is not active', 403);
            }

            // Verify password
            const isPasswordValid = await bcrypt.compare(password, user.password_hash);

            if (!isPasswordValid) {
                await this.handleFailedLogin(user.id, ipAddress, userAgent);
                throw createError('Invalid email or password', 401);
            }

            // Reset failed login attempts
            await this.resetFailedLoginAttempts(user.id);

            // Update last login
            await this.db.execute(
                'UPDATE users SET last_login = NOW(), updated_at = NOW() WHERE id = $1',
                [user.id]
            );

            // Record successful login
            await this.recordLoginAttempt(user.id, ipAddress, userAgent, 'SUCCESS', null);

            // Generate tokens
            const accessToken = this.generateAccessToken(user);
            const refreshToken = await this.generateRefreshToken(user.id, ipAddress, userAgent);

            return {
                user: {
                    id: user.id,
                    email: user.email,
                    name: user.name,
                    profile_pic_url: user.profile_pic_url,
                    is_premium: user.is_premium || false,
                    is_email_verified: user.is_email_verified || false
                },
                accessToken,
                refreshToken
            };
        } catch (error) {
            console.error('Login error:', error);
            throw error;
        }
    }

    /**
     * Refresh access token using refresh token
     */
    async refreshAccessToken(refreshToken: string): Promise<{ accessToken: string }> {
        try {
            // Verify refresh token exists and is valid
            const [tokens]: any = await this.db.execute(
                `SELECT rt.*, u.email, u.name, u.is_premium, u.status
         FROM refresh_tokens rt
         JOIN users u ON rt.user_id = u.id
         WHERE rt.token = $1 AND rt.is_revoked = false`,
                [refreshToken]
            );

            if (tokens.length === 0) {
                throw createError('Invalid refresh token', 401);
            }

            const tokenData = tokens[0];

            // Check if token is expired
            if (new Date(tokenData.expires_at) < new Date()) {
                throw createError('Refresh token expired', 401);
            }

            // Check if user account is active
            if (tokenData.status !== 'ACTIVE') {
                throw createError('Account is not active', 403);
            }

            // Generate new access token
            const user = {
                id: tokenData.user_id,
                email: tokenData.email,
                name: tokenData.name,
                is_premium: tokenData.is_premium
            };

            const accessToken = this.generateAccessToken(user);

            return { accessToken };
        } catch (error) {
            console.error('Refresh token error:', error);
            throw error;
        }
    }

    /**
     * Logout user by revoking refresh token
     */
    async logout(refreshToken: string): Promise<{ message: string }> {
        try {
            if (!refreshToken) {
                return { message: 'Logged out successfully' };
            }

            // Revoke refresh token
            await this.db.execute(
                'UPDATE refresh_tokens SET is_revoked = true WHERE token = $1',
                [refreshToken]
            );

            return { message: 'Logged out successfully' };
        } catch (error) {
            console.error('Logout error:', error);
            throw error;
        }
    }

    /**
     * Change password for authenticated user
     */
    async changePassword(userId: number, currentPassword: string, newPassword: string): Promise<{ message: string }> {
        try {
            // Validate new password
            if (newPassword.length < 8) {
                throw createError('New password must be at least 8 characters', 400);
            }

            // Get current password hash
            const [users]: any = await this.db.execute(
                'SELECT password_hash FROM users WHERE id = $1',
                [userId]
            );

            if (users.length === 0) {
                throw createError('User not found', 404);
            }

            // Verify current password
            const isPasswordValid = await bcrypt.compare(currentPassword, users[0].password_hash);

            if (!isPasswordValid) {
                throw createError('Current password is incorrect', 401);
            }

            // Hash new password
            const newPasswordHash = await bcrypt.hash(newPassword, this.SALT_ROUNDS);

            // Update password
            await this.db.execute(
                'UPDATE users SET password_hash = $1, updated_at = NOW() WHERE id = $2',
                [newPasswordHash, userId]
            );

            // Revoke all refresh tokens (force re-login on all devices)
            await this.db.execute(
                'UPDATE refresh_tokens SET is_revoked = true WHERE user_id = $1',
                [userId]
            );

            return { message: 'Password changed successfully' };
        } catch (error) {
            console.error('Change password error:', error);
            throw error;
        }
    }

    /**
     * Request password reset token
     */
    async requestPasswordReset(email: string): Promise<{ message: string }> {
        try {
            // Get user by email
            const [users]: any = await this.db.execute(
                'SELECT id FROM users WHERE email = $1',
                [email]
            );

            // Always return success to prevent email enumeration
            if (users.length === 0) {
                return { message: 'If the email exists, a reset link has been sent' };
            }

            const userId = users[0].id;

            // Generate reset token
            const resetToken = await this.generatePasswordResetToken(userId);

            // TODO: Send password reset email
            console.log(`Password reset token for ${email}: ${resetToken}`);

            return { message: 'If the email exists, a reset link has been sent' };
        } catch (error) {
            console.error('Password reset request error:', error);
            throw error;
        }
    }

    /**
     * Reset password using verification token
     */
    async resetPassword(token: string, newPassword: string): Promise<{ message: string }> {
        try {
            // Validate new password
            if (newPassword.length < 8) {
                throw createError('Password must be at least 8 characters', 400);
            }

            // Verify token
            const [tokens]: any = await this.db.execute(
                `SELECT user_id FROM password_reset_tokens
         WHERE token = $1 AND is_used = false AND expires_at > NOW()`,
                [token]
            );

            if (tokens.length === 0) {
                throw createError('Invalid or expired reset token', 400);
            }

            const userId = tokens[0].user_id;

            // Hash new password
            const passwordHash = await bcrypt.hash(newPassword, this.SALT_ROUNDS);

            // Update password
            await this.db.execute(
                'UPDATE users SET password_hash = $1, updated_at = NOW() WHERE id = $2',
                [passwordHash, userId]
            );

            // Mark token as used
            await this.db.execute(
                'UPDATE password_reset_tokens SET is_used = true WHERE token = $1',
                [token]
            );

            // Revoke all refresh tokens
            await this.db.execute(
                'UPDATE refresh_tokens SET is_revoked = true WHERE user_id = $1',
                [userId]
            );

            return { message: 'Password reset successfully' };
        } catch (error) {
            console.error('Password reset error:', error);
            throw error;
        }
    }

    /**
     * Verify email with token
     */
    async verifyEmail(token: string): Promise<{ message: string }> {
        try {
            const [tokens]: any = await this.db.execute(
                `SELECT user_id FROM email_verification_tokens
         WHERE token = $1 AND expires_at > NOW()`,
                [token]
            );

            if (tokens.length === 0) {
                throw createError('Invalid or expired verification token', 400);
            }

            const userId = tokens[0].user_id;

            // Update user as verified
            await this.db.execute(
                'UPDATE users SET is_email_verified = true, updated_at = NOW() WHERE id = $1',
                [userId]
            );

            // Delete verification token
            await this.db.execute(
                'DELETE FROM email_verification_tokens WHERE token = $1',
                [token]
            );

            return { message: 'Email verified successfully' };
        } catch (error) {
            console.error('Email verification error:', error);
            throw error;
        }
    }

    // ==================== HELPER METHODS ====================

    /**
     * Generate JWT access token with 15m expiration
     */
    generateAccessToken(user: { id: number; email: string; name: string; is_premium: boolean }): string {
        return (jwt.sign as any)(
            {
                id: user.id,
                email: user.email,
                name: user.name,
                is_premium: user.is_premium
            } as JWTPayload,
            this.JWT_SECRET,
            { expiresIn: this.JWT_EXPIRES_IN }
        );
    }

    /**
     * Generate refresh token with 7d expiration
     */
    async generateRefreshToken(userId: number, ipAddress: string, userAgent: string): Promise<string> {
        const token = crypto.randomBytes(64).toString('hex');
        const expiresAt = new Date();
        expiresAt.setDate(expiresAt.getDate() + 7); // 7 days

        await this.db.execute(
            `INSERT INTO refresh_tokens (user_id, token, expires_at, ip_address, device_info, created_at)
       VALUES ($1, $2, $3, $4, $5, NOW())`,
            [userId, token, expiresAt, ipAddress, userAgent]
        );

        return token;
    }

    /**
     * Generate email verification token with 24h expiration
     */
    async generateEmailVerificationToken(userId: number): Promise<string> {
        const token = crypto.randomBytes(32).toString('hex');
        const expiresAt = new Date();
        expiresAt.setHours(expiresAt.getHours() + 24); // 24 hours

        await this.db.execute(
            'INSERT INTO email_verification_tokens (user_id, token, expires_at, created_at) VALUES ($1, $2, $3, NOW())',
            [userId, token, expiresAt]
        );

        return token;
    }

    /**
     * Generate password reset token with 1h expiration
     */
    async generatePasswordResetToken(userId: number): Promise<string> {
        const token = crypto.randomBytes(32).toString('hex');
        const expiresAt = new Date();
        expiresAt.setHours(expiresAt.getHours() + 1); // 1 hour

        await this.db.execute(
            'INSERT INTO password_reset_tokens (user_id, token, expires_at, created_at) VALUES ($1, $2, $3, NOW())',
            [userId, token, expiresAt]
        );

        return token;
    }

    /**
     * Record login attempt in history
     */
    async recordLoginAttempt(
        userId: number | null,
        ipAddress: string,
        userAgent: string,
        status: 'SUCCESS' | 'FAILED',
        failureReason: string | null
    ): Promise<void> {
        await this.db.execute(
            `INSERT INTO login_history (user_id, ip_address, user_agent, login_status, failure_reason, created_at)
       VALUES ($1, $2, $3, $4, $5, NOW())`,
            [userId, ipAddress, userAgent, status, failureReason]
        );
    }

    /**
     * Handle failed login attempt with account locking
     */
    async handleFailedLogin(userId: number, ipAddress: string, userAgent: string): Promise<void> {
        // Record failed attempt
        await this.recordLoginAttempt(userId, ipAddress, userAgent, 'FAILED', 'Invalid password');

        // Increment failed login attempts
        await this.db.execute(
            `UPDATE security_settings
       SET failed_login_attempts = failed_login_attempts + 1,
           last_failed_login = NOW(),
           updated_at = NOW()
       WHERE user_id = $1`,
            [userId]
        );

        // Check if account should be locked
        const [settings]: any = await this.db.execute(
            'SELECT failed_login_attempts FROM security_settings WHERE user_id = $1',
            [userId]
        );

        if (settings[0].failed_login_attempts >= this.MAX_FAILED_ATTEMPTS) {
            // Lock account for specified duration
            const lockUntil = new Date();
            lockUntil.setMinutes(lockUntil.getMinutes() + this.ACCOUNT_LOCK_DURATION_MINUTES);

            await this.db.execute(
                'UPDATE security_settings SET account_locked_until = $1, updated_at = NOW() WHERE user_id = $2',
                [lockUntil, userId]
            );

            throw createError('Account locked due to multiple failed login attempts', 423);
        }
    }

    /**
     * Reset failed login attempts
     */
    async resetFailedLoginAttempts(userId: number): Promise<void> {
        await this.db.execute(
            `UPDATE security_settings
       SET failed_login_attempts = 0,
           account_locked_until = NULL,
           updated_at = NOW()
       WHERE user_id = $1`,
            [userId]
        );
    }

    /**
     * Unlock account manually
     */
    async unlockAccount(userId: number): Promise<void> {
        await this.db.execute(
            `UPDATE security_settings
       SET account_locked_until = NULL,
           failed_login_attempts = 0,
           updated_at = NOW()
       WHERE user_id = $1`,
            [userId]
        );
    }

    /**
     * Verify JWT access token validity
     */
    verifyAccessToken(token: string): JWTPayload {
        try {
            return jwt.verify(token, this.JWT_SECRET) as JWTPayload;
        } catch (error: any) {
            if (error.name === 'TokenExpiredError') {
                throw createError('Access token expired', 401);
            }
            throw createError('Invalid access token', 401);
        }
    }

    /**
     * Cleanup expired tokens (run via cron job)
     */
    async cleanupExpiredTokens(): Promise<void> {
        try {
            // Delete expired refresh tokens
            await this.db.execute('DELETE FROM refresh_tokens WHERE expires_at < NOW()');

            // Delete expired verification tokens
            await this.db.execute('DELETE FROM email_verification_tokens WHERE expires_at < NOW()');

            // Delete used or expired password reset tokens
            await this.db.execute(
                'DELETE FROM password_reset_tokens WHERE expires_at < NOW() OR is_used = true'
            );

            console.log('Expired tokens cleaned up successfully');
        } catch (error) {
            console.error('Token cleanup error:', error);
        }
    }
}

export default new AuthService();

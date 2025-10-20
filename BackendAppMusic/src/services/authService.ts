import * as bcrypt from 'bcrypt';
import * as jwt from 'jsonwebtoken';
import { Pool } from 'pg';
import { v4 as uuidv4 } from 'uu id';
import * as nodemailer from 'nodemailer';
import {
    Auth,
    ErrorCode,
    JWTPayload,
    DatabaseUser,
} from '../types/api.types';

interface AuthConfig {
    jwtSecret: string;
    jwtRefreshSecret: string;
    accessTokenExpiry: number; // in minutes
    refreshTokenExpiry: number; // in days
    emailFrom: string;
    emailService: any; // nodemailer transporter
}

export class AuthService {
    private pool: Pool;
    private config: AuthConfig;
    private readonly SALT_ROUNDS = 10;
    private readonly MAX_FAILED_ATTEMPTS = 5;
    private readonly LOCKOUT_DURATION = 30; // minutes

    constructor(pool: Pool, config: AuthConfig) {
        this.pool = pool;
        this.config = config;
    }

    /**
     * Register new user
     */
    async register(payload: Auth.RegisterRequest): Promise<Auth.AuthResponse> {
        // Validate email format
        if (!this.isValidEmail(payload.email)) {
            throw {
                code: ErrorCode.VALIDATION_ERROR,
                message: 'Invalid email format',
                statusCode: 400,
            };
        }

        // Validate password strength
        if (!this.isStrongPassword(payload.password)) {
            throw {
                code: ErrorCode.VALIDATION_ERROR,
                message:
                    'Password must be at least 8 characters with uppercase, lowercase, and numbers',
                statusCode: 400,
            };
        }

        // Check if email already exists
        const existingUser = await this.pool.query(
            'SELECT id FROM users WHERE LOWER(email) = LOWER($1)',
            [payload.email]
        );

        if (existingUser.rows.length > 0) {
            throw {
                code: ErrorCode.EMAIL_ALREADY_EXISTS,
                message: 'Email already registered',
                statusCode: 409,
            };
        }

        // Hash password
        const passwordHash = await bcrypt.hash(payload.password, this.SALT_ROUNDS);

        // Insert user
        const result = await this.pool.query(
            `INSERT INTO users (email, password_hash, name, is_email_verified)
       VALUES ($1, $2, $3, false)
       RETURNING id, email, name, is_premium`,
            [payload.email, passwordHash, payload.name]
        );

        const user = result.rows[0];

        // Create security settings record
        await this.pool.query(
            'INSERT INTO security_settings (user_id) VALUES ($1)',
            [user.id]
        );

        // Generate verification token
        const verificationToken = await this.generateEmailVerificationToken(user.id);

        // Send verification email (async)
        this.sendVerificationEmail(payload.email, payload.name, verificationToken).catch(
            (err) => console.error('Failed to send verification email:', err)
        );

        // Generate tokens
        const { accessToken, refreshToken } = await this.generateTokens(user);

        return {
            id: user.id,
            email: user.email,
            name: user.name,
            is_premium: user.is_premium,
            accessToken,
            refreshToken,
        };
    }

    /**
     * Login user
     */
    async login(
        payload: Auth.LoginRequest,
        ipAddress?: string,
        userAgent?: string
    ): Promise<Auth.AuthResponse> {
        // Find user
        const result = await this.pool.query(
            'SELECT * FROM users WHERE LOWER(email) = LOWER($1)',
            [payload.email]
        );

        const user = result.rows[0] as DatabaseUser;

        if (!user) {
            // Log failed login
            await this.logLoginAttempt({
                userId: null,
                ipAddress,
                userAgent,
                status: 'FAILED',
                reason: 'User not found',
            });

            throw {
                code: ErrorCode.INVALID_CREDENTIALS,
                message: 'Invalid email or password',
                statusCode: 401,
            };
        }

        // Check if account is locked
        const securitySettings = await this.pool.query(
            'SELECT * FROM security_settings WHERE user_id = $1',
            [user.id]
        );

        const security = securitySettings.rows[0];

        if (
            security.account_locked_until &&
            new Date(security.account_locked_until) > new Date()
        ) {
            throw {
                code: ErrorCode.ACCOUNT_LOCKED,
                message: 'Account locked due to too many failed login attempts',
                statusCode: 403,
            };
        }

        // Check email verification
        if (!user.is_email_verified) {
            throw {
                code: ErrorCode.EMAIL_NOT_VERIFIED,
                message: 'Please verify your email first',
                statusCode: 403,
            };
        }

        // Verify password
        const isPasswordValid = await bcrypt.compare(
            payload.password,
            user.password_hash
        );

        if (!isPasswordValid) {
            // Increment failed attempts
            const newFailedAttempts = (security.failed_login_attempts || 0) + 1;
            let lockoutTime = null;

            if (newFailedAttempts >= this.MAX_FAILED_ATTEMPTS) {
                lockoutTime = new Date(
                    Date.now() + this.LOCKOUT_DURATION * 60 * 1000
                );
            }

            await this.pool.query(
                `UPDATE security_settings
         SET failed_login_attempts = $1, last_failed_login = NOW(), account_locked_until = $2
         WHERE user_id = $3`,
                [newFailedAttempts, lockoutTime, user.id]
            );

            // Log failed login
            await this.logLoginAttempt({
                userId: user.id,
                ipAddress,
                userAgent,
                status: 'FAILED',
                reason: 'Invalid password',
            });

            throw {
                code: ErrorCode.INVALID_CREDENTIALS,
                message: 'Invalid email or password',
                statusCode: 401,
            };
        }

        // Reset failed attempts
        await this.pool.query(
            `UPDATE security_settings
       SET failed_login_attempts = 0, last_failed_login = NULL, account_locked_until = NULL
       WHERE user_id = $1`,
            [user.id]
        );

        // Update last login
        await this.pool.query(
            'UPDATE users SET last_login = NOW() WHERE id = $1',
            [user.id]
        );

        // Log successful login
        await this.logLoginAttempt({
            userId: user.id,
            ipAddress,
            userAgent,
            status: 'SUCCESS',
        });

        // Generate tokens
        const { accessToken, refreshToken } = await this.generateTokens(user);

        // Store refresh token
        await this.storeRefreshToken(user.id, refreshToken, ipAddress, userAgent);

        return {
            id: user.id,
            email: user.email,
            name: user.name,
            is_premium: user.is_premium,
            accessToken,
            refreshToken,
        };
    }

    /**
     * Refresh access token
     */
    async refreshToken(refreshToken: string): Promise<Auth.TokenRefreshResponse> {
        try {
            // Verify refresh token
            const decoded = jwt.verify(
                refreshToken,
                this.config.jwtRefreshSecret
            ) as JWTPayload;

            // Check if token is revoked
            const tokenResult = await this.pool.query(
                'SELECT * FROM refresh_tokens WHERE token = $1 AND user_id = $2',
                [refreshToken, decoded.id]
            );

            if (
                tokenResult.rows.length === 0 ||
                tokenResult.rows[0].is_revoked
            ) {
                throw {
                    code: ErrorCode.UNAUTHORIZED,
                    message: 'Invalid or revoked refresh token',
                    statusCode: 401,
                };
            }

            // Get user
            const userResult = await this.pool.query(
                'SELECT * FROM users WHERE id = $1',
                [decoded.id]
            );

            if (userResult.rows.length === 0) {
                throw {
                    code: ErrorCode.NOT_FOUND,
                    message: 'User not found',
                    statusCode: 404,
                };
            }

            const user = userResult.rows[0];

            // Generate new tokens
            const { accessToken, refreshToken: newRefreshToken } =
                await this.generateTokens(user);

            // Revoke old refresh token
            await this.pool.query(
                'UPDATE refresh_tokens SET is_revoked = true WHERE id = $1',
                [tokenResult.rows[0].id]
            );

            return {
                accessToken,
                refreshToken: newRefreshToken,
            };
        } catch (error) {
            throw {
                code: ErrorCode.UNAUTHORIZED,
                message: 'Invalid refresh token',
                statusCode: 401,
            };
        }
    }

    /**
     * Logout user
     */
    async logout(userId: number, refreshToken?: string): Promise<void> {
        if (refreshToken) {
            // Revoke refresh token
            await this.pool.query(
                'UPDATE refresh_tokens SET is_revoked = true WHERE token = $1 AND user_id = $2',
                [refreshToken, userId]
            );
        }
    }

    /**
     * Verify email
     */
    async verifyEmail(token: string): Promise<void> {
        const result = await this.pool.query(
            'SELECT * FROM email_verification_tokens WHERE token = $1',
            [token]
        );

        if (result.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'Invalid verification token',
                statusCode: 404,
            };
        }

        const record = result.rows[0];

        // Check expiry
        if (new Date(record.expires_at) < new Date()) {
            throw {
                code: ErrorCode.VALIDATION_ERROR,
                message: 'Verification token has expired',
                statusCode: 400,
            };
        }

        // Update user
        await this.pool.query(
            'UPDATE users SET is_email_verified = true WHERE id = $1',
            [record.user_id]
        );

        // Delete token
        await this.pool.query(
            'DELETE FROM email_verification_tokens WHERE id = $1',
            [record.id]
        );
    }

    /**
     * Request password reset
     */
    async requestPasswordReset(email: string): Promise<void> {
        const result = await this.pool.query(
            'SELECT id, name FROM users WHERE LOWER(email) = LOWER($1)',
            [email]
        );

        if (result.rows.length === 0) {
            // Don't reveal if email exists for security
            return;
        }

        const user = result.rows[0];

        // Generate reset token
        const resetToken = uuidv4();
        const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

        await this.pool.query(
            'INSERT INTO password_reset_tokens (user_id, token, expires_at) VALUES ($1, $2, $3)',
            [user.id, resetToken, expiresAt]
        );

        // Send email
        await this.sendPasswordResetEmail(email, user.name, resetToken);
    }

    /**
     * Reset password
     */
    async resetPassword(token: string, newPassword: string): Promise<void> {
        // Validate password strength
        if (!this.isStrongPassword(newPassword)) {
            throw {
                code: ErrorCode.VALIDATION_ERROR,
                message:
                    'Password must be at least 8 characters with uppercase, lowercase, and numbers',
                statusCode: 400,
            };
        }

        const result = await this.pool.query(
            'SELECT * FROM password_reset_tokens WHERE token = $1 AND is_used = false',
            [token]
        );

        if (result.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'Invalid or expired reset token',
                statusCode: 404,
            };
        }

        const record = result.rows[0];

        // Check expiry
        if (new Date(record.expires_at) < new Date()) {
            throw {
                code: ErrorCode.VALIDATION_ERROR,
                message: 'Reset token has expired',
                statusCode: 400,
            };
        }

        // Hash new password
        const passwordHash = await bcrypt.hash(newPassword, this.SALT_ROUNDS);

        // Update user password
        await this.pool.query(
            'UPDATE users SET password_hash = $1, updated_at = NOW() WHERE id = $2',
            [passwordHash, record.user_id]
        );

        // Mark token as used
        await this.pool.query(
            'UPDATE password_reset_tokens SET is_used = true WHERE id = $1',
            [record.id]
        );
    }

    /**
     * Change password (authenticated user)
     */
    async changePassword(
        userId: number,
        currentPassword: string,
        newPassword: string
    ): Promise<void> {
        // Get user
        const result = await this.pool.query('SELECT * FROM users WHERE id = $1', [
            userId,
        ]);

        if (result.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'User not found',
                statusCode: 404,
            };
        }

        const user = result.rows[0];

        // Verify current password
        const isValid = await bcrypt.compare(currentPassword, user.password_hash);

        if (!isValid) {
            throw {
                code: ErrorCode.INVALID_CREDENTIALS,
                message: 'Current password is incorrect',
                statusCode: 401,
            };
        }

        // Validate new password
        if (!this.isStrongPassword(newPassword)) {
            throw {
                code: ErrorCode.VALIDATION_ERROR,
                message:
                    'New password must be at least 8 characters with uppercase, lowercase, and numbers',
                statusCode: 400,
            };
        }

        // Hash new password
        const passwordHash = await bcrypt.hash(newPassword, this.SALT_ROUNDS);

        // Update password
        await this.pool.query(
            'UPDATE users SET password_hash = $1, updated_at = NOW() WHERE id = $2',
            [passwordHash, userId]
        );
    }

    /**
     * Helper: Generate JWT tokens
     */
    private async generateTokens(user: DatabaseUser) {
        const payload: JWTPayload = {
            id: user.id,
            email: user.email,
            name: user.name,
            is_premium: user.is_premium,
        };

        const accessToken = jwt.sign(payload, this.config.jwtSecret, {
            expiresIn: `${this.config.accessTokenExpiry}m`,
        });

        const refreshToken = jwt.sign(payload, this.config.jwtRefreshSecret, {
            expiresIn: `${this.config.refreshTokenExpiry}d`,
        });

        return { accessToken, refreshToken };
    }

    /**
     * Helper: Store refresh token
     */
    private async storeRefreshToken(
        userId: number,
        token: string,
        ipAddress?: string,
        userAgent?: string
    ): Promise<void> {
        const expiresAt = new Date(
            Date.now() + this.config.refreshTokenExpiry * 24 * 60 * 60 * 1000
        );

        await this.pool.query(
            `INSERT INTO refresh_tokens (user_id, token, expires_at, device_info, ip_address)
       VALUES ($1, $2, $3, $4, $5)`,
            [userId, token, expiresAt, userAgent, ipAddress]
        );
    }

    /**
     * Helper: Generate email verification token
     */
    private async generateEmailVerificationToken(userId: number): Promise<string> {
        const token = uuidv4();
        const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

        await this.pool.query(
            'INSERT INTO email_verification_tokens (user_id, token, expires_at) VALUES ($1, $2, $3)',
            [userId, token, expiresAt]
        );

        return token;
    }

    /**
     * Helper: Log login attempt
     */
    private async logLoginAttempt(data: {
        userId: number | null;
        ipAddress?: string;
        userAgent?: string;
        status: 'SUCCESS' | 'FAILED';
        reason?: string;
    }): Promise<void> {
        await this.pool.query(
            `INSERT INTO login_history (user_id, ip_address, user_agent, login_status, failure_reason)
       VALUES ($1, $2, $3, $4, $5)`,
            [data.userId, data.ipAddress, data.userAgent, data.status, data.reason]
        );
    }

    /**
     * Helper: Validate email format
     */
    private isValidEmail(email: string): boolean {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    /**
     * Helper: Validate password strength
     */
    private isStrongPassword(password: string): boolean {
        const minLength = 8;
        const hasUppercase = /[A-Z]/.test(password);
        const hasLowercase = /[a-z]/.test(password);
        const hasNumber = /[0-9]/.test(password);

        return (
            password.length >= minLength &&
            hasUppercase &&
            hasLowercase &&
            hasNumber
        );
    }

    /**
     * Helper: Send verification email
     */
    private async sendVerificationEmail(
        email: string,
        name: string,
        token: string
    ): Promise<void> {
        const verificationUrl = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/verify-email?token=${token}`;

        const htmlContent = `
      <h2>Welcome to AppMusic, ${name}!</h2>
      <p>Please verify your email by clicking the link below:</p>
      <a href="${verificationUrl}">${verificationUrl}</a>
      <p>This link will expire in 24 hours.</p>
    `;

        await this.config.emailService.sendMail({
            from: this.config.emailFrom,
            to: email,
            subject: 'Verify your AppMusic email',
            html: htmlContent,
        });
    }

    /**
     * Helper: Send password reset email
     */
    private async sendPasswordResetEmail(
        email: string,
        name: string,
        token: string
    ): Promise<void> {
        const resetUrl = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/reset-password?token=${token}`;

        const htmlContent = `
      <h2>Password Reset Request</h2>
      <p>Hi ${name},</p>
      <p>We received a request to reset your password. Click the link below:</p>
      <a href="${resetUrl}">${resetUrl}</a>
      <p>This link will expire in 24 hours.</p>
      <p>If you didn't request this, ignore this email.</p>
    `;

        await this.config.emailService.sendMail({
            from: this.config.emailFrom,
            to: email,
            subject: 'Reset your AppMusic password',
            html: htmlContent,
        });
    }
}

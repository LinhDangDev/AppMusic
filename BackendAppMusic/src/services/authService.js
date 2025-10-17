import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import db from '../model/db.js';
import { createError } from '../utils/error.js';

class AuthService {
  constructor() {
    this.JWT_SECRET = process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production';
    this.JWT_EXPIRES_IN = '15m'; // Access token expires in 15 minutes
    this.REFRESH_TOKEN_EXPIRES_IN = '7d'; // Refresh token expires in 7 days
    this.SALT_ROUNDS = 10;
  }

  /**
   * Đăng ký user mới
   */
  async register({ email, password, name }) {
    try {
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
      const [existing] = await db.execute(
        'SELECT id FROM Users WHERE email = ?',
        [email]
      );

      if (existing.length > 0) {
        throw createError('Email already registered', 409);
      }

      // Hash password
      const password_hash = await bcrypt.hash(password, this.SALT_ROUNDS);

      // Create user
      const [result] = await db.execute(
        `INSERT INTO Users (email, password_hash, name, status)
         VALUES (?, ?, ?, 'ACTIVE')`,
        [email, password_hash, name]
      );

      const userId = result.insertId;

      // Create security settings
      await db.execute(
        'INSERT INTO Security_Settings (user_id) VALUES (?)',
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
   * Login user
   */
  async login({ email, password, ipAddress, userAgent }) {
    try {
      // Get user by email
      const [users] = await db.execute(
        `SELECT u.*, ss.failed_login_attempts, ss.account_locked_until
         FROM Users u
         LEFT JOIN Security_Settings ss ON u.id = ss.user_id
         WHERE u.email = ?`,
        [email]
      );

      const user = users[0];

      // Check if account is locked
      if (user && user.account_locked_until) {
        const now = new Date();
        const lockUntil = new Date(user.account_locked_until);

        if (now < lockUntil) {
          const remainingMinutes = Math.ceil((lockUntil - now) / 60000);
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
      await db.execute(
        'UPDATE Users SET last_login = NOW() WHERE id = ?',
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
          is_premium: user.is_premium,
          is_email_verified: user.is_email_verified
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
   * Refresh access token
   */
  async refreshAccessToken(refreshToken) {
    try {
      // Verify refresh token exists and is valid
      const [tokens] = await db.execute(
        `SELECT rt.*, u.email, u.name, u.is_premium, u.status
         FROM Refresh_Tokens rt
         JOIN Users u ON rt.user_id = u.id
         WHERE rt.token = ? AND rt.is_revoked = 0`,
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
   * Logout user
   */
  async logout(refreshToken) {
    try {
      if (!refreshToken) {
        return { message: 'Logged out successfully' };
      }

      // Revoke refresh token
      await db.execute(
        'UPDATE Refresh_Tokens SET is_revoked = 1 WHERE token = ?',
        [refreshToken]
      );

      return { message: 'Logged out successfully' };
    } catch (error) {
      console.error('Logout error:', error);
      throw error;
    }
  }

  /**
   * Change password
   */
  async changePassword(userId, currentPassword, newPassword) {
    try {
      // Validate new password
      if (newPassword.length < 8) {
        throw createError('New password must be at least 8 characters', 400);
      }

      // Get current password hash
      const [users] = await db.execute(
        'SELECT password_hash FROM Users WHERE id = ?',
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
      await db.execute(
        'UPDATE Users SET password_hash = ? WHERE id = ?',
        [newPasswordHash, userId]
      );

      // Revoke all refresh tokens (force re-login on all devices)
      await db.execute(
        'UPDATE Refresh_Tokens SET is_revoked = 1 WHERE user_id = ?',
        [userId]
      );

      return { message: 'Password changed successfully' };
    } catch (error) {
      console.error('Change password error:', error);
      throw error;
    }
  }

  /**
   * Request password reset
   */
  async requestPasswordReset(email) {
    try {
      // Get user by email
      const [users] = await db.execute(
        'SELECT id, email, name FROM Users WHERE email = ?',
        [email]
      );

      // Always return success to prevent email enumeration
      if (users.length === 0) {
        return { message: 'If the email exists, a reset link has been sent' };
      }

      const user = users[0];

      // Generate reset token
      const resetToken = await this.generatePasswordResetToken(user.id);

      // TODO: Send password reset email
      console.log(`Password reset token for ${email}: ${resetToken}`);

      return { message: 'If the email exists, a reset link has been sent' };
    } catch (error) {
      console.error('Password reset request error:', error);
      throw error;
    }
  }

  /**
   * Reset password with token
   */
  async resetPassword(token, newPassword) {
    try {
      // Validate new password
      if (newPassword.length < 8) {
        throw createError('Password must be at least 8 characters', 400);
      }

      // Verify token
      const [tokens] = await db.execute(
        `SELECT user_id FROM Password_Reset_Tokens
         WHERE token = ? AND is_used = 0 AND expires_at > NOW()`,
        [token]
      );

      if (tokens.length === 0) {
        throw createError('Invalid or expired reset token', 400);
      }

      const userId = tokens[0].user_id;

      // Hash new password
      const passwordHash = await bcrypt.hash(newPassword, this.SALT_ROUNDS);

      // Update password
      await db.execute(
        'UPDATE Users SET password_hash = ? WHERE id = ?',
        [passwordHash, userId]
      );

      // Mark token as used
      await db.execute(
        'UPDATE Password_Reset_Tokens SET is_used = 1 WHERE token = ?',
        [token]
      );

      // Revoke all refresh tokens
      await db.execute(
        'UPDATE Refresh_Tokens SET is_revoked = 1 WHERE user_id = ?',
        [userId]
      );

      return { message: 'Password reset successfully' };
    } catch (error) {
      console.error('Password reset error:', error);
      throw error;
    }
  }

  /**
   * Verify email
   */
  async verifyEmail(token) {
    try {
      const [tokens] = await db.execute(
        `SELECT user_id FROM Email_Verification_Tokens
         WHERE token = ? AND expires_at > NOW()`,
        [token]
      );

      if (tokens.length === 0) {
        throw createError('Invalid or expired verification token', 400);
      }

      const userId = tokens[0].user_id;

      // Update user as verified
      await db.execute(
        'UPDATE Users SET is_email_verified = 1 WHERE id = ?',
        [userId]
      );

      // Delete verification token
      await db.execute(
        'DELETE FROM Email_Verification_Tokens WHERE token = ?',
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
   * Generate JWT access token
   */
  generateAccessToken(user) {
    return jwt.sign(
      {
        id: user.id,
        email: user.email,
        name: user.name,
        is_premium: user.is_premium
      },
      this.JWT_SECRET,
      { expiresIn: this.JWT_EXPIRES_IN }
    );
  }

  /**
   * Generate refresh token
   */
  async generateRefreshToken(userId, ipAddress, userAgent) {
    const token = crypto.randomBytes(64).toString('hex');
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7); // 7 days

    await db.execute(
      `INSERT INTO Refresh_Tokens (user_id, token, expires_at, ip_address, device_info)
       VALUES (?, ?, ?, ?, ?)`,
      [userId, token, expiresAt, ipAddress, userAgent]
    );

    return token;
  }

  /**
   * Generate email verification token
   */
  async generateEmailVerificationToken(userId) {
    const token = crypto.randomBytes(32).toString('hex');
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 24); // 24 hours

    await db.execute(
      'INSERT INTO Email_Verification_Tokens (user_id, token, expires_at) VALUES (?, ?, ?)',
      [userId, token, expiresAt]
    );

    return token;
  }

  /**
   * Generate password reset token
   */
  async generatePasswordResetToken(userId) {
    const token = crypto.randomBytes(32).toString('hex');
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 1); // 1 hour

    await db.execute(
      'INSERT INTO Password_Reset_Tokens (user_id, token, expires_at) VALUES (?, ?, ?)',
      [userId, token, expiresAt]
    );

    return token;
  }

  /**
   * Record login attempt
   */
  async recordLoginAttempt(userId, ipAddress, userAgent, status, failureReason) {
    await db.execute(
      `INSERT INTO Login_History (user_id, ip_address, user_agent, login_status, failure_reason)
       VALUES (?, ?, ?, ?, ?)`,
      [userId, ipAddress, userAgent, status, failureReason]
    );
  }

  /**
   * Handle failed login attempt
   */
  async handleFailedLogin(userId, ipAddress, userAgent) {
    // Record failed attempt
    await this.recordLoginAttempt(userId, ipAddress, userAgent, 'FAILED', 'Invalid password');

    // Increment failed login attempts
    const [result] = await db.execute(
      `UPDATE Security_Settings
       SET failed_login_attempts = failed_login_attempts + 1,
           last_failed_login = NOW()
       WHERE user_id = ?`,
      [userId]
    );

    // Check if account should be locked (5 failed attempts)
    const [settings] = await db.execute(
      'SELECT failed_login_attempts FROM Security_Settings WHERE user_id = ?',
      [userId]
    );

    if (settings[0].failed_login_attempts >= 5) {
      // Lock account for 30 minutes
      const lockUntil = new Date();
      lockUntil.setMinutes(lockUntil.getMinutes() + 30);

      await db.execute(
        'UPDATE Security_Settings SET account_locked_until = ? WHERE user_id = ?',
        [lockUntil, userId]
      );

      throw createError('Account locked due to multiple failed login attempts', 423);
    }
  }

  /**
   * Reset failed login attempts
   */
  async resetFailedLoginAttempts(userId) {
    await db.execute(
      `UPDATE Security_Settings
       SET failed_login_attempts = 0,
           account_locked_until = NULL
       WHERE user_id = ?`,
      [userId]
    );
  }

  /**
   * Unlock account
   */
  async unlockAccount(userId) {
    await db.execute(
      `UPDATE Security_Settings
       SET account_locked_until = NULL,
           failed_login_attempts = 0
       WHERE user_id = ?`,
      [userId]
    );
  }

  /**
   * Verify JWT token
   */
  verifyAccessToken(token) {
    try {
      return jwt.verify(token, this.JWT_SECRET);
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        throw createError('Access token expired', 401);
      }
      throw createError('Invalid access token', 401);
    }
  }

  /**
   * Clean up expired tokens (run periodically)
   */
  async cleanupExpiredTokens() {
    try {
      // Delete expired refresh tokens
      await db.execute('DELETE FROM Refresh_Tokens WHERE expires_at < NOW()');

      // Delete expired verification tokens
      await db.execute('DELETE FROM Email_Verification_Tokens WHERE expires_at < NOW()');

      // Delete used or expired password reset tokens
      await db.execute(
        'DELETE FROM Password_Reset_Tokens WHERE expires_at < NOW() OR is_used = 1'
      );

      console.log('Expired tokens cleaned up successfully');
    } catch (error) {
      console.error('Token cleanup error:', error);
    }
  }
}

export default new AuthService();


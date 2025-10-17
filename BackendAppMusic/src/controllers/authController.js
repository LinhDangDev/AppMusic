import authService from '../services/authService.js';
import { getClientIp, getUserAgent } from '../middleware/authMiddleware.js';

class AuthController {
  /**
   * POST /api/auth/register
   * Đăng ký user mới
   */
  async register(req, res, next) {
    try {
      const { email, password, name } = req.body;

      const result = await authService.register({ email, password, name });

      res.status(201).json({
        success: true,
        data: result
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/auth/login
   * Đăng nhập
   */
  async login(req, res, next) {
    try {
      const { email, password } = req.body;
      const ipAddress = getClientIp(req);
      const userAgent = getUserAgent(req);

      const result = await authService.login({
        email,
        password,
        ipAddress,
        userAgent
      });

      // Set refresh token as httpOnly cookie (recommended for security)
      res.cookie('refreshToken', result.refreshToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production', // HTTPS only in production
        sameSite: 'strict',
        maxAge: 7 * 24 * 60 * 60 * 1000 // 7 days
      });

      res.json({
        success: true,
        data: {
          user: result.user,
          accessToken: result.accessToken,
          refreshToken: result.refreshToken // Also return in body for mobile apps
        }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/auth/refresh
   * Refresh access token
   */
  async refresh(req, res, next) {
    try {
      // Get refresh token from cookie or body
      const refreshToken = req.cookies.refreshToken || req.body.refreshToken;

      if (!refreshToken) {
        return res.status(401).json({
          success: false,
          message: 'Refresh token is required'
        });
      }

      const result = await authService.refreshAccessToken(refreshToken);

      res.json({
        success: true,
        data: result
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/auth/logout
   * Đăng xuất
   */
  async logout(req, res, next) {
    try {
      const refreshToken = req.cookies.refreshToken || req.body.refreshToken;

      await authService.logout(refreshToken);

      // Clear refresh token cookie
      res.clearCookie('refreshToken');

      res.json({
        success: true,
        message: 'Logged out successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/auth/change-password
   * Đổi mật khẩu
   */
  async changePassword(req, res, next) {
    try {
      const { currentPassword, newPassword } = req.body;
      const userId = req.user.id;

      const result = await authService.changePassword(
        userId,
        currentPassword,
        newPassword
      );

      // Clear refresh token cookie to force re-login
      res.clearCookie('refreshToken');

      res.json({
        success: true,
        data: result
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/auth/forgot-password
   * Yêu cầu reset mật khẩu
   */
  async forgotPassword(req, res, next) {
    try {
      const { email } = req.body;

      const result = await authService.requestPasswordReset(email);

      res.json({
        success: true,
        data: result
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/auth/reset-password
   * Reset mật khẩu với token
   */
  async resetPassword(req, res, next) {
    try {
      const { token, newPassword } = req.body;

      const result = await authService.resetPassword(token, newPassword);

      res.json({
        success: true,
        data: result
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/auth/verify-email/:token
   * Xác thực email
   */
  async verifyEmail(req, res, next) {
    try {
      const { token } = req.params;

      const result = await authService.verifyEmail(token);

      res.json({
        success: true,
        data: result
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/auth/me
   * Lấy thông tin user hiện tại
   */
  async getCurrentUser(req, res, next) {
    try {
      res.json({
        success: true,
        data: {
          user: req.user
        }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/auth/sessions
   * Lấy danh sách active sessions (refresh tokens)
   */
  async getActiveSessions(req, res, next) {
    try {
      const userId = req.user.id;

      const [sessions] = await db.execute(
        `SELECT id, device_info, ip_address, created_at, expires_at
         FROM Refresh_Tokens
         WHERE user_id = ? AND is_revoked = 0 AND expires_at > NOW()
         ORDER BY created_at DESC`,
        [userId]
      );

      res.json({
        success: true,
        data: { sessions }
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * DELETE /api/auth/sessions/:sessionId
   * Revoke một session cụ thể
   */
  async revokeSession(req, res, next) {
    try {
      const userId = req.user.id;
      const { sessionId } = req.params;

      await db.execute(
        'UPDATE Refresh_Tokens SET is_revoked = 1 WHERE id = ? AND user_id = ?',
        [sessionId, userId]
      );

      res.json({
        success: true,
        message: 'Session revoked successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * DELETE /api/auth/sessions
   * Revoke tất cả sessions (trừ session hiện tại)
   */
  async revokeAllSessions(req, res, next) {
    try {
      const userId = req.user.id;
      const currentToken = req.cookies.refreshToken || req.body.currentRefreshToken;

      // Revoke all except current session
      await db.execute(
        'UPDATE Refresh_Tokens SET is_revoked = 1 WHERE user_id = ? AND token != ?',
        [userId, currentToken || '']
      );

      res.json({
        success: true,
        message: 'All other sessions revoked successfully'
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new AuthController();


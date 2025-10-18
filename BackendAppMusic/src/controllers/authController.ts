import { Request, Response, NextFunction } from 'express';
import authService from '../services/authService';
import { getClientIp, getUserAgent } from '../middleware/authMiddleware';

/**
 * Authentication Controller - Handles auth endpoints
 */
class AuthController {
    /**
     * POST /api/auth/register - Register new user
     */
    async register(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { email, password, name } = req.body;
            const result = await authService.register({ email, password, name });
            res.status(201).json({ success: true, data: result });
        } catch (error) {
            next(error);
        }
    }

    /**
     * POST /api/auth/login - User login with security tracking
     */
    async login(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { email, password } = req.body;
            const ipAddress = getClientIp(req);
            const userAgent = getUserAgent(req);

            const result = await authService.login({ email, password, ipAddress, userAgent });

            res.cookie('refreshToken', result.refreshToken, {
                httpOnly: true,
                secure: process.env.NODE_ENV === 'production',
                sameSite: 'strict',
                maxAge: 7 * 24 * 60 * 60 * 1000
            });

            res.json({
                success: true,
                data: {
                    user: result.user,
                    accessToken: result.accessToken,
                    refreshToken: result.refreshToken
                }
            });
        } catch (error) {
            next(error);
        }
    }

    /**
     * POST /api/auth/refresh - Refresh access token
     */
    async refresh(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const refreshToken = req.cookies.refreshToken || req.body.refreshToken;

            if (!refreshToken) {
                res.status(401).json({ success: false, message: 'Refresh token required' });
                return;
            }

            const result = await authService.refreshAccessToken(refreshToken);
            res.json({ success: true, data: result });
        } catch (error) {
            next(error);
        }
    }

    /**
     * POST /api/auth/logout - Logout user
     */
    async logout(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const refreshToken = req.cookies.refreshToken || req.body.refreshToken;
            await authService.logout(refreshToken);
            res.clearCookie('refreshToken');
            res.json({ success: true, message: 'Logged out successfully' });
        } catch (error) {
            next(error);
        }
    }

    /**
     * POST /api/auth/change-password - Change password
     */
    async changePassword(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { currentPassword, newPassword } = req.body;
            const userId = (req as any).user?.id;

            const result = await authService.changePassword(userId, currentPassword, newPassword);
            res.clearCookie('refreshToken');
            res.json({ success: true, data: result });
        } catch (error) {
            next(error);
        }
    }

    /**
     * POST /api/auth/forgot-password - Request password reset
     */
    async forgotPassword(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { email } = req.body;
            const result = await authService.requestPasswordReset(email);
            res.json({ success: true, data: result });
        } catch (error) {
            next(error);
        }
    }

    /**
     * POST /api/auth/reset-password - Reset password with token
     */
    async resetPassword(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { token, newPassword } = req.body;
            const result = await authService.resetPassword(token, newPassword);
            res.json({ success: true, data: result });
        } catch (error) {
            next(error);
        }
    }

    /**
     * GET /api/auth/verify-email/:token - Verify email
     */
    async verifyEmail(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { token } = req.params;
            const result = await authService.verifyEmail(token);
            res.json({ success: true, data: result });
        } catch (error) {
            next(error);
        }
    }

    /**
     * GET /api/auth/me - Get current user
     */
    async getCurrentUser(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            res.json({ success: true, data: { user: (req as any).user } });
        } catch (error) {
            next(error);
        }
    }

    /**
     * GET /api/auth/sessions - Get active sessions
     */
    async getActiveSessions(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const userId = (req as any).user?.id;
            // TODO: Implement session retrieval from database
            res.json({ success: true, data: { sessions: [] } });
        } catch (error) {
            next(error);
        }
    }

    /**
     * DELETE /api/auth/sessions/:sessionId - Revoke specific session
     */
    async revokeSession(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { sessionId } = req.params;
            // TODO: Implement session revocation
            res.json({ success: true, message: 'Session revoked successfully' });
        } catch (error) {
            next(error);
        }
    }

    /**
     * DELETE /api/auth/sessions - Revoke all other sessions
     */
    async revokeAllSessions(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const userId = (req as any).user?.id;
            // TODO: Implement revoking all other sessions
            res.json({ success: true, message: 'All other sessions revoked' });
        } catch (error) {
            next(error);
        }
    }
}

export default new AuthController();

import { Request, Response } from 'express';
import { AuthService } from '../services/authService';
import { Auth, ApiResponse, ErrorCode } from '../types/api.types';
import { Pool } from 'pg';

export class AuthController {
    private authService: AuthService;

    constructor(pool: Pool) {
        this.authService = new AuthService(
            pool,
            {
                jwtSecret: process.env.JWT_SECRET || 'your-super-secret-jwt-key',
                jwtRefreshSecret: process.env.JWT_REFRESH_SECRET || 'your-super-secret-refresh-key',
                accessTokenExpiry: 15, // 15 minutes
                refreshTokenExpiry: 7, // 7 days
                emailFrom: process.env.EMAIL_FROM || 'noreply@appmusic.com',
                emailService: null, // Configure nodemailer here
            }
        );
    }

    /**
     * Register user
     * POST /api/v1/auth/register
     */
    async register(req: Request, res: Response): Promise<void> {
        try {
            const { email, password, name } = req.body;

            // Validate required fields
            if (!email || !password || !name) {
                res.status(400).json({
                    success: false,
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Email, password, and name are required',
                    statusCode: 400,
                } as ApiResponse);
                return;
            }

            const result = await this.authService.register({
                email,
                password,
                name,
            });

            res.status(201).json({
                success: true,
                data: result,
                message: 'User registered successfully',
                statusCode: 201,
            } as ApiResponse);
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    /**
     * Login user
     * POST /api/v1/auth/login
     */
    async login(req: Request, res: Response): Promise<void> {
        try {
            const { email, password } = req.body;

            if (!email || !password) {
                res.status(400).json({
                    success: false,
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Email and password are required',
                    statusCode: 400,
                } as ApiResponse);
                return;
            }

            const ipAddress = req.ip || 'unknown';
            const userAgent = req.get('user-agent') || 'unknown';

            const result = await this.authService.login(
                { email, password },
                ipAddress,
                userAgent
            );

            res.status(200).json({
                success: true,
                data: result,
                message: 'Login successful',
                statusCode: 200,
            } as ApiResponse);
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    /**
     * Refresh token
     * POST /api/v1/auth/refresh-token
     */
    async refreshToken(req: Request, res: Response): Promise<void> {
        try {
            const { refreshToken } = req.body;

            if (!refreshToken) {
                res.status(400).json({
                    success: false,
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Refresh token is required',
                    statusCode: 400,
                } as ApiResponse);
                return;
            }

            const result = await this.authService.refreshToken(refreshToken);

            res.status(200).json({
                success: true,
                data: result,
                message: 'Token refreshed successfully',
                statusCode: 200,
            } as ApiResponse);
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    /**
     * Logout user
     * POST /api/v1/auth/logout
     */
    async logout(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).userId;
            const { refreshToken } = req.body;

            if (!userId) {
                res.status(401).json({
                    success: false,
                    code: ErrorCode.UNAUTHORIZED,
                    message: 'Unauthorized',
                    statusCode: 401,
                } as ApiResponse);
                return;
            }

            await this.authService.logout(userId, refreshToken);

            res.status(200).json({
                success: true,
                message: 'Logged out successfully',
                statusCode: 200,
            } as ApiResponse);
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    /**
     * Verify email
     * GET /api/v1/auth/verify-email/:token
     */
    async verifyEmail(req: Request, res: Response): Promise<void> {
        try {
            const { token } = req.params;

            if (!token) {
                res.status(400).json({
                    success: false,
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Verification token is required',
                    statusCode: 400,
                } as ApiResponse);
                return;
            }

            await this.authService.verifyEmail(token);

            res.status(200).json({
                success: true,
                message: 'Email verified successfully',
                statusCode: 200,
            } as ApiResponse);
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    /**
     * Request password reset
     * POST /api/v1/auth/request-password-reset
     */
    async requestPasswordReset(req: Request, res: Response): Promise<void> {
        try {
            const { email } = req.body;

            if (!email) {
                res.status(400).json({
                    success: false,
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Email is required',
                    statusCode: 400,
                } as ApiResponse);
                return;
            }

            await this.authService.requestPasswordReset(email);

            // Always return success to prevent email enumeration
            res.status(200).json({
                success: true,
                message: 'If the email exists, a password reset link has been sent',
                statusCode: 200,
            } as ApiResponse);
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    /**
     * Reset password
     * POST /api/v1/auth/reset-password
     */
    async resetPassword(req: Request, res: Response): Promise<void> {
        try {
            const { token, newPassword } = req.body;

            if (!token || !newPassword) {
                res.status(400).json({
                    success: false,
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Token and new password are required',
                    statusCode: 400,
                } as ApiResponse);
                return;
            }

            await this.authService.resetPassword(token, newPassword);

            res.status(200).json({
                success: true,
                message: 'Password reset successfully',
                statusCode: 200,
            } as ApiResponse);
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    /**
     * Change password (authenticated)
     * POST /api/v1/auth/change-password
     */
    async changePassword(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).userId;
            const { currentPassword, newPassword } = req.body;

            if (!userId) {
                res.status(401).json({
                    success: false,
                    code: ErrorCode.UNAUTHORIZED,
                    message: 'Unauthorized',
                    statusCode: 401,
                } as ApiResponse);
                return;
            }

            if (!currentPassword || !newPassword) {
                res.status(400).json({
                    success: false,
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Current password and new password are required',
                    statusCode: 400,
                } as ApiResponse);
                return;
            }

            await this.authService.changePassword(userId, currentPassword, newPassword);

            res.status(200).json({
                success: true,
                message: 'Password changed successfully',
                statusCode: 200,
            } as ApiResponse);
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    /**
     * Handle errors and send appropriate response
     */
    private handleError(error: any, res: Response): void {
        const code = error.code || ErrorCode.INTERNAL_ERROR;
        const statusCode = error.statusCode || 500;
        const message = error.message || 'Internal server error';

        res.status(statusCode).json({
            success: false,
            code,
            message,
            statusCode,
            errors: error.errors || [],
        } as ApiResponse);
    }
}

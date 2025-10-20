import { Request, Response } from 'express';
import { UserService } from '../services/userService';
import { ApiResponse, ErrorCode } from '../types/api.types';
import { Pool } from 'pg';

export class UserController {
    private userService: UserService;

    constructor(pool: Pool) {
        this.userService = new UserService(pool);
    }

    /**
     * Get user profile
     * GET /api/v1/users/profile
     */
    async getProfile(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).userId;

            if (!userId) {
                res.status(401).json({
                    success: false,
                    code: ErrorCode.UNAUTHORIZED,
                    message: 'Unauthorized',
                    statusCode: 401,
                });
                return;
            }

            const profile = await this.userService.getProfile(userId);

            res.status(200).json({
                success: true,
                data: profile,
                message: 'Profile retrieved successfully',
                statusCode: 200,
            });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    /**
     * Update user profile
     * PUT /api/v1/users/profile
     */
    async updateProfile(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).userId;
            const { name, profilePicUrl, favoriteGenres, favoriteArtists } = req.body;

            if (!userId) {
                res.status(401).json({
                    success: false,
                    code: ErrorCode.UNAUTHORIZED,
                    message: 'Unauthorized',
                    statusCode: 401,
                });
                return;
            }

            const updatedProfile = await this.userService.updateProfile(userId, {
                name,
                profile_pic_url: profilePicUrl,
                favorite_genres: favoriteGenres,
                favorite_artists: favoriteArtists,
            });

            res.status(200).json({
                success: true,
                data: updatedProfile,
                message: 'Profile updated successfully',
                statusCode: 200,
            });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    /**
     * Get user preferences
     * GET /api/v1/users/preferences
     */
    async getPreferences(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).userId;

            if (!userId) {
                res.status(401).json({
                    success: false,
                    code: ErrorCode.UNAUTHORIZED,
                    message: 'Unauthorized',
                    statusCode: 401,
                });
                return;
            }

            const preferences = await this.userService.getPreferences(userId);

            res.status(200).json({
                success: true,
                data: preferences,
                message: 'Preferences retrieved successfully',
                statusCode: 200,
            });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    /**
     * Update user preferences
     * PUT /api/v1/users/preferences
     */
    async updatePreferences(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).userId;
            const { favoriteGenres, favoriteArtists } = req.body;

            if (!userId) {
                res.status(401).json({
                    success: false,
                    code: ErrorCode.UNAUTHORIZED,
                    message: 'Unauthorized',
                    statusCode: 401,
                });
                return;
            }

            const updatedPreferences = await this.userService.updatePreferences(userId, {
                favorite_genres: favoriteGenres,
                favorite_artists: favoriteArtists,
            });

            res.status(200).json({
                success: true,
                data: updatedPreferences,
                message: 'Preferences updated successfully',
                statusCode: 200,
            });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    /**
     * Get user statistics
     * GET /api/v1/users/stats
     */
    async getUserStats(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).userId;

            if (!userId) {
                res.status(401).json({
                    success: false,
                    code: ErrorCode.UNAUTHORIZED,
                    message: 'Unauthorized',
                    statusCode: 401,
                });
                return;
            }

            const stats = await this.userService.getUserStats(userId);

            res.status(200).json({
                success: true,
                data: stats,
                message: 'Statistics retrieved successfully',
                statusCode: 200,
            });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    /**
     * Deactivate user account
     * DELETE /api/v1/users/account
     */
    async deactivateAccount(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).userId;
            const { password } = req.body;

            if (!userId) {
                res.status(401).json({
                    success: false,
                    code: ErrorCode.UNAUTHORIZED,
                    message: 'Unauthorized',
                    statusCode: 401,
                });
                return;
            }

            if (!password) {
                res.status(400).json({
                    success: false,
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Password is required to deactivate account',
                    statusCode: 400,
                });
                return;
            }

            await this.userService.deactivateAccount(userId);

            res.status(200).json({
                success: true,
                message: 'Account deactivated successfully',
                statusCode: 200,
            });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    private handleError(error: any, res: Response): void {
        const code = error.code || ErrorCode.INTERNAL_ERROR;
        const statusCode = error.statusCode || 500;
        const message = error.message || 'Internal server error';

        res.status(statusCode).json({
            success: false,
            code,
            message,
            statusCode,
        });
    }
}

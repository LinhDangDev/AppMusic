import { Request, Response } from 'express';
import { FavoriteService } from '../services/favoriteService';
import { ApiResponse, ErrorCode } from '../types/api.types';
import { Pool } from 'pg';

export class FavoriteController {
    private favoriteService: FavoriteService;

    constructor(pool: Pool) {
        this.favoriteService = new FavoriteService(pool);
    }

    async getFavorites(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).userId;
            const page = parseInt(req.query.page as string) || 1;
            const limit = parseInt(req.query.limit as string) || 20;
            if (!userId) {
                res.status(401).json({ success: false, code: ErrorCode.UNAUTHORIZED, message: 'Unauthorized', statusCode: 401 });
                return;
            }
            const result = await this.favoriteService.getFavorites(userId, page, limit);
            res.status(200).json({ success: true, data: result.data, pagination: result.pagination, message: 'Favorites retrieved', statusCode: 200 });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    async addFavorite(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).userId;
            const { musicId } = req.body;
            if (!userId || !musicId) {
                res.status(400).json({ success: false, code: ErrorCode.VALIDATION_ERROR, message: 'User ID and music ID required', statusCode: 400 });
                return;
            }
            const result = await this.favoriteService.addFavorite(userId, musicId);
            res.status(201).json({ success: true, data: result, message: 'Song added to favorites', statusCode: 201 });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    async removeFavorite(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).userId;
            const musicId = parseInt(req.params.musicId);
            if (!userId) {
                res.status(401).json({ success: false, code: ErrorCode.UNAUTHORIZED, message: 'Unauthorized', statusCode: 401 });
                return;
            }
            await this.favoriteService.removeFavorite(userId, musicId);
            res.status(200).json({ success: true, message: 'Song removed from favorites', statusCode: 200 });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    private handleError(error: any, res: Response): void {
        const code = error.code || ErrorCode.INTERNAL_ERROR;
        const statusCode = error.statusCode || 500;
        res.status(statusCode).json({ success: false, code, message: error.message, statusCode });
    }
}

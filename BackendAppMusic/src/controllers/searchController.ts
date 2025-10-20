import { Request, Response } from 'express';
import { MusicService } from '../services/musicService';
import { ApiResponse, ErrorCode } from '../types/api.types';
import { Pool } from 'pg';

export class SearchController {
    private musicService: MusicService;

    constructor(pool: Pool) {
        this.musicService = new MusicService(pool);
    }

    async search(req: Request, res: Response): Promise<void> {
        try {
            const query = req.query.q as string;
            const limit = parseInt(req.query.limit as string) || 20;
            const type = (req.query.type as string) || 'all';

            if (!query) {
                res.status(400).json({
                    success: false,
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Search query is required',
                    statusCode: 400,
                });
                return;
            }

            const results = await this.musicService.searchMusic(query, limit, type as 'title' | 'artist' | 'album');

            res.status(200).json({
                success: true,
                data: results,
                message: 'Search completed successfully',
                statusCode: 200,
            });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    private handleError(error: any, res: Response): void {
        const code = error.code || ErrorCode.INTERNAL_ERROR;
        const statusCode = error.statusCode || 500;
        res.status(statusCode).json({
            success: false,
            code,
            message: error.message,
            statusCode,
        });
    }
}

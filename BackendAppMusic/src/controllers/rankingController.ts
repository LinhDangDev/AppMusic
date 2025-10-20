import { Request, Response } from 'express';
import { RankingService } from '../services/rankingService';
import { ApiResponse, ErrorCode } from '../types/api.types';
import { Pool } from 'pg';

export class RankingController {
    private rankingService: RankingService;

    constructor(pool: Pool) {
        this.rankingService = new RankingService(pool);
    }

    async getRankings(req: Request, res: Response): Promise<void> {
        try {
            const platform = req.query.platform as string;
            const region = req.query.region as string;
            const limit = parseInt(req.query.limit as string) || 50;

            const rankings = await this.rankingService.getRankings(platform, region, limit);
            res.status(200).json({ success: true, data: rankings, message: 'Rankings retrieved', statusCode: 200 });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    async getTrendingSongs(req: Request, res: Response): Promise<void> {
        try {
            const platform = req.query.platform as string;
            const limit = parseInt(req.query.limit as string) || 50;

            const trending = await this.rankingService.getTrendingSongs(platform, limit);
            res.status(200).json({ success: true, data: trending, message: 'Trending songs retrieved', statusCode: 200 });
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

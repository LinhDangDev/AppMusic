import { Request, Response, NextFunction } from 'express';
import rankingService from '../services/rankingService';

class RankingController {
    async getRankingsByPlatform(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const platform = req.query.platform as string;
            const limit = parseInt(req.query.limit as string) || 50;
            const rankings = await rankingService.getRankingsByPlatform(platform, limit);
            res.json({ success: true, data: rankings });
        } catch (error) {
            next(error);
        }
    }

    async getRankingsByRegion(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const region = req.query.region as string;
            const limit = parseInt(req.query.limit as string) || 50;
            const rankings = await rankingService.getRankingsByRegion(region, limit);
            res.json({ success: true, data: rankings });
        } catch (error) {
            next(error);
        }
    }

    async updateRanking(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { musicId, platform, position } = req.body;
            const ranking = await rankingService.updateRanking(musicId, platform, position);
            res.json({ success: true, data: ranking });
        } catch (error) {
            next(error);
        }
    }
}

export default new RankingController();

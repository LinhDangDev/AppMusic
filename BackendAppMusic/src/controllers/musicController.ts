import { Request, Response, NextFunction } from 'express';
import musicService from '../services/musicService';

class MusicController {
    async getAllMusic(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const limit = parseInt(req.query.limit as string) || 20;
            const offset = parseInt(req.query.offset as string) || 0;
            const sort = (req.query.sort as string) || 'newest';
            const result = await musicService.getAllMusic(limit, offset, sort);
            res.json({ success: true, data: result });
        } catch (error) {
            next(error);
        }
    }

    async getMusicById(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const musicId = parseInt(req.params.id);
            const music = await musicService.getMusicById(musicId);
            res.json({ success: true, data: music });
        } catch (error) {
            next(error);
        }
    }

    async searchMusic(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const query = req.query.q as string;
            const limit = parseInt(req.query.limit as string) || 20;
            const results = await musicService.searchAll(query, limit);
            res.json({ success: true, data: results });
        } catch (error) {
            next(error);
        }
    }

    async getMusicByArtist(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const artistId = parseInt(req.params.artistId);
            const limit = parseInt(req.query.limit as string) || 20;
            const music = await musicService.getMusicByArtist(artistId, limit);
            res.json({ success: true, data: music });
        } catch (error) {
            next(error);
        }
    }

    async getMusicByGenres(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const genreIds = (req.query.genres as string)?.split(',').map(Number) || [];
            const limit = parseInt(req.query.limit as string) || 20;
            const music = await musicService.getMusicByGenres(genreIds, limit);
            res.json({ success: true, data: music });
        } catch (error) {
            next(error);
        }
    }

    async getTopMusic(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const limit = parseInt(req.query.limit as string) || 10;
            const music = await musicService.getTopMusic(limit);
            res.json({ success: true, data: music });
        } catch (error) {
            next(error);
        }
    }

    async getRandomMusic(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const limit = parseInt(req.query.limit as string) || 10;
            const music = await musicService.getRandomMusic(limit);
            res.json({ success: true, data: music });
        } catch (error) {
            next(error);
        }
    }

    async updatePlayCount(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const musicId = parseInt(req.params.id);
            const increment = parseInt(req.body.increment) || 1;
            await musicService.updatePlayCount(musicId, increment);
            res.json({ success: true, message: 'Play count updated' });
        } catch (error) {
            next(error);
        }
    }
}

export default new MusicController();

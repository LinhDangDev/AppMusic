import { Request, Response, NextFunction } from 'express';
import artistService from '../services/artistService';

class ArtistController {
    async getArtistById(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const artistId = parseInt(req.params.id);
            const artist = await artistService.getArtistById(artistId);
            res.json({ success: true, data: artist });
        } catch (error) {
            next(error);
        }
    }

    async searchArtists(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const query = req.query.q as string;
            const limit = parseInt(req.query.limit as string) || 20;
            const artists = await artistService.searchArtists(query, limit);
            res.json({ success: true, data: artists });
        } catch (error) {
            next(error);
        }
    }

    async getTopArtists(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const limit = parseInt(req.query.limit as string) || 10;
            const artists = await artistService.getTopArtists(limit);
            res.json({ success: true, data: artists });
        } catch (error) {
            next(error);
        }
    }

    async getArtistWithStats(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const artistId = parseInt(req.params.id);
            const artist = await artistService.getArtistWithStats(artistId);
            res.json({ success: true, data: artist });
        } catch (error) {
            next(error);
        }
    }
}

export default new ArtistController();

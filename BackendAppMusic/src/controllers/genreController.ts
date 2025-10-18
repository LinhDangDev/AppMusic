import { Request, Response, NextFunction } from 'express';
import genreService from '../services/genreService';

class GenreController {
    async getAllGenres(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const limit = parseInt(req.query.limit as string) || 100;
            const genres = await genreService.getAllGenres(limit);
            res.json({ success: true, data: genres });
        } catch (error) {
            next(error);
        }
    }

    async getGenreById(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const genreId = parseInt(req.params.id);
            const genre = await genreService.getGenreById(genreId);
            res.json({ success: true, data: genre });
        } catch (error) {
            next(error);
        }
    }

    async searchGenres(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const query = req.query.q as string;
            const genres = await genreService.searchGenres(query);
            res.json({ success: true, data: genres });
        } catch (error) {
            next(error);
        }
    }
}

export default new GenreController();

import { Request, Response, NextFunction } from 'express';
import userService from '../services/userService';
import { createError } from '../utils/error';

class UserController {
    async getCurrentUser(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const userId = (req as any).user?.id || 1;
            const user = await userService.getUserById(userId);
            res.json({ success: true, data: user });
        } catch (error) {
            next(error);
        }
    }

    async updateUser(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { name, avatar, favorite_genres, favorite_artists } = req.body;
            const userId = (req as any).user?.id;
            const updated = await userService.updateUser(userId, {
                name,
                avatar,
                favorite_genres,
                favorite_artists
            });
            res.json({ success: true, data: updated });
        } catch (error) {
            next(error);
        }
    }

    async getPlayHistory(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const userId = (req as any).user?.id;
            const limit = parseInt(req.query.limit as string) || 50;
            const history = await userService.getPlayHistory(userId, limit);
            res.json({ success: true, data: history });
        } catch (error) {
            next(error);
        }
    }

    async getFavorites(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const userId = (req as any).user?.id || 1;
            const favorites = await userService.getFavorites(userId);
            res.json({ success: true, data: favorites });
        } catch (error) {
            next(error);
        }
    }

    async addToFavorites(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const userId = (req as any).user?.id || 1;
            const musicId = parseInt(req.params.musicId);
            await userService.addToFavorites(userId, musicId);
            res.json({ success: true, message: 'Added to favorites' });
        } catch (error) {
            next(error);
        }
    }

    async removeFromFavorites(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const userId = (req as any).user?.id || 1;
            const musicId = parseInt(req.params.musicId);
            await userService.removeFromFavorites(userId, musicId);
            res.json({ success: true, message: 'Removed from favorites' });
        } catch (error) {
            next(error);
        }
    }

    async getUserById(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const userId = parseInt(req.params.id);
            const user = await userService.getUserById(userId);
            if (!user) {
                throw createError('User not found', 404);
            }
            res.json({ success: true, data: user });
        } catch (error) {
            next(error);
        }
    }
}

export default new UserController();

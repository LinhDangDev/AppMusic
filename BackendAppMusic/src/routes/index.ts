import { Router } from 'express';
import { Pool } from 'pg';
import { authMiddleware } from '../middleware/authMiddleware';

// Import route factories
import createAuthRoutes from './authRoutes';
import createUserRoutes from './userRoutes';
import createMusicRoutes from './musicRoutes';
import createPlaylistRoutes from './playlistRoutes';
import createFavoriteRoutes from './favoriteRoutes';
import createRankingRoutes from './rankingRoutes';
import createSearchRoutes from './searchRoutes';

const createRoutes = (pool: Pool): Router => {
    const router = Router();

    // Public routes
    router.use('/auth', createAuthRoutes(pool));
    router.use('/music', createMusicRoutes(pool));
    router.use('/rankings', createRankingRoutes(pool));
    router.use('/search', createSearchRoutes(pool));

    // Protected routes (require authentication)
    router.use('/users', authMiddleware, createUserRoutes(pool));
    router.use('/playlists', authMiddleware, createPlaylistRoutes(pool));
    router.use('/favorites', authMiddleware, createFavoriteRoutes(pool));

    return router;
};

export default createRoutes;

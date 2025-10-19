import { Router, Request, Response } from 'express';
import authRoutes from './authRoutes';
import userRoutes from './userRoutes';
import musicRoutes from './musicRoutes';
import playlistRoutes from './playlistRoutes';
import artistRoutes from './artistRoutes';
import genreRoutes from './genreRoutes';
import rankingRoutes from './rankingRoutes';

const router = Router();

// Health check endpoint - accessible at /api/health
router.get('/health', (req: Request, res: Response) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        environment: process.env.NODE_ENV || 'development'
    });
});

// Mount all route modules
router.use('/api/auth', authRoutes);
router.use('/api/users', userRoutes);
router.use('/api/music', musicRoutes);
router.use('/api/playlists', playlistRoutes);
router.use('/api/artists', artistRoutes);
router.use('/api/genres', genreRoutes);
router.use('/api/rankings', rankingRoutes);

export default router;

import express from 'express';
import musicRoutes from './musicRoutes.js';
import artistRoutes from './artistRoutes.js';
import playlistRoutes from './playlistRoutes.js';
import userRoutes from './userRoutes.js';
import genreRoutes from './genreRoutes.js';

const router = express.Router();

// Mount các routes với prefix /api
router.use('/api/music', musicRoutes);
router.use('/api/artists', artistRoutes);
router.use('/api/playlists', playlistRoutes);
router.use('/api/users', userRoutes);
router.use('/api/genres', genreRoutes);

// Health check route
router.get('/api/health', (req, res) => {
  res.json({
    status: 'success',
    message: 'API is running'
  });
});

export default router; 
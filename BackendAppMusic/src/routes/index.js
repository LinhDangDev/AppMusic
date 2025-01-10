import express from 'express';
import musicRoutes from './musicRoutes.js';
import artistRoutes from './artistRoutes.js';
import playlistRoutes from './playlistRoutes.js';
import userRoutes from './userRoutes.js';
import genreRoutes from './genreRoutes.js';

const router = express.Router();

// Mount các routes
router.use('/music', musicRoutes);
router.use('/artists', artistRoutes);
router.use('/playlists', playlistRoutes);
router.use('/users', userRoutes);
router.use('/genres', genreRoutes);

// Health check route
router.get('/health', (req, res) => {
  res.json({
    status: 'success',
    message: 'API is running'
  });
});

export default router; 
import express from 'express';
import musicController from '../controllers/musicController.js';

const router = express.Router();

// Public routes
router.get('/', musicController.getAllMusic);
router.get('/search', musicController.searchMusic);
router.get('/youtube', musicController.searchYouTube);
router.get('/top', musicController.getTopMusic);
router.get('/:id', musicController.getMusicById);
router.get('/rankings/:region', musicController.getRankings);

export default router;
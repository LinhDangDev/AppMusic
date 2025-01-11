import express from 'express';
import musicController from '../controllers/musicController.js';

const router = express.Router();

router.get('/', musicController.getAllMusic);
router.get('/search', musicController.searchMusic);
router.get('/rankings/:region', musicController.getRankings);
router.get('/random', musicController.getRandomMusic);
router.get('/:id', musicController.getMusicById);

// Queue routes
router.post('/queue', musicController.addToQueue);
router.get('/queue', musicController.getQueue);
router.delete('/queue/:id', musicController.removeFromQueue);

export default router;
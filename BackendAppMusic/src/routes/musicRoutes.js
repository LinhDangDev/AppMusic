import express from 'express';
import musicController from '../controllers/musicController.js';

const router = express.Router();

router.get('/', musicController.getAllMusic);
router.get('/search', musicController.searchMusic);
router.get('/rankings/:region', musicController.getRankings);
router.get('/:id', musicController.getMusicById);

export default router;
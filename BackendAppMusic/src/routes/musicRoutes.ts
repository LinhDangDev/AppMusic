import { Router } from 'express';
import musicController from '../controllers/musicController';
import { optionalAuth } from '../middleware/authMiddleware';

const router = Router();

router.get('/', musicController.getAllMusic);
router.get('/search', musicController.searchMusic);
router.get('/top', musicController.getTopMusic);
router.get('/random', musicController.getRandomMusic);
router.get('/artist/:artistId', musicController.getMusicByArtist);
router.get('/genres', musicController.getMusicByGenres);
router.get('/:id', musicController.getMusicById);
router.post('/:id/play', optionalAuth, musicController.updatePlayCount);

export default router;

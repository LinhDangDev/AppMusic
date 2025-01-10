import express from 'express';
import auth from '../middleware/auth.js';
import artistController from '../controllers/artistController.js';

const router = express.Router();

router.get('/', auth, artistController.getAllArtists);
router.get('/:id', auth, artistController.getArtistById);
router.get('/:id/songs', auth, artistController.getArtistSongs);
router.get('/search', auth, artistController.searchArtists);

export default router;

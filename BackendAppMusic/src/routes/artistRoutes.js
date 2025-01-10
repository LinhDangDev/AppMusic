import express from 'express';
import artistController from '../controllers/artistController.js';

const router = express.Router();

router.get('/', artistController.getAllArtists);
router.get('/:id', artistController.getArtistById);
router.get('/:id/songs', artistController.getArtistSongs);

export default router;

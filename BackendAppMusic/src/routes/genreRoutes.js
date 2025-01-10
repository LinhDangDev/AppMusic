import express from 'express';
import genreController from '../controllers/genreController.js';

const router = express.Router();

router.get('/', genreController.getAllGenres);
router.get('/:id', genreController.getGenreById);
router.get('/:id/songs', genreController.getGenreSongs);

export default router;

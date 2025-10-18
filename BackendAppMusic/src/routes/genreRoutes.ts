import { Router } from 'express';
import genreController from '../controllers/genreController';

const router = Router();

router.get('/', genreController.getAllGenres);
router.get('/search', genreController.searchGenres);
router.get('/:id', genreController.getGenreById);

export default router;

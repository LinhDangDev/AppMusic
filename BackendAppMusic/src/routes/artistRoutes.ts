import { Router } from 'express';
import artistController from '../controllers/artistController';

const router = Router();

router.get('/', artistController.getTopArtists);
router.get('/search', artistController.searchArtists);
router.get('/:id', artistController.getArtistById);
router.get('/:id/stats', artistController.getArtistWithStats);

export default router;

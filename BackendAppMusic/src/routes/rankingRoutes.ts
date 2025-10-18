import { Router } from 'express';
import rankingController from '../controllers/rankingController';

const router = Router();

router.get('/platform', rankingController.getRankingsByPlatform);
router.get('/region', rankingController.getRankingsByRegion);
router.post('/', rankingController.updateRanking);

export default router;

import { Router } from 'express';
import { RankingController } from '../controllers/rankingController';
import { Pool } from 'pg';

const createRankingRoutes = (pool: Pool): Router => {
    const router = Router();
    const rankingController = new RankingController(pool);

    router.get('/', (req, res) => rankingController.getRankings(req, res));
    router.get('/trending', (req, res) => rankingController.getTrendingSongs(req, res));

    return router;
};

export default createRankingRoutes;

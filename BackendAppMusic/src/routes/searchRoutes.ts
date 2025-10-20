import { Router } from 'express';
import { SearchController } from '../controllers/searchController';
import { Pool } from 'pg';

const createSearchRoutes = (pool: Pool): Router => {
    const router = Router();
    const searchController = new SearchController(pool);

    router.get('/', (req, res) => searchController.search(req, res));

    return router;
};

export default createSearchRoutes;

import { Router } from 'express';
import { FavoriteController } from '../controllers/favoriteController';
import { Pool } from 'pg';

const createFavoriteRoutes = (pool: Pool): Router => {
    const router = Router();
    const favoriteController = new FavoriteController(pool);

    router.get('/', (req, res) => favoriteController.getFavorites(req, res));
    router.post('/', (req, res) => favoriteController.addFavorite(req, res));
    router.delete('/:musicId', (req, res) => favoriteController.removeFavorite(req, res));

    return router;
};

export default createFavoriteRoutes;

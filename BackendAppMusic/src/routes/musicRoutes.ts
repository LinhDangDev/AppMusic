import { Router } from 'express';
import { MusicController } from '../controllers/musicController';
import { Pool } from 'pg';

const createMusicRoutes = (pool: Pool): Router => {
    const router = Router();
    const musicController = new MusicController(pool);

    // Public routes
    router.get('/', (req, res) => musicController.getMusic(req, res));
    router.get('/search', (req, res) => musicController.searchMusic(req, res));
    router.get('/:id', (req, res) => musicController.getMusicById(req, res));

    // Admin routes (would need admin middleware in production)
    router.post('/', (req, res) => musicController.createMusic(req, res));
    router.put('/:id', (req, res) => musicController.updateMusic(req, res));
    router.delete('/:id', (req, res) => musicController.deleteMusic(req, res));

    return router;
};

export default createMusicRoutes;

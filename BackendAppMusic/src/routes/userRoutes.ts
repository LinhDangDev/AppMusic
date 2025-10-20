import { Router } from 'express';
import { UserController } from '../controllers/userController';
import { Pool } from 'pg';

const createUserRoutes = (pool: Pool): Router => {
    const router = Router();
    const userController = new UserController(pool);

    router.get('/profile', (req, res) => userController.getProfile(req, res));
    router.put('/profile', (req, res) => userController.updateProfile(req, res));
    router.get('/preferences', (req, res) => userController.getPreferences(req, res));
    router.put('/preferences', (req, res) => userController.updatePreferences(req, res));
    router.get('/stats', (req, res) => userController.getUserStats(req, res));
    router.delete('/account', (req, res) => userController.deactivateAccount(req, res));

    return router;
};

export default createUserRoutes;

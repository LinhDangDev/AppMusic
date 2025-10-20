import { Router } from 'express';
import { AuthController } from '../controllers/authController';
import { Pool } from 'pg';
import { authMiddleware } from '../middleware/authMiddleware';

const createAuthRoutes = (pool: Pool): Router => {
    const router = Router();
    const authController = new AuthController(pool);

    // Public routes
    router.post('/register', (req, res) => authController.register(req, res));
    router.post('/login', (req, res) => authController.login(req, res));
    router.post('/refresh-token', (req, res) => authController.refreshToken(req, res));
    router.get('/verify-email/:token', (req, res) => authController.verifyEmail(req, res));
    router.post('/request-password-reset', (req, res) => authController.requestPasswordReset(req, res));
    router.post('/reset-password', (req, res) => authController.resetPassword(req, res));

    // Protected routes
    router.post('/logout', authMiddleware, (req, res) => authController.logout(req, res));
    router.post('/change-password', authMiddleware, (req, res) => authController.changePassword(req, res));

    return router;
};

export default createAuthRoutes;

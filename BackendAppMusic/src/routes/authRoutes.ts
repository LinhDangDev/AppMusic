import { Router } from 'express';
import authController from '../controllers/authController';
import { authenticateToken } from '../middleware/authMiddleware';

const router = Router();

// ==================== PUBLIC ROUTES ====================

router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/refresh', authController.refresh);
router.post('/forgot-password', authController.forgotPassword);
router.post('/reset-password', authController.resetPassword);
router.get('/verify-email/:token', authController.verifyEmail);

// ==================== PROTECTED ROUTES ====================

router.post('/logout', authenticateToken, authController.logout);
router.post('/change-password', authenticateToken, authController.changePassword);
router.get('/me', authenticateToken, authController.getCurrentUser);
router.get('/sessions', authenticateToken, authController.getActiveSessions);
router.delete('/sessions/:sessionId', authenticateToken, authController.revokeSession);
router.delete('/sessions', authenticateToken, authController.revokeAllSessions);

export default router;

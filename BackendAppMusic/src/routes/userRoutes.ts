import { Router } from 'express';
import userController from '../controllers/userController';
import { authenticateToken } from '../middleware/authMiddleware';

const router = Router();

router.get('/me', authenticateToken, userController.getCurrentUser);
router.put('/me', authenticateToken, userController.updateUser);
router.get('/me/history', authenticateToken, userController.getPlayHistory);
router.get('/me/favorites', authenticateToken, userController.getFavorites);
router.post('/me/favorites/:musicId', authenticateToken, userController.addToFavorites);
router.delete('/me/favorites/:musicId', authenticateToken, userController.removeFromFavorites);
router.get('/:id', userController.getUserById);

export default router;

import express from 'express';
import auth from '../middleware/auth.js';
import userController from '../controllers/userController.js';

const router = express.Router();

router.get('/me', auth, userController.getCurrentUser);
router.get('/me/history', auth, userController.getPlayHistory);
router.get('/me/favorites', auth, userController.getFavorites);
router.post('/me/favorites/:musicId', auth, userController.addToFavorites);
router.delete('/me/favorites/:musicId', auth, userController.removeFromFavorites);

export default router;

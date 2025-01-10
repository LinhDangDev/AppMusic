import express from 'express';
import userController from '../controllers/userController.js';

const router = express.Router();

router.get('/me', userController.getCurrentUser);
router.get('/me/favorites', userController.getFavorites);
router.post('/me/favorites/:musicId', userController.addToFavorites);
router.delete('/me/favorites/:musicId', userController.removeFromFavorites);

export default router;

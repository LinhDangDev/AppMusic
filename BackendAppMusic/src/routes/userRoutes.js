import express from 'express';
import auth from '../middleware/auth.js';
import { apiLimiter } from '../middleware/rateLimiter.js';
import userController from '../controllers/userController.js';

const router = express.Router();

// Lấy thông tin user hiện tại
router.get('/me', auth, apiLimiter, userController.getCurrentUser);

// Cập nhật thông tin user
router.put('/me', auth, apiLimiter, userController.updateUser);

// Thay đổi mật khẩu
router.put('/me/password', auth, apiLimiter, userController.changePassword);

// Lấy lịch sử nghe nhạc
router.get('/me/history', auth, apiLimiter, userController.getPlayHistory);

// Lấy bài hát yêu thích
router.get('/me/favorites', auth, apiLimiter, userController.getFavorites);

// Thêm bài hát vào yêu thích
router.post('/me/favorites/:musicId', auth, apiLimiter, userController.addToFavorites);

// Xóa bài hát khỏi yêu thích
router.delete('/me/favorites/:musicId', auth, apiLimiter, userController.removeFromFavorites);

// Lấy thông tin user khác (nếu cần)
router.get('/:id', auth, apiLimiter, userController.getUserById);

export default router;

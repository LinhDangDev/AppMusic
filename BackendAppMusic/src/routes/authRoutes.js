import express from 'express';
import authController from '../controllers/authController.js';
import { apiLimiter } from '../middleware/rateLimiter.js';

const router = express.Router();

// Đăng ký
router.post('/register', apiLimiter, authController.register);

// Đăng nhập
router.post('/login', apiLimiter, authController.login);

// Đăng xuất
router.post('/logout', authController.logout);

// Refresh token
router.post('/refresh-token', authController.refreshToken);

// Xác thực token
router.post('/verify-token', authController.verifyToken);

// Quên mật khẩu
router.post('/forgot-password', apiLimiter, authController.forgotPassword);

// Đặt lại mật khẩu
router.post('/reset-password', apiLimiter, authController.resetPassword);

export default router;

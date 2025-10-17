import express from 'express';
import authController from '../controllers/authController.js';
import { authenticateToken } from '../middleware/authMiddleware.js';

const router = express.Router();

// ==================== PUBLIC ROUTES ====================

/**
 * @route   POST /api/auth/register
 * @desc    Đăng ký user mới
 * @access  Public
 */
router.post('/register', authController.register);

/**
 * @route   POST /api/auth/login
 * @desc    Đăng nhập
 * @access  Public
 */
router.post('/login', authController.login);

/**
 * @route   POST /api/auth/refresh
 * @desc    Refresh access token
 * @access  Public
 */
router.post('/refresh', authController.refresh);

/**
 * @route   POST /api/auth/forgot-password
 * @desc    Yêu cầu reset mật khẩu
 * @access  Public
 */
router.post('/forgot-password', authController.forgotPassword);

/**
 * @route   POST /api/auth/reset-password
 * @desc    Reset mật khẩu với token
 * @access  Public
 */
router.post('/reset-password', authController.resetPassword);

/**
 * @route   GET /api/auth/verify-email/:token
 * @desc    Xác thực email
 * @access  Public
 */
router.get('/verify-email/:token', authController.verifyEmail);

// ==================== PROTECTED ROUTES ====================

/**
 * @route   GET /api/auth/me
 * @desc    Lấy thông tin user hiện tại
 * @access  Private
 */
router.get('/me', authenticateToken, authController.getCurrentUser);

/**
 * @route   POST /api/auth/logout
 * @desc    Đăng xuất
 * @access  Private
 */
router.post('/logout', authenticateToken, authController.logout);

/**
 * @route   POST /api/auth/change-password
 * @desc    Đổi mật khẩu
 * @access  Private
 */
router.post('/change-password', authenticateToken, authController.changePassword);

/**
 * @route   GET /api/auth/sessions
 * @desc    Lấy danh sách active sessions
 * @access  Private
 */
router.get('/sessions', authenticateToken, authController.getActiveSessions);

/**
 * @route   DELETE /api/auth/sessions/:sessionId
 * @desc    Revoke một session cụ thể
 * @access  Private
 */
router.delete('/sessions/:sessionId', authenticateToken, authController.revokeSession);

/**
 * @route   DELETE /api/auth/sessions
 * @desc    Revoke tất cả sessions khác
 * @access  Private
 */
router.delete('/sessions', authenticateToken, authController.revokeAllSessions);

export default router;


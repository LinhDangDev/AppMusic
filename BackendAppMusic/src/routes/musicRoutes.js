import express from 'express';
import auth from '../middleware/auth.js';
import { apiLimiter } from '../middleware/rateLimiter.js';
import musicController from '../controllers/musicController.js';

const router = express.Router();

// Tìm kiếm bài hát
router.get('/search', auth, apiLimiter, musicController.searchMusic);

// Lấy thông tin bài hát theo ID
router.get('/:id', auth, apiLimiter, musicController.getMusicById);

// Lấy URL stream của bài hát
router.get('/:id/stream', auth, apiLimiter, musicController.getStreamUrl);

// Ghi nhận lượt nghe
router.post('/:id/play', auth, apiLimiter, musicController.recordPlay);

// Lấy top bài hát
router.get('/top/songs', auth, apiLimiter, musicController.getTopSongs);

export default router;

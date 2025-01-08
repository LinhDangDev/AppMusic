import express from 'express';
import auth from '../middleware/auth.js';
import { apiLimiter } from '../middleware/rateLimiter.js';
import playlistController from '../controllers/playlistController.js';

const router = express.Router();

// Lấy danh sách playlist của user
router.get('/', auth, apiLimiter, playlistController.getUserPlaylists);

// Tạo playlist mới
router.post('/', auth, apiLimiter, playlistController.createPlaylist);

// Lấy chi tiết playlist
router.get('/:id', auth, apiLimiter, playlistController.getPlaylistById);

// Cập nhật playlist
router.put('/:id', auth, apiLimiter, playlistController.updatePlaylist);

// Xóa playlist
router.delete('/:id', auth, apiLimiter, playlistController.deletePlaylist);

// Thêm bài hát vào playlist
router.post('/:id/songs', auth, apiLimiter, playlistController.addSongToPlaylist);

// Xóa bài hát khỏi playlist
router.delete('/:id/songs/:songId', auth, apiLimiter, playlistController.removeSongFromPlaylist);

// Lấy danh sách bài hát trong playlist
router.get('/:id/songs', auth, apiLimiter, playlistController.getPlaylistSongs);

export default router;

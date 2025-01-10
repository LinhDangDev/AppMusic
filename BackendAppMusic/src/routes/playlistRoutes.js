import express from 'express';
import playlistController from '../controllers/playlistController.js';

const router = express.Router();

// Bỏ auth middleware khỏi tất cả routes
router.get('/', playlistController.getUserPlaylists);
router.post('/', playlistController.createPlaylist);
router.get('/:id', playlistController.getPlaylistById);
router.put('/:id', playlistController.updatePlaylist);
router.delete('/:id', playlistController.deletePlaylist);
router.post('/:id/songs', playlistController.addSongToPlaylist);
router.delete('/:id/songs/:songId', playlistController.removeSongFromPlaylist);
router.get('/:id/songs', playlistController.getPlaylistSongs);

export default router;

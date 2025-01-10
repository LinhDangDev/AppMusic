import express from 'express';
import playlistController from '../controllers/playlistController.js';

const router = express.Router();

router.get('/', playlistController.getUserPlaylists);
router.post('/', playlistController.createPlaylist);
router.get('/:id', playlistController.getPlaylistById);
router.post('/:id/songs/:musicId', playlistController.addSongToPlaylist);
router.post('/:id/songs', playlistController.addSongToPlaylist);
router.get('/:id/songs', playlistController.getPlaylistSongs);
router.delete('/:id/songs/:songId', playlistController.removeSongFromPlaylist);

export default router;

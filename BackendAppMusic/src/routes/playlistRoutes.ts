import { Router } from 'express';
import playlistController from '../controllers/playlistController';
import { authenticateToken } from '../middleware/authMiddleware';

const router = Router();

router.get('/', authenticateToken, playlistController.getUserPlaylists);
router.post('/', authenticateToken, playlistController.createPlaylist);
router.get('/:id', playlistController.getPlaylistById);
router.get('/:id/songs', playlistController.getPlaylistSongs);
router.put('/:id', authenticateToken, playlistController.updatePlaylist);
router.delete('/:id', authenticateToken, playlistController.deletePlaylist);
router.post('/:id/songs', authenticateToken, playlistController.addSongToPlaylist);
router.delete('/:id/songs/:musicId', authenticateToken, playlistController.removeSongFromPlaylist);

export default router;

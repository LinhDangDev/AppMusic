import { Router } from 'express';
import { PlaylistController } from '../controllers/playlistController';
import { Pool } from 'pg';

const createPlaylistRoutes = (pool: Pool): Router => {
  const router = Router();
  const playlistController = new PlaylistController(pool);

  router.get('/', (req, res) => playlistController.getUserPlaylists(req, res));
  router.post('/', (req, res) => playlistController.createPlaylist(req, res));
  router.get('/:id', (req, res) => playlistController.getPlaylistById(req, res));
  router.put('/:id', (req, res) => playlistController.updatePlaylist(req, res));
  router.delete('/:id', (req, res) => playlistController.deletePlaylist(req, res));
  router.post('/:id/songs', (req, res) => playlistController.addSong(req, res));
  router.delete('/:id/songs/:musicId', (req, res) => playlistController.removeSong(req, res));

  return router;
};

export default createPlaylistRoutes;

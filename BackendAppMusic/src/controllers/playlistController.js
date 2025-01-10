import playlistService from '../services/playlistService.js';
import { createError } from '../utils/error.js';

class PlaylistController {
  async getUserPlaylists(req, res, next) {
    try {
      const userId = req.user?.id || 1;
      const playlists = await playlistService.getUserPlaylists(userId);
      res.json({
        status: 'success',
        data: playlists
      });
    } catch (error) {
      next(error);
    }
  }

  async createPlaylist(req, res, next) {
    try {
      const { name, description } = req.body;
      if (!name) {
        throw createError('Playlist name is required', 400);
      }
      const userId = req.user?.id || 1;
      const playlist = await playlistService.createPlaylist(name, description, userId);
      res.json({
        status: 'success',
        data: playlist
      });
    } catch (error) {
      next(error);
    }
  }

  async getPlaylistById(req, res, next) {
    try {
      const playlist = await playlistService.getPlaylistById(req.params.id);
      if (!playlist) {
        throw createError('Playlist not found', 404);
      }
      res.json({
        status: 'success',
        data: playlist
      });
    } catch (error) {
      next(error);
    }
  }

  async updatePlaylist(req, res, next) {
    try {
      const { name, description } = req.body;
      const playlist = await playlistService.updatePlaylist(req.params.id, { name, description });
      res.json({
        status: 'success',
        data: playlist
      });
    } catch (error) {
      next(error);
    }
  }

  async deletePlaylist(req, res, next) {
    try {
      await playlistService.deletePlaylist(req.params.id);
      res.status(204).send();
    } catch (error) {
      next(error);
    }
  }

  async addSongToPlaylist(req, res, next) {
    try {
      const playlistId = req.params.id;
      const musicId = req.params.musicId || req.body.musicId;
      
      console.log('Adding song to playlist:', { playlistId, musicId, body: req.body });

      if (!musicId) {
        throw createError('Music ID is required', 400);
      }

      await playlistService.addToPlaylist(playlistId, musicId);
      res.json({
        status: 'success',
        message: 'Song added to playlist successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  async removeSongFromPlaylist(req, res, next) {
    try {
      const { id: playlistId, songId: musicId } = req.params;
      await playlistService.removeFromPlaylist(playlistId, musicId);
      res.json({
        status: 'success',
        message: 'Song removed from playlist successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  async getPlaylistSongs(req, res, next) {
    try {
      const { id } = req.params;
      const songs = await playlistService.getPlaylistSongs(id);
      res.json({
        status: 'success',
        data: songs
      });
    } catch (error) {
      next(error);
    }
  }

  async deletePlaylistByParam(req, res, next) {
    try {
      const playlistId = req.query.playlist_id || req.body.playlist_id;
      
      if (!playlistId) {
        return res.status(400).json({
          status: 'error',
          message: 'playlist_id is required'
        });
      }

      await playlistService.deletePlaylist(playlistId);
      
      res.json({
        status: 'success',
        message: `Playlist ${playlistId} deleted successfully`
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new PlaylistController();

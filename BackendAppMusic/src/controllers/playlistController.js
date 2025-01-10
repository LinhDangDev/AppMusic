import playlistService from '../services/playlistService.js';
import { createError } from '../utils/error.js';

class PlaylistController {
  async getUserPlaylists(req, res, next) {
    try {
      const playlists = await playlistService.getUserPlaylists();
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
      const playlist = await playlistService.createPlaylist(name, description);
      res.status(201).json({
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
      const { musicId } = req.body;
      if (!musicId) {
        throw createError('Music ID is required', 400);
      }
      await playlistService.addToPlaylist(req.params.id, musicId);
      res.status(201).json({
        status: 'success',
        message: 'Song added to playlist'
      });
    } catch (error) {
      next(error);
    }
  }

  async removeSongFromPlaylist(req, res, next) {
    try {
      await playlistService.removeFromPlaylist(req.params.id, req.params.songId);
      res.status(204).send();
    } catch (error) {
      next(error);
    }
  }

  async getPlaylistSongs(req, res, next) {
    try {
      const songs = await playlistService.getPlaylistSongs(req.params.id);
      res.json({
        status: 'success',
        data: songs
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new PlaylistController();

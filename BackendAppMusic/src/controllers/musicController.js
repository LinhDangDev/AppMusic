import musicService from '../services/musicService.js';
import { createError } from '../utils/error.js';

class MusicController {
  async searchMusic(req, res, next) {
    try {
      const { q } = req.query;
      if (!q) {
        throw createError('Search query is required', 400);
      }
      const results = await musicService.searchMusic(q);
      res.json({
        status: 'success',
        data: results
      });
    } catch (error) {
      next(error);
    }
  }

  async getMusicById(req, res, next) {
    try {
      const music = await musicService.getMusicById(req.params.id);
      res.json({
        status: 'success',
        data: music
      });
    } catch (error) {
      next(error);
    }
  }

  async getStreamUrl(req, res, next) {
    try {
      const { id } = req.params;
      const music = await musicService.getMusicById(id);
      
      // Xử lý stream URL tùy theo source
      const streamUrl = await musicService.generateStreamUrl(music);
      
      res.json({
        status: 'success',
        data: { streamUrl }
      });
    } catch (error) {
      next(error);
    }
  }

  async recordPlay(req, res, next) {
    try {
      await musicService.recordPlay(req.params.id, req.user.uid);
      res.status(204).send();
    } catch (error) {
      next(error);
    }
  }

  async getTopSongs(req, res, next) {
    try {
      const { limit = 10 } = req.query;
      const songs = await musicService.getTopSongs(parseInt(limit));
      res.json({
        status: 'success',
        data: songs
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new MusicController();

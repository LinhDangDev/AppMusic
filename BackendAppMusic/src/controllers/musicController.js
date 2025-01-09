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
      
      if (!music) {
        throw createError('Music not found', 404);
      }

      // Nếu chưa có source, tự động tìm và thêm
      if (!music.source || music.source === 'itunes') {
        try {
          await musicService.searchAndAddYoutubeSource(
            music.id,
            music.title,
            music.artist_name
          );
          // Lấy lại thông tin music sau khi cập nhật
          music = await musicService.getMusicById(id);
        } catch (error) {
          console.error('Failed to add YouTube source:', error);
          // Fallback to preview URL if YouTube source not found
          return res.json({
            status: 'success',
            data: { streamUrl: music.preview_url }
          });
        }
      }

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

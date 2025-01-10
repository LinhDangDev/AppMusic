import musicService from '../services/musicService.js';
import syncService from '../services/syncService.js';
import rankingService from '../services/rankingService.js';

class MusicController {
  async getAllMusic(req, res, next) {
    try {
      const { limit = 20, offset = 0, sort = 'newest' } = req.query;
      const result = await musicService.getAllMusic(
        parseInt(limit),
        parseInt(offset),
        sort
      );

      res.json({
        success: true,
        data: result.items,
        pagination: result.pagination
      });
    } catch (error) {
      next(error);
    }
  }

  async getMusicById(req, res, next) {
    try {
      const music = await musicService.getMusicById(req.params.id);
      if (!music) {
        return res.status(404).json({
          success: false,
          message: 'Music not found'
        });
      }
      res.json({ success: true, data: music });
    } catch (error) {
      next(error);
    }
  }

  async searchMusic(req, res, next) {
    try {
      const { q, limit = 20 } = req.query;
      
      if (!q) {
        return res.status(400).json({
          success: false,
          message: 'Search query is required'
        });
      }

      // Tìm kiếm tổng hợp
      const results = await musicService.searchAll(q.trim(), parseInt(limit));

      res.json({
        success: true,
        data: results,
        total: results.length,
        message: results.length > 0 ? 
          `Found ${results.length} results` : 
          'No results found'
      });

    } catch (error) {
      console.error('Search error:', error);
      res.status(500).json({
        success: false,
        message: 'Error searching music'
      });
    }
  }

  async getTopMusic(req, res, next) {
    try {
      const { limit } = req.query;
      const music = await musicService.getTopMusic(parseInt(limit) || 10);
      res.json({ success: true, data: music });
    } catch (error) {
      next(error);
    }
  }

  async syncITunes(req, res, next) {
    try {
      await syncService.syncITunesMusic();
      res.json({
        success: true,
        message: 'iTunes sync completed and YouTube URLs update started'
      });
    } catch (error) {
      next(error);
    }
  }

  async triggerSync(req, res, next) {
    try {
      // Chạy sync trong background
      syncService.syncITunesMusic()
        .then(() => console.log('Manual sync completed'))
        .catch(error => console.error('Manual sync failed:', error));
      
      res.json({
        success: true,
        message: 'Sync process started in background'
      });
    } catch (error) {
      next(error);
    }
  }

  // Thêm API riêng cho YouTube search
  async searchYouTube(req, res, next) {
    try {
      const { q, limit = 10 } = req.query;
      
      if (!q) {
        return res.status(400).json({
          success: false,
          message: 'Search query is required'
        });
      }

      const results = await musicService.searchYouTube(q.trim(), parseInt(limit));

      res.json({
        success: true,
        data: results,
        total: results.length,
        message: `Found ${results.length} YouTube results`
      });

    } catch (error) {
      console.error('YouTube search error:', error);
      res.status(500).json({
        success: false,
        message: 'Error searching YouTube'
      });
    }
  }

  async getRankings(req, res, next) {
    try {
      const { region } = req.params;
      const { limit = 100 } = req.query;
      
      const rankings = await rankingService.getTopSongs(
        region.toUpperCase(),
        parseInt(limit)
      );
      
      res.json({
        success: true,
        data: rankings
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new MusicController();

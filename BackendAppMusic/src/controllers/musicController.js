import musicService from '../services/musicService.js';
import syncService from '../services/syncService.js';
import rankingService from '../services/rankingService.js';
import pool from '../config/database.js';

const musicController = {
  getAllMusic: async (req, res, next) => {
    try {
      const { limit, offset, sort } = req.query;
      const result = await musicService.getAllMusic(limit, offset, sort);
      res.json({
        status: 'success',
        data: result
      });
    } catch (error) {
      next(error);
    }
  },

  getMusicById: async (req, res, next) => {
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
  },

  searchMusic: async (req, res, next) => {
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
  },

  getTopMusic: async (req, res, next) => {
    try {
      const { limit } = req.query;
      const music = await musicService.getTopMusic(parseInt(limit) || 10);
      res.json({ success: true, data: music });
    } catch (error) {
      next(error);
    }
  },

  syncITunes: async (req, res, next) => {
    try {
      await syncService.syncITunesMusic();
      res.json({
        success: true,
        message: 'iTunes sync completed and YouTube URLs update started'
      });
    } catch (error) {
      next(error);
    }
  },

  triggerSync: async (req, res, next) => {
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
  },

  // Thêm API riêng cho YouTube search
  searchYouTube: async (req, res, next) => {
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
  },

  getRankings: async (req, res) => {
    try {
      const region = req.params.region.toUpperCase();
      if (!['US', 'VN'].includes(region)) {
        return res.status(400).json({
          status: 'error',
          message: 'Invalid region. Must be US or VN'
        });
      }

      let rankings = await rankingService.getRankingsByRegion(region);
      
      // Nếu không có data hoặc data cũ, update từ iTunes
      if (!rankings.length) {
        rankings = await rankingService.updateRankings(region);
      }

      res.json({
        status: 'success',
        data: {
          region,
          rankings
        }
      });
    } catch (error) {
      console.error('Error getting rankings:', error);
      res.status(500).json({
        status: 'error',
        message: error.message
      });
    }
  },

  // Thêm vào hàng đợi
  addToQueue: async (req, res) => {
    try {
      const { user_id, music_id, source_type = 'manual', source_id = null } = req.body;
      
      // Lấy position cao nhất hiện tại
      const [maxPos] = await pool.query(
        'SELECT MAX(position) as maxPos FROM Queue WHERE user_id = ?',
        [user_id]
      );
      const nextPosition = (maxPos[0].maxPos || 0) + 1;

      // Thêm vào queue
      await pool.query(
        `INSERT INTO Queue (user_id, music_id, position, queue_type, source_id) 
         VALUES (?, ?, ?, ?, ?)`,
        [user_id, music_id, nextPosition, source_type, source_id]
      );

      res.json({
        success: true,
        message: 'Added to queue'
      });
    } catch (error) {
      console.error('Error adding to queue:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to add to queue'
      });
    }
  },

  // Lấy danh sách hàng đợi
  getQueue: async (req, res) => {
    try {
      const user_id = req.query.user_id;
      const [queue] = await pool.query(
        `SELECT q.*, m.title, m.image_url, m.preview_url, a.name as artist_name 
         FROM Queue q 
         JOIN Music m ON q.music_id = m.id 
         JOIN Artists a ON m.artist_id = a.id 
         WHERE q.user_id = ? 
         ORDER BY q.position`,
        [user_id]
      );

      res.json({ 
        success: true, 
        data: queue 
      });
    } catch (error) {
      console.error('Error getting queue:', error);
      res.status(500).json({ 
        success: false, 
        message: 'Failed to get queue' 
      });
    }
  },

  // Xóa khỏi hàng đợi
  removeFromQueue: async (req, res) => {
    try {
      const { id } = req.params;
      const [result] = await pool.query(
        'DELETE FROM Queue WHERE id = ?',
        [id]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({ 
          success: false, 
          message: 'Queue item not found' 
        });
      }

      res.json({ 
        success: true, 
        message: 'Removed from queue' 
      });
    } catch (error) {
      console.error('Error removing from queue:', error);
      res.status(500).json({ 
        success: false, 
        message: 'Failed to remove from queue' 
      });
    }
  },

  getRandomMusic: async (req, res, next) => {
    try {
      const { limit = 10 } = req.query;
      const music = await musicService.getRandomMusic(parseInt(limit));
      res.json({
        status: 'success',
        data: music
      });
    } catch (error) {
      next(error);
    }
  },
};

export default musicController;

const cron = require('node-cron');
const axios = require('axios');
const db = require('../model/db');
const musicService = require('./musicService');

class RankingService {
  async updateCharts() {
    try {
      // Ví dụ lấy top chart từ API của YouTube Music
      const charts = await this.ytMusic.getCharts();
      
      for (const song of charts.songs) {
        // Lưu thông tin bài hát vào database nếu chưa có
        const music = await musicService.searchAndSaveMusic(song.title, song.artist);
        
        // Cập nhật bảng xếp hạng
        await db.execute(`
          INSERT INTO Rankings (platform, music_id, rank_position)
          VALUES ('youtube_music', ?, ?)
          ON DUPLICATE KEY UPDATE rank_position = ?
        `, [music.id, song.rank, song.rank]);
      }
    } catch (error) {
      console.error('Error updating charts:', error);
    }
  }

  startScheduledUpdates() {
    // Cập nhật bảng xếp hạng mỗi 6 tiếng
    cron.schedule('0 */6 * * *', () => {
      this.updateCharts();
    });
  }
}

module.exports = new RankingService(); 
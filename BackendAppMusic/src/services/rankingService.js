import db from '../model/db.js';
import cron from 'node-cron';
import Redis from 'ioredis';

const redis = new Redis({
  host: process.env.REDIS_HOST || 'redis',
  port: process.env.REDIS_PORT || 6379
});

class RankingService {
  constructor() {
    this.CACHE_KEY = 'music_rankings';
    this.UPDATE_INTERVAL = '0 */6 * * *'; // Cập nhật mỗi 6 giờ
  }

  async updateRankings() {
    try {
      const [rows] = await db.execute(`
        SELECT 
          m.id,
          m.title,
          m.artist_id,
          a.name as artist_name,
          COUNT(ph.id) as play_count
        FROM Music m
        LEFT JOIN Play_History ph ON m.id = ph.music_id
        JOIN Artists a ON m.artist_id = a.id
        WHERE ph.played_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
        GROUP BY m.id
        ORDER BY play_count DESC
        LIMIT 100
      `);

      await redis.set(this.CACHE_KEY, JSON.stringify(rows));
      console.log('Rankings updated successfully');
    } catch (error) {
      console.error('Error updating rankings:', error);
    }
  }

  async getRankings() {
    try {
      const cachedRankings = await redis.get(this.CACHE_KEY);
      if (cachedRankings) {
        return JSON.parse(cachedRankings);
      }

      // Nếu không có cache, tính toán lại
      await this.updateRankings();
      const newRankings = await redis.get(this.CACHE_KEY);
      return JSON.parse(newRankings);
    } catch (error) {
      console.error('Error getting rankings:', error);
      throw error;
    }
  }

  startScheduledUpdates() {
    cron.schedule(this.UPDATE_INTERVAL, () => {
      this.updateRankings();
    });
    console.log('Ranking update scheduler started');
  }

  async recordPlay(musicId, userId) {
    try {
      await db.execute(
        'INSERT INTO Play_History (music_id, user_id, played_at) VALUES (?, ?, NOW())',
        [musicId, userId]
      );
    } catch (error) {
      console.error('Error recording play:', error);
      throw error;
    }
  }
}

export default new RankingService(); 
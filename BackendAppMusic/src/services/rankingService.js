import db from '../model/db.js';

class RankingService {
  async getRankings(region = 'VN', limit = 10) {
    try {
      // Validate region
      if (!['VN', 'US'].includes(region)) {
        throw new Error('Invalid region. Must be VN or US');
      }

      const [rows] = await db.query(`
        SELECT 
          m.id,
          m.title,
          m.duration,
          m.play_count,
          m.image_url,
          m.preview_url,
          m.source,
          m.youtube_url,
          m.youtube_thumbnail,
          m.created_at,
          a.name as artist_name,
          a.image_url as artist_image,
          r.position,
          r.region,
          GROUP_CONCAT(DISTINCT g.name) as genres
        FROM Rankings r
        JOIN Music m ON r.music_id = m.id
        LEFT JOIN Artists a ON m.artist_id = a.id
        LEFT JOIN Music_Genres mg ON m.id = mg.music_id
        LEFT JOIN Genres g ON mg.genre_id = g.id
        WHERE r.region = ?
        GROUP BY m.id, r.position
        ORDER BY r.position ASC
        LIMIT ?
      `, [region, limit]);

      return {
        region,
        rankings: rows.map(row => ({
          ...row,
          genres: row.genres ? row.genres.split(',') : []
        }))
      };
    } catch (error) {
      console.error('Error getting rankings:', error);
      throw error;
    }
  }

  async updateRankings() {
    const connection = await db.getConnection();
    try {
      await connection.beginTransaction();

      const regions = ['VN', 'US'];
      
      for (const region of regions) {
        // Lấy top 100 bài hát có điểm cao nhất cho mỗi region
        const [songs] = await connection.query(`
          SELECT 
            m.id,
            (m.play_count * 0.7 + COALESCE(SUM(ph.play_duration), 0) * 0.3) as score
          FROM Music m
          LEFT JOIN Play_History ph ON m.id = ph.music_id
          WHERE EXISTS (
            SELECT 1 
            FROM Rankings r 
            WHERE r.music_id = m.id 
            AND r.region = ?
          )
          GROUP BY m.id
          ORDER BY score DESC
          LIMIT 100
        `, [region]);

        // Cập nhật rankings cho region hiện tại
        for (let i = 0; i < songs.length; i++) {
          await connection.execute(
            `INSERT INTO Rankings (music_id, region, position) 
             VALUES (?, ?, ?)
             ON DUPLICATE KEY UPDATE position = VALUES(position)`,
            [songs[i].id, region, i + 1]
          );
        }

        console.log(`Updated rankings for ${region}: ${songs.length} songs`);
      }

      await connection.commit();
      console.log('Rankings update completed successfully');
    } catch (error) {
      await connection.rollback();
      console.error('Error updating rankings:', error);
      throw error;
    } finally {
      connection.release();
    }
  }

  // Thêm phương thức để lấy rankings cho cả 2 region
  async getAllRegionRankings(limit = 10) {
    try {
      const vnRankings = await this.getRankings('VN', limit);
      const usRankings = await this.getRankings('US', limit);
      
      return {
        VN: vnRankings.rankings,
        US: usRankings.rankings
      };
    } catch (error) {
      console.error('Error getting all region rankings:', error);
      throw error;
    }
  }
}

export default new RankingService(); 
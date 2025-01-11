import db from '../model/db.js';

class RankingService {
  constructor() {
    this.REGIONS = ['VN', 'US'];
  }

  async getRankingsByRegion(region = 'VN') {
    try {
      region = region.toUpperCase();
      if (!this.REGIONS.includes(region)) {
        throw new Error('Invalid region. Must be VN or US');
      }

      // Lấy top 10 bài hát của region
      const [rows] = await db.query(`
        WITH RankedMusic AS (
          SELECT 
            r.position,
            m.id,
            m.title,
            m.youtube_url,
            m.youtube_thumbnail,
            m.preview_url,
            m.play_count,
            m.duration,
            a.name as artist_name,
            a.image_url as artist_image,
            r.region,
            GROUP_CONCAT(DISTINCT g.name) as genres
          FROM Rankings r
          JOIN Music m ON r.music_id = m.id
          JOIN Artists a ON m.artist_id = a.id
          LEFT JOIN Music_Genres mg ON m.id = mg.music_id
          LEFT JOIN Genres g ON mg.genre_id = g.id
          WHERE r.region = ?
          GROUP BY r.id, r.position, r.region
          ORDER BY r.position ASC
          LIMIT 10
        )
        SELECT * FROM RankedMusic
      `, [region]);

      return rows.map(row => ({
        id: row.id,
        title: row.title,
        duration: row.duration || null,
        play_count: row.play_count || 0,
        preview_url: row.preview_url,
        source: 'itunes',
        youtube_url: row.youtube_url,
        youtube_thumbnail: row.youtube_thumbnail,
        artist_name: row.artist_name,
        artist_image: row.artist_image || null,
        position: row.position,
        region: row.region,
        genres: row.genres ? row.genres.split(',') : []
      }));

    } catch (error) {
      console.error(`Error getting rankings for ${region}:`, error);
      throw error;
    }
  }

  // Cập nhật position trong bảng Rankings
  async updatePosition(musicId, region, position) {
    try {
      await db.query(`
        INSERT INTO Rankings (music_id, region, position) 
        VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE position = VALUES(position)
      `, [musicId, region, position]);
    } catch (error) {
      console.error('Error updating ranking position:', error);
      throw error;
    }
  }
}

export default new RankingService();

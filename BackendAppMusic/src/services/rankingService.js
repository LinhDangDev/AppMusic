import db from '../model/db.js';

class RankingService {
  async getRankings(region = 'VN', limit = 100) {
    try {
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
          GROUP_CONCAT(DISTINCT g.name) as genres
        FROM Rankings r
        JOIN Music m ON r.music_id = m.id
        LEFT JOIN Artists a ON m.artist_id = a.id
        LEFT JOIN Music_Genres mg ON m.id = mg.music_id
        LEFT JOIN Genres g ON mg.genre_id = g.id
        WHERE r.region = ?
        GROUP BY m.id, m.title, m.duration, m.play_count, m.image_url, 
                 m.preview_url, m.source, m.youtube_url, m.youtube_thumbnail, 
                 m.created_at, a.name, a.image_url, r.position
        ORDER BY r.position ASC
        LIMIT ?
      `, [region, limit]);

      // Format lại genres cho mỗi bài hát
      const formattedRows = rows.map(row => ({
        ...row,
        genres: row.genres ? row.genres.split(',') : []
      }));

      return {
        region,
        rankings: formattedRows
      };
    } catch (error) {
      console.error('Error getting rankings:', error);
      throw error;
    }
  }

  async updateRankings() {
    try {
      console.log('Starting rankings update...');
      const connection = await db.getConnection();
      
      try {
        await connection.beginTransaction();

        // Xóa rankings cũ
        await connection.execute('DELETE FROM Rankings');

        // Lấy top songs cho mỗi region dựa trên play_count
        const regions = ['VN', 'US'];
        
        for (const region of regions) {
          const [songs] = await connection.query(`
            SELECT id 
            FROM Music 
            ORDER BY play_count DESC, created_at DESC
            LIMIT 100
          `);

          // Insert rankings mới
          for (let i = 0; i < songs.length; i++) {
            await connection.execute(
              'INSERT INTO Rankings (music_id, region, position) VALUES (?, ?, ?)',
              [songs[i].id, region, i + 1]
            );
          }
        }

        await connection.commit();
        console.log('Rankings updated successfully');
      } catch (error) {
        await connection.rollback();
        throw error;
      } finally {
        connection.release();
      }
    } catch (error) {
      console.error('Error updating rankings:', error);
      throw error;
    }
  }
}

export default new RankingService(); 
import db from '../model/db.js';
import YouTube from 'youtube-sr';
import lyricsService from './lyricsService.js';

class MusicService {
  // Thêm method getAllMusic
  async getAllMusic(limit = 20, offset = 0, sort = 'newest') {
    try {
      // Convert params to numbers and set defaults
      const limitNum = Number(limit) || 20;
      const offsetNum = Number(offset) || 0;

      let orderBy;
      switch (sort) {
        case 'popular':
          orderBy = 'play_count DESC';
          break;
        case 'newest':
          orderBy = 'created_at DESC';
          break;
        default:
          orderBy = 'created_at DESC';
      }

      // Sử dụng query với tham số đã được convert
      const [rows] = await db.query(`
        SELECT 
          m.*,
          a.name as artist_name,
          a.image_url as artist_image,
          (SELECT COUNT(*) FROM Favorites f WHERE f.music_id = m.id) as favorite_count,
          GROUP_CONCAT(DISTINCT g.name) as genres,
          (SELECT SUM(play_duration) FROM Play_History WHERE music_id = m.id) as total_play_duration
        FROM Music m
        LEFT JOIN Artists a ON m.artist_id = a.id
        LEFT JOIN Music_Genres mg ON m.id = mg.music_id
        LEFT JOIN Genres g ON mg.genre_id = g.id
        GROUP BY m.id
        ORDER BY ${sort === 'popular' ? 'play_count' : 'created_at'} DESC
        LIMIT ? OFFSET ?
      `, [offsetNum, limitNum]);

      // Đếm tổng số bài hát
      const [totalRows] = await db.query('SELECT COUNT(*) as total FROM Music');

      // Format lại genres cho mỗi bài hát
      const formattedRows = rows.map(row => ({
        ...row,
        genres: row.genres ? row.genres.split(',') : []
      }));

      return {
        items: formattedRows,
        total: totalRows[0].total,
        limit: limitNum,
        offset: offsetNum
      };
    } catch (error) {
      console.error('Error getting all music:', error);
      throw error;
    }
  }

  // Thêm method getMusicById
  async getMusicById(id) {
    try {
      const [rows] = await db.execute(`
        SELECT 
          m.*,
          a.name as artist_name,
          a.image_url as artist_image,
          (SELECT COUNT(*) FROM Favorites f WHERE f.music_id = m.id) as favorite_count
        FROM Music m
        LEFT JOIN Artists a ON m.artist_id = a.id
        WHERE m.id = ?
      `, [id]);

      if (!rows[0]) return null;

      // Nếu chưa có lyrics và đang ở trạng thái PENDING
      if (!rows[0].lyrics && rows[0].lyrics_state === 'PENDING') {
        await lyricsService.updateLyrics(id);
        // Lấy lại data sau khi cập nhật lyrics
        return this.getMusicById(id);
      }

      return rows[0];
    } catch (error) {
      console.error('Error getting music by id:', error);
      throw error;
    }
  }

  // Search trong database
  async searchDatabase(query, limit = 20) {
    try {
      const searchQuery = `%${query}%`;
      const [rows] = await db.query(
        `SELECT 
          m.*,
          a.name as artist_name,
          a.image_url as artist_image,
          (SELECT COUNT(*) FROM Favorites f WHERE f.music_id = m.id) as favorite_count,
          m.play_count,
          m.youtube_url,
          m.youtube_thumbnail
        FROM Music m
        LEFT JOIN Artists a ON m.artist_id = a.id
        WHERE m.title LIKE ? OR a.name LIKE ?
        ORDER BY m.play_count DESC
        LIMIT ?`,
        [searchQuery, searchQuery, limit]
      );
      return rows;
    } catch (error) {
      console.error('Database search error:', error);
      return [];
    }
  }

  // Helper function để phân loại thể loại
  async classifyGenres(title = '', artist = '') {
    const text = `${title} ${artist}`.toLowerCase();
    const genres = [];

    // Các rule để phân loại
    const genreRules = {
      'romance': ['love', 'heart', 'romantic', 'yêu', 'tình yêu', 'valentine'],
      'sad': ['sad', 'buồn', 'lonely', 'alone', 'cry', 'khóc', 'nước mắt'],
      'party': ['party', 'dance', 'club', 'remix', 'edm'],
      'k-pop': ['k-pop', 'kpop', 'korean', 'korea', 'bts', 'blackpink'],
      'hip-hop': ['rap', 'hip hop', 'hip-hop', 'trap'],
      'chill': ['chill', 'relax', 'acoustic'],
      'pop': ['pop', 'nhạc trẻ'],
      'dance & electronic': ['edm', 'electronic', 'dance'],
      'indie & alternative': ['indie', 'alternative'],
      'r&b & soul': ['r&b', 'soul', 'rhythm and blues']
    };

    // Check từng rule
    for (const [genre, keywords] of Object.entries(genreRules)) {
      if (keywords.some(keyword => text.includes(keyword))) {
        genres.push(genre);
      }
    }

    // Thêm genre mặc định nếu không tìm thấy genre nào
    if (genres.length === 0) {
      genres.push('pop');
    }

    // Lấy genre IDs từ database
    const placeholders = genres.map(() => '?').join(',');
    const [rows] = await db.query(
      `SELECT id, name FROM Genres WHERE name IN (${placeholders})`,
      genres
    );

    return rows;
  }

  // Search trên YouTube
  async searchYouTube(query, limit = 10) {
    try {
      const searchQuery = `${query} official music video`;
      const videos = await YouTube.YouTube.search(searchQuery, {
        limit: Math.min(limit * 2, 20),
        type: 'video',
        safeSearch: true
      });

      // Format và thêm genres cho mỗi kết quả
      const formattedResults = await Promise.all(
        videos
          .filter(video => {
            const duration = video.duration / 1000;
            return duration >= 120 && duration <= 600;
          })
          .map(async video => {
            // Phân loại genres
            const genres = await this.classifyGenres(
              video.title,
              video.channel?.name
            );

            return {
              id: `yt_${video.id}`,
              title: video.title,
              artist_name: video.channel?.name || 'Unknown Artist',
              image_url: video.thumbnail?.url || '',
              youtube_url: `https://www.youtube.com/watch?v=${video.id}`,
              youtube_thumbnail: video.thumbnail?.url || '',
              duration: Math.floor(video.duration / 1000),
              source: 'youtube',
              play_count: video.views || 0,
              favorite_count: 0,
              description: video.description || '',
              published_at: video.uploadedAt || new Date().toISOString(),
              genres: genres
            };
          })
      );

      return formattedResults.slice(0, limit);

    } catch (error) {
      console.error('YouTube search error:', error);
      return [];
    }
  }

  // Combine kết quả
  async searchAll(query, limit = 20) {
    try {
      // Tìm trong database trước
      const dbResults = await this.searchDatabase(query, Math.floor(limit / 2));
      
      // Luôn tìm trên YouTube để có kết quả đa dạng
      const youtubeResults = await this.searchYouTube(query, Math.ceil(limit / 2));
      
      // Kết hợp và sắp xếp kết quả
      const combinedResults = [...dbResults, ...youtubeResults];
      
      // Sắp xếp theo lượt play giảm dần
      combinedResults.sort((a, b) => (b.play_count || 0) - (a.play_count || 0));
      
      return combinedResults;
    } catch (error) {
      console.error('Search error:', error);
      return [];
    }
  }

  // Thêm method getRandomMusic
  async getRandomMusic(limit = 10) {
    try {
      const [rows] = await db.query(`
        SELECT 
          m.*,
          a.name as artist_name,
          COALESCE(a.image_url, '') as artist_image,
          GROUP_CONCAT(DISTINCT g.name) as genres
        FROM Music m
        LEFT JOIN Artists a ON m.artist_id = a.id
        LEFT JOIN Music_Genres mg ON m.id = mg.music_id
        LEFT JOIN Genres g ON mg.genre_id = g.id
        WHERE m.youtube_url IS NOT NULL 
          AND m.youtube_thumbnail IS NOT NULL
        GROUP BY m.id
        ORDER BY RAND()
        LIMIT ?
      `, [limit]);

      return rows.map(row => ({
        id: row.id,
        title: row.title,
        artistName: row.artist_name,
        artistImage: row.artist_image || '',
        youtubeUrl: row.youtube_url,
        youtubeThumbnail: row.youtube_thumbnail || '',
        genres: row.genres ? row.genres.split(',') : [],
        duration: row.duration || 0,
        playCount: row.play_count || 0
      }));
    } catch (error) {
      console.error('Error getting random music:', error);
      throw error;
    }
  }
}

export default new MusicService(); 
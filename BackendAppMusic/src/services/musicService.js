import db from '../model/db.js';
import ytdl from 'ytdl-core';
import { createError } from '../utils/error.js';

class MusicService {
  async searchMusic(query) {
    try {
      // Tìm trong database trước
      const [dbResults] = await db.execute(`
        SELECT 
          m.id,
          m.title,
          m.image_url,
          m.preview_url,
          a.name as artist_name,
          a.id as artist_id
        FROM Music m
        JOIN Artists a ON m.artist_id = a.id
        WHERE m.title LIKE ? OR a.name LIKE ?
        LIMIT 10
      `, [`%${query}%`, `%${query}%`]);
      
      // Tìm trên YouTube
      const ytResults = await this.searchYouTube(query);
      
      // Kết hợp kết quả
      return {
        database: dbResults,
        youtube: ytResults
      };
    } catch (error) {
      console.error('Error searching music:', error);
      throw error;
    }
  }

  async searchYouTube(query) {
    try {
      const searchResults = await ytdl.search(query, { limit: 5 });
      return searchResults.map(video => ({
        id: video.id,
        title: video.title,
        thumbnail: `https://img.youtube.com/vi/${video.id}/maxresdefault.jpg`,
        duration: video.duration,
        author: video.author.name,
        url: `https://www.youtube.com/watch?v=${video.id}`
      }));
    } catch (error) {
      console.error('YouTube search error:', error);
      return [];
    }
  }

  async getMusicById(id) {
    try {
      const [rows] = await db.execute(`
        SELECT 
          m.*,
          a.name as artist_name,
          a.id as artist_id
        FROM Music m
        JOIN Artists a ON m.artist_id = a.id
        WHERE m.id = ?
      `, [id]);

      if (!rows.length) {
        throw createError('Music not found', 404);
      }

      return rows[0];
    } catch (error) {
      console.error('Error getting music by id:', error);
      throw error;
    }
  }

  async getStreamUrl(videoId) {
    try {
      const info = await ytdl.getInfo(videoId);
      const format = ytdl.chooseFormat(info.formats, { quality: 'highestaudio' });
      return format.url;
    } catch (error) {
      console.error('Error getting stream URL:', error);
      throw createError('Failed to get stream URL', 500);
    }
  }

  async recordPlay(musicId, userId) {
    try {
      await db.execute(
        'INSERT INTO Play_History (music_id, user_id, played_at) VALUES (?, ?, NOW())',
        [musicId, userId]
      );
    } catch (error) {
      console.error('Error recording play:', error);
      // Không throw error vì đây không phải lỗi nghiêm trọng
    }
  }

  async getTopSongs(limit = 10) {
    try {
      const [rows] = await db.execute(`
        SELECT 
          m.id,
          m.title,
          m.image_url,
          a.name as artist_name,
          COUNT(ph.id) as play_count
        FROM Music m
        LEFT JOIN Play_History ph ON m.id = ph.music_id
        JOIN Artists a ON m.artist_id = a.id
        GROUP BY m.id
        ORDER BY play_count DESC
        LIMIT ?
      `, [limit]);
      
      return rows;
    } catch (error) {
      console.error('Error getting top songs:', error);
      throw error;
    }
  }

  async generateStreamUrl(music) {
    try {
      switch(music.source) {
        case 'youtube':
          return await this.getYoutubeStream(music.source_id);
        case 'itunes':
          // Fallback to preview_url if full version not available
          return music.preview_url;
        default:
          throw createError('Unsupported music source', 400);
      }
    } catch (error) {
      console.error('Error generating stream URL:', error);
      throw error;
    }
  }

  async getYoutubeStream(videoId) {
    try {
      const info = await ytdl.getInfo(videoId);
      const audioFormat = ytdl.chooseFormat(info.formats, { 
        quality: 'highestaudio',
        filter: 'audioonly' 
      });
      
      if (!audioFormat) {
        throw createError('No audio format found', 404);
      }

      return audioFormat.url;
    } catch (error) {
      console.error('Error getting YouTube stream:', error);
      throw createError('Failed to get stream URL', 500);
    }
  }

  async searchAndAddYoutubeSource(musicId, title, artist) {
    try {
      const searchQuery = `${title} ${artist} official audio`;
      const searchResults = await ytdl.search(searchQuery, { limit: 1 });
      
      if (searchResults.length > 0) {
        const videoId = searchResults[0].id;
        const videoUrl = `https://www.youtube.com/watch?v=${videoId}`;
        const thumbnailUrl = `https://img.youtube.com/vi/${videoId}/maxresdefault.jpg`;

        // Sử dụng stored procedure đã tạo
        await db.execute(
          'CALL update_youtube_source(?, ?, ?, ?)',
          [musicId, videoId, videoUrl, thumbnailUrl]
        );
        
        return videoId;
      }
      throw createError('No YouTube source found', 404);
    } catch (error) {
      console.error('Error adding YouTube source:', error);
      throw error;
    }
  }
}

export default new MusicService(); 
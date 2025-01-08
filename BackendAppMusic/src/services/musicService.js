import db from '../model/db.js';
import ytdl from 'ytdl-core';
import { createError } from '../utils/error.js';

class MusicService {
  async searchMusic(query) {
    try {
      const [rows] = await db.execute(`
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
        LIMIT 20
      `, [`%${query}%`, `%${query}%`]);
      
      return rows;
    } catch (error) {
      console.error('Error searching music:', error);
      throw error;
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
    // Xử lý theo source type
    switch(music.sourceType) {
      case 'youtube':
        return await this.getYoutubeStream(music.sourceUrl);
      case 'local':
        return await this.getLocalFileStream(music.filePath);
      // Thêm các source khác
    }
  }
}

export default new MusicService(); 
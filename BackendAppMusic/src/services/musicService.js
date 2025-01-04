const db = require('../model/db');

class MusicService {
  async searchSong(query) {
    try {
      const [songs] = await db.execute(`
        SELECT s.*, a.name as artist_name 
        FROM Songs s
        JOIN Artists a ON s.artist_id = a.id
        WHERE s.title LIKE ? OR a.name LIKE ?
      `, [`%${query}%`, `%${query}%`]);

      return songs.map(song => ({
        id: song.id,
        title: song.title,
        artist: song.artist_name,
        duration: song.duration,
        thumbnail: song.image_url,
        audioUrl: song.audio_url
      }));
    } catch (error) {
      console.error('Error searching songs:', error);
      throw error;
    }
  }

  async getStreamingData(songId) {
    try {
      const [songs] = await db.execute(`
        SELECT s.*, a.name as artist_name 
        FROM Songs s
        JOIN Artists a ON s.artist_id = a.id
        WHERE s.id = ?
      `, [songId]);

      if (songs.length === 0) {
        throw new Error('Song not found');
      }

      const song = songs[0];
      return {
        url: song.audio_url,
        title: song.title,
        artist: song.artist_name,
        thumbnail: song.image_url,
        duration: song.duration
      };
    } catch (error) {
      console.error('Error getting stream data:', error);
      throw error;
    }
  }

  // Thêm các phương thức quản lý bài hát và nghệ sĩ
  async addSong(songData) {
    try {
      const [result] = await db.execute(`
        INSERT INTO Songs (title, artist_id, duration, audio_url, image_url)
        VALUES (?, ?, ?, ?, ?)
      `, [songData.title, songData.artistId, songData.duration, songData.audioUrl, songData.imageUrl]);
      
      return result.insertId;
    } catch (error) {
      console.error('Error adding song:', error);
      throw error;
    }
  }

  async addArtist(artistData) {
    try {
      const [result] = await db.execute(`
        INSERT INTO Artists (name, bio, image_url)
        VALUES (?, ?, ?)
      `, [artistData.name, artistData.bio, artistData.imageUrl]);
      
      return result.insertId;
    } catch (error) {
      console.error('Error adding artist:', error);
      throw error;
    }
  }
}

module.exports = new MusicService(); 
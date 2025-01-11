import db from '../model/db.js';
import { createError } from '../utils/error.js';

class PlaylistService {
  async getUserPlaylists(userId) {
    const [rows] = await db.execute(`
      SELECT p.*, COUNT(ps.music_id) as song_count
      FROM Playlists p
      LEFT JOIN Playlist_Songs ps ON p.id = ps.playlist_id
      WHERE p.user_id = ?
      GROUP BY p.id
    `, [userId]);
    return rows;
  }

  async createPlaylist(name, description = '', userId) {
    const [result] = await db.execute(
      'INSERT INTO Playlists (name, description, user_id) VALUES (?, ?, ?)',
      [name, description, userId]
    );
    return {
      id: result.insertId,
      name,
      description,
      user_id: userId
    };
  }

  async getPlaylistById(playlistId) {
    const [rows] = await db.execute(
      'SELECT * FROM Playlists WHERE id = ?',
      [playlistId]
    );
    return rows[0];
  }

  async updatePlaylist(playlistId, { name, description }) {
    const [playlist] = await db.execute(
      'SELECT * FROM Playlists WHERE id = ?',
      [playlistId]
    );

    if (!playlist.length) {
      throw createError('Playlist not found', 404);
    }

    await db.execute(
      'UPDATE Playlists SET name = ?, description = ? WHERE id = ?',
      [name, description, playlistId]
    );

    return {
      id: playlistId,
      name,
      description
    };
  }

  async deletePlaylist(playlistId) {
    const [result] = await db.execute(
      'DELETE FROM Playlists WHERE id = ?',
      [playlistId]
    );

    if (result.affectedRows === 0) {
      throw createError('Playlist not found', 404);
    }
  }

  async addToPlaylist(playlistId, musicId) {
    const connection = await db.getConnection();
    try {
      await connection.beginTransaction();

      // Lấy position cao nhất hiện tại
      const [maxPos] = await connection.query(
        'SELECT MAX(position) as maxPos FROM Playlist_Songs WHERE playlist_id = ?',
        [playlistId]
      );
      const nextPosition = (maxPos[0].maxPos || 0) + 1;

      // Thêm bài hát với position mới
      await connection.query(
        'INSERT INTO Playlist_Songs (playlist_id, music_id, position) VALUES (?, ?, ?)',
        [playlistId, musicId, nextPosition]
      );

      await connection.commit();
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  async removeFromPlaylist(playlistId, musicId) {
    await db.execute(
      'DELETE FROM Playlist_Songs WHERE playlist_id = ? AND music_id = ?',
      [playlistId, musicId]
    );
  }

  async getPlaylistSongs(playlistId) {
    try {
      const [playlist] = await db.execute(
        'SELECT * FROM Playlists WHERE id = ?',
        [playlistId]
      );

      if (!playlist.length) {
        throw createError('Playlist not found', 404);
      }

      const [songs] = await db.execute(`
        SELECT 
          m.id,
          m.title,
          m.duration,
          m.play_count,
          m.image_url,
          m.preview_url,
          m.youtube_url,
          m.youtube_thumbnail,
          a.name as artist_name,
          a.image_url as artist_image,
          ps.added_at,
          GROUP_CONCAT(DISTINCT g.name) as genres
        FROM Playlist_Songs ps
        JOIN Music m ON ps.music_id = m.id
        LEFT JOIN Artists a ON m.artist_id = a.id
        LEFT JOIN Music_Genres mg ON m.id = mg.music_id
        LEFT JOIN Genres g ON mg.genre_id = g.id
        WHERE ps.playlist_id = ?
        GROUP BY m.id, ps.added_at
        ORDER BY ps.added_at DESC
      `, [playlistId]);

      const formattedSongs = songs.map(song => ({
        id: song.id,
        title: song.title,
        duration: song.duration,
        play_count: song.play_count,
        image_url: song.image_url,
        preview_url: song.preview_url,
        youtube_url: song.youtube_url,
        youtube_thumbnail: song.youtube_thumbnail,
        artist: {
          name: song.artist_name,
          image_url: song.artist_image
        },
        genres: song.genres ? song.genres.split(',') : [],
        added_at: song.added_at
      }));

      return {
        playlist: playlist[0],
        songs: formattedSongs,
        total: formattedSongs.length
      };
    } catch (error) {
      console.error('Error getting playlist songs:', error);
      throw error;
    }
  }
}

export default new PlaylistService();

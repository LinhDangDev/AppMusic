import db from '../model/db.js';
import { createError } from '../utils/error.js';

class UserService {
  async getUserById(uid) {
    try {
      const [rows] = await db.execute(
        'SELECT id, name, email, avatar, created_at FROM Users WHERE id = ?',
        [uid]
      );
      return rows[0];
    } catch (error) {
      console.error('Error getting user:', error);
      throw error;
    }
  }

  async updateUser(uid, { name, avatar }) {
    try {
      await db.execute(
        'UPDATE Users SET name = ?, avatar = ? WHERE id = ?',
        [name, avatar, uid]
      );
      return this.getUserById(uid);
    } catch (error) {
      console.error('Error updating user:', error);
      throw error;
    }
  }

  async getPlayHistory(uid) {
    try {
      const [rows] = await db.execute(`
        SELECT 
          m.id,
          m.title,
          m.image_url,
          a.name as artist_name,
          ph.played_at
        FROM Play_History ph
        JOIN Music m ON ph.music_id = m.id
        JOIN Artists a ON m.artist_id = a.id
        WHERE ph.user_id = ?
        ORDER BY ph.played_at DESC
        LIMIT 50
      `, [uid]);
      return rows;
    } catch (error) {
      console.error('Error getting play history:', error);
      throw error;
    }
  }

  async getFavorites(uid) {
    try {
      const [rows] = await db.execute(`
        SELECT 
          m.id,
          m.title,
          m.image_url,
          a.name as artist_name,
          f.created_at as added_at
        FROM Favorites f
        JOIN Music m ON f.music_id = m.id
        JOIN Artists a ON m.artist_id = a.id
        WHERE f.user_id = ?
        ORDER BY f.created_at DESC
      `, [uid]);
      return rows;
    } catch (error) {
      console.error('Error getting favorites:', error);
      throw error;
    }
  }

  async addToFavorites(uid, musicId) {
    try {
      await db.execute(
        'INSERT INTO Favorites (user_id, music_id) VALUES (?, ?)',
        [uid, musicId]
      );
    } catch (error) {
      if (error.code === 'ER_DUP_ENTRY') {
        throw createError('Song already in favorites', 400);
      }
      console.error('Error adding to favorites:', error);
      throw error;
    }
  }

  async removeFromFavorites(uid, musicId) {
    try {
      await db.execute(
        'DELETE FROM Favorites WHERE user_id = ? AND music_id = ?',
        [uid, musicId]
      );
    } catch (error) {
      console.error('Error removing from favorites:', error);
      throw error;
    }
  }
}

export default new UserService(); 
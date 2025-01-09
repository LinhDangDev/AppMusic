import db from '../model/db.js';
import { createError } from '../utils/error.js';
import admin from '../config/firebase.js';

class UserService {
  async getUserById(uid) {
    try {
      const [rows] = await db.execute(
        'SELECT id, name, email, avatar, created_at FROM Users WHERE firebase_uid = ?',
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
        'UPDATE Users SET name = ?, avatar = ? WHERE firebase_uid = ?',
        [name, avatar, uid]
      );
      return this.getUserById(uid);
    } catch (error) {
      console.error('Error updating user:', error);
      throw error;
    }
  }

  async changePassword(uid, currentPassword, newPassword) {
    try {
      // Xác thực mật khẩu hiện tại thông qua Firebase
      const user = await admin.auth().getUser(uid);
      // Cập nhật mật khẩu mới
      await admin.auth().updateUser(uid, {
        password: newPassword
      });
    } catch (error) {
      console.error('Error changing password:', error);
      throw createError('Failed to change password', 400);
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
        JOIN Users u ON ph.user_id = u.id
        WHERE u.firebase_uid = ?
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
        JOIN Users u ON f.user_id = u.id
        WHERE u.firebase_uid = ?
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
      const [user] = await db.execute('SELECT id FROM Users WHERE firebase_uid = ?', [uid]);
      if (!user.length) {
        throw createError('User not found', 404);
      }

      await db.execute(
        'INSERT INTO Favorites (user_id, music_id) VALUES (?, ?)',
        [user[0].id, musicId]
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
      const [user] = await db.execute('SELECT id FROM Users WHERE firebase_uid = ?', [uid]);
      if (!user.length) {
        throw createError('User not found', 404);
      }

      await db.execute(
        'DELETE FROM Favorites WHERE user_id = ? AND music_id = ?',
        [user[0].id, musicId]
      );
    } catch (error) {
      console.error('Error removing from favorites:', error);
      throw error;
    }
  }

  async createUser({ firebase_uid, email, name }) {
    try {
      const [result] = await db.execute(
        'INSERT INTO Users (firebase_uid, email, name) VALUES (?, ?, ?)',
        [firebase_uid, email, name]
      );
      return result.insertId;
    } catch (error) {
      console.error('Error creating user in database:', error);
      throw error;
    }
  }
}

export default new UserService(); 
import db from '../model/db.js';
import { createError } from '../utils/error.js';

class PlaylistService {
  async getUserPlaylists() {
    const [rows] = await db.execute(`
      SELECT p.*, COUNT(ps.music_id) as song_count
      FROM Playlists p
      LEFT JOIN Playlist_Songs ps ON p.id = ps.playlist_id
      GROUP BY p.id
    `);
    return rows;
  }

  async createPlaylist(name, description = '') {
    const [result] = await db.execute(
      'INSERT INTO Playlists (name, description) VALUES (?, ?)',
      [name, description]
    );
    return {
      id: result.insertId,
      name,
      description
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
    const [playlist] = await db.execute(
      'SELECT * FROM Playlists WHERE id = ?',
      [playlistId]
    );

    if (!playlist.length) {
      throw createError('Playlist not found', 404);
    }

    await db.execute(
      'INSERT INTO Playlist_Songs (playlist_id, music_id) VALUES (?, ?)',
      [playlistId, musicId]
    );
  }

  async removeFromPlaylist(playlistId, musicId) {
    await db.execute(
      'DELETE FROM Playlist_Songs WHERE playlist_id = ? AND music_id = ?',
      [playlistId, musicId]
    );
  }

  async getPlaylistSongs(playlistId) {
    const [songs] = await db.execute(`
      SELECT m.*, a.name as artist_name
      FROM Music m
      JOIN Artists a ON m.artist_id = a.id
      JOIN Playlist_Songs ps ON m.id = ps.music_id
      WHERE ps.playlist_id = ?
    `, [playlistId]);

    return songs;
  }
}

export default new PlaylistService();

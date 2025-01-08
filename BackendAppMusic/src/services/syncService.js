import axios from 'axios';
import db from '../model/db.js';

class SyncService {
  constructor() {
    this.ITUNES_API = 'https://itunes.apple.com/us/rss/topsongs/limit=100/json';
  } 

  async syncITunesCharts() {
    try {
      console.log('Starting iTunes charts sync...');

      const response = await axios.get(this.ITUNES_API);
      const songs = response.data.feed.entry;

      for (const song of songs) {
        try {
          // Kiểm tra và thêm artist nếu chưa tồn tại
          const artistName = song['im:artist'].label;
          let [artist] = await db.execute('SELECT id FROM Artists WHERE name = ?', [artistName]);

          let artistId;
          if (!artist.length) {
            const [result] = await db.execute(
              'INSERT INTO Artists (name) VALUES (?)',
              [artistName]
            );
            artistId = result.insertId;
          } else {
            artistId = artist[0].id;
          }

          // Kiểm tra và thêm bài hát nếu chưa tồn tại
          const title = song['im:name'].label;
          const [existingSong] = await db.execute(
            'SELECT id FROM Music WHERE title = ? AND artist_id = ?',
            [title, artistId]
          );

          if (!existingSong.length) {
            const imageUrl = song['im:image'][2].label;
            const previewUrl = song.link[1].attributes.href;

            await db.execute(`
              INSERT INTO Music (title, artist_id, image_url, preview_url, source, source_id)
              VALUES (?, ?, ?, ?, 'itunes', ?)
            `, [
              title,
              artistId,
              imageUrl,
              previewUrl,
              song.id.attributes['im:id']
            ]);
          }
        } catch (error) {
          console.error(`Error processing song ${song['im:name'].label}:`, error);
          continue;
        }
      }

      console.log('iTunes charts sync completed successfully');
    } catch (error) {
      console.error('Error syncing iTunes charts:', error);
      throw error;
    }
  }

  async getLastSyncTime() {
    try {
      const [rows] = await db.execute('SELECT value FROM System_Settings WHERE key = "last_itunes_sync"');
      return rows[0]?.value;
    } catch (error) {
      console.error('Error getting last sync time:', error);
      return null;
    }
  }

  async updateLastSyncTime() {
    try {
      await db.execute(`
        INSERT INTO System_Settings (key, value)
        VALUES ("last_itunes_sync", NOW())
        ON DUPLICATE KEY UPDATE value = NOW()
      `);
    } catch (error) {
      console.error('Error updating last sync time:', error);
    }
  }
}

export default new SyncService();

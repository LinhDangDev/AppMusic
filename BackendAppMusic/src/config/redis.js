
import db from '../config/database.js';
import { google } from 'googleapis';
import puppeteer from 'puppeteer';
import Redis from 'ioredis';

const redis = new Redis({
  host: process.env.REDIS_HOST || 'localhost',
  port: process.env.REDIS_PORT || 6379,
  password: process.env.REDIS_PASSWORD || 'cntt15723'
});

const youtube = google.youtube({
  version: 'v3',
  auth: process.env.YOUTUBE_API_KEY
});

class MusicService {
  async getAllMusic(limit = 20, offset = 0) {
    const [rows] = await db.execute(`
      SELECT
        m.*,
        a.name as artist_name,
        a.image_url as artist_image,
        (SELECT COUNT(*) FROM Favorites f WHERE f.music_id = m.id) as favorite_count,
        m.play_count,
        m.youtube_url,
        m.youtube_thumbnail
      FROM Music m
      LEFT JOIN Artists a ON m.artist_id = a.id
      ORDER BY m.created_at DESC
      LIMIT ? OFFSET ?
    `, [limit, offset]);
    return rows;
  }

  async getMusicById(id) {
    const [rows] = await db.execute(`
      SELECT
        m.*,
        a.name as artist_name,
        a.image_url as artist_image,
        (SELECT COUNT(*) FROM Favorites f WHERE f.music_id = m.id) as favorite_count,
        m.play_count,
        m.youtube_url,
        m.youtube_thumbnail
      FROM Music m
      LEFT JOIN Artists a ON m.artist_id = a.id
      WHERE m.id = ?
    `, [id]);

    if (!rows[0]) return null;

    // Nếu chưa có YouTube URL, tìm và cập nhật
    if (!rows[0].youtube_url) {
      const videoData = await this.scrapeYouTubeVideo(
        rows[0].title,
        rows[0].artist_name
      );

      if (videoData) {
        await this.updateYouTubeData(id, videoData);
        rows[0].youtube_url = videoData.videoUrl;
        rows[0].youtube_thumbnail = videoData.thumbnailUrl;
      }
    }

    return rows[0];
  }

  async searchMusic(query) {
    const [rows] = await db.execute(`
      SELECT
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
    `, [`%${query}%`, `%${query}%`]);
    return rows;
  }

  async searchYouTubeVideo(title, artistName) {
    try {
      const searchQuery = `${title} ${artistName} official audio`;
      const response = await youtube.search.list({
        part: ['snippet'],
        q: searchQuery,
        type: ['video'],
        videoCategoryId: '10',
        maxResults: 1
      });

      if (response.data.items && response.data.items.length > 0) {
        const video = response.data.items[0];
        return {
          videoId: video.id.videoId,
          videoUrl: `https://www.youtube.com/watch?v=${video.id.videoId}`,
          thumbnailUrl: video.snippet.thumbnails.high.url
        };
      }
      return null;
    } catch (error) {
      if (error.response && error.response.status === 403 && error.response.data.error.errors[0].reason === 'quotaExceeded') {
        console.error('YouTube API quota exceeded. Retrying after delay...');
        await new Promise(resolve => setTimeout(resolve, 60000)); // Retry after 1 minute
        return this.searchYouTubeVideo(title, artistName);
      } else {
        console.error('YouTube API Error:', error.message);
        return null;
      }
    }
  }

  async scrapeYouTubeVideo(title, artistName) {
    const searchQuery = `${title} ${artistName} official audio`;
    const url = `https://www.youtube.com/results?search_query=${encodeURIComponent(searchQuery)}`;

    try {
      const browser = await puppeteer.launch();
      const page = await browser.newPage();
      await page.goto(url);

      const videoData = await page.evaluate(() => {
        const video = document.querySelector('ytd-video-renderer');
        if (video) {
          const videoId = video.querySelector('a#thumbnail').href.split('v=')[1];
          const videoUrl = `https://www.youtube.com/watch?v=${videoId}`;
          const thumbnailUrl = video.querySelector('img').src;
          return { videoId, videoUrl, thumbnailUrl };
        }
        return null;
      });

      await browser.close();
      return videoData;
    } catch (error) {
      console.error('Error scraping YouTube:', error);
      return null;
    }
  }

  async updateYouTubeData(musicId, videoData) {
    await db.execute(
      `UPDATE Music
       SET youtube_url = ?,
           youtube_thumbnail = ?,
           updated_at = NOW()
       WHERE id = ?`,
      [videoData.videoUrl, videoData.thumbnailUrl, musicId]
    );
  }
}

export default new MusicService();

import axios from 'axios';
import db from '../model/db.js';
import YouTube from 'youtube-sr';
import cron from 'node-cron';
import rankingService from './rankingService.js';

class SyncService {
  constructor() {
    this.ITUNES_URLS = {
      'VN': 'https://itunes.apple.com/vn/rss/topsongs/limit=100/json',
      'US': 'https://itunes.apple.com/us/rss/topsongs/limit=100/json'
    };

    // Chạy sync iTunes mỗi 12 giờ
    if (process.env.ENABLE_CRON_SYNC === 'true') {
      cron.schedule('0 */12 * * *', async () => {
        console.log('Starting scheduled sync...', new Date());
        try {
          await this.syncITunesMusic();
          console.log('Scheduled sync completed');
        } catch (error) {
          console.error('Scheduled sync failed:', error);
        }
      });
    }

    // Khởi tạo dữ liệu khi start server
    this.initializeData();
  }

  async initializeData() {
    try {
      console.log('Starting data initialization...');
      await this.syncITunesMusic();
      console.log('Data initialization completed successfully');
    } catch (error) {
      console.error('Error in data initialization:', error);
    }
  }

  async searchYouTubeVideo(query, retries = 3) {
    for (let i = 0; i < retries; i++) {
      try {
        // Thêm delay giữa các request
        if (i > 0) {
          await new Promise(resolve => setTimeout(resolve, 2000));
        }

        // Sửa cách gọi YouTube search
        const videos = await YouTube.default.search(query, {
          limit: 1,
          type: 'video',
          safeSearch: true
        });

        if (videos && videos.length > 0) {
          const video = videos[0];
          console.log(`✅ Found YouTube video: ${video.title}`);
          return {
            videoId: video.id,
            videoUrl: `https://www.youtube.com/watch?v=${video.id}`,
            thumbnailUrl: video.thumbnail?.url || video.thumbnails[0]?.url
          };
        }
        console.log(`⚠️ No results found for: ${query}`);
        return null;
      } catch (error) {
        console.error(`❌ Attempt ${i + 1}/${retries} failed for "${query}":`, error.message);

        // Nếu là lỗi fetch hoặc rate limit, đợi lâu hơn
        if (error.message.includes('fetch failed') || error.message.includes('rate limit')) {
          const delay = 5000 * (i + 1);
          console.log(`Waiting ${delay/1000} seconds before retry...`);
          await new Promise(resolve => setTimeout(resolve, delay));
        }

        // Nếu là lần thử cuối cùng thì return null
        if (i === retries - 1) {
          console.error(`❌ All ${retries} attempts failed for "${query}"`);
          return null;
        }
      }
    }
    return null;
  }

  async syncITunesMusic() {
    try {
      console.log('Starting iTunes sync process...');
      
      for (const [region, url] of Object.entries(this.ITUNES_URLS)) {
        console.log(`Syncing ${region} iTunes store...`);
        console.log(`Fetching from: ${url}`);
        
        const response = await axios.get(url);
        const songs = response.data.feed.entry;

        for (const song of songs) {
          const title = song['im:name'].label;
          const artistName = song['im:artist'].label;

          console.log(`Processing: ${title} - ${artistName}`);

          // Kiểm tra và thêm artist
          let [artist] = await db.query(
            'SELECT id FROM Artists WHERE name = ?',
            [artistName]
          );
          
          let artistId;
          if (artist.length === 0) {
            console.log(`Created new artist: ${artistName}`);
            const [newArtist] = await db.query(
              'INSERT INTO Artists (name) VALUES (?)',
              [artistName]
            );
            artistId = newArtist.insertId;
          } else {
            artistId = artist[0].id;
          }

          // Kiểm tra bài hát tồn tại
          const [existingSong] = await db.query(
            `SELECT id, youtube_url, youtube_thumbnail 
             FROM Music 
             WHERE title = ? AND artist_id = ?`,
            [title, artistId]
          );
          
          let musicId;
          if (existingSong.length === 0) {
            console.log(`Added new song: ${title}`);
            const [newSong] = await db.query(
              'INSERT INTO Music (title, artist_id, source, preview_url) VALUES (?, ?, ?, ?)',
              [title, artistId, 'itunes', song.link[0].attributes.href]
            );
            musicId = newSong.insertId;

            // Tìm YouTube URL cho bài hát mới
            const searchQuery = `${title} ${artistName} official audio`;
            console.log(`✅ Found YouTube video for: ${searchQuery}`);
            const videoData = await this.searchYouTubeVideo(searchQuery);
            if (videoData) {
              console.log(`Found YouTube data for: ${title}`);
              await db.query(
                `UPDATE Music 
                 SET youtube_url = ?, youtube_thumbnail = ?
                 WHERE id = ?`,
                [videoData.videoUrl, videoData.thumbnailUrl, musicId]
              );
            }
          } else {
            musicId = existingSong[0].id;
            // Cập nhật YouTube URL nếu chưa có
            if (!existingSong[0].youtube_url || !existingSong[0].youtube_thumbnail) {
              const searchQuery = `${title} ${artistName} official audio`;
              console.log(`✅ Found YouTube video for: ${searchQuery}`);
              const videoData = await this.searchYouTubeVideo(searchQuery);
              if (videoData) {
                console.log(`Found YouTube data for: ${title}`);
                await db.query(
                  `UPDATE Music 
                   SET youtube_url = ?, youtube_thumbnail = ?
                   WHERE id = ?`,
                  [videoData.videoUrl, videoData.thumbnailUrl, musicId]
                );
              }
            }
          }
          
          // Cập nhật Rankings
          await rankingService.updatePosition(musicId, region, songs.indexOf(song) + 1);
        }
        
        console.log(`Completed sync for ${region}`);
      }
      
      console.log('iTunes sync completed');
    } catch (error) {
      console.error('Error syncing iTunes music:', error);
      throw error;
    }
  }
}

export default new SyncService();

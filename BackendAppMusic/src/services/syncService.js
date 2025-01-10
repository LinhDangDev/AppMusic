import axios from 'axios';
import db from '../model/db.js';
import YouTube from 'youtube-sr';
import cron from 'node-cron';
import rankingService from './rankingService.js';

const BATCH_SIZE = 100;

class SyncService {
  constructor() {
    // Cập nhật URLs cho cả US và VN iTunes Store
    this.ITUNES_URLS = [
      'https://itunes.apple.com/us/rss/topsongs/limit=100/json',
      'https://itunes.apple.com/vn/rss/topsongs/limit=100/json'
    ];

    // Chạy sync mỗi 12 giờ
    if (process.env.ENABLE_CRON_SYNC === 'true') {
      cron.schedule('5* * * * *', async () => {
        console.log('Starting scheduled sync...');
        try {
          await this.syncITunesMusic();
          console.log('Scheduled sync completed');
        } catch (error) {
          console.error('Scheduled sync failed:', error);
        }
      });
    }

    // Thêm kiểm tra và cập nhật rankings khi khởi động
    this.initializeRankings();
  }

  async searchYouTubeVideo(query) {
    try {
    //   await new Promise(resolve => setTimeout(resolve, 1000 + Math.random() * 2000));

      const videos = await YouTube.default.search(query, {
        limit: 1,
        type: 'video',
        safeSearch: true
      });

      if (videos && videos.length > 0) {
        const video = videos[0];
        return {
          videoId: video.id,
          videoUrl: `https://www.youtube.com/watch?v=${video.id}`,
          thumbnailUrl: video.thumbnail?.url || video.thumbnails[0]?.url
        };
      }
      return null;
    } catch (error) {
      console.error('YouTube search error:', error.message);
      return null;
    }
  }

  async updateYouTubeURLs() {
    try {
      console.log('Starting YouTube URL update...');

      // Sửa query để chỉ lấy những bài chưa có URL hoặc thumbnail
      const [songs] = await this.retryDbExecute(`
        SELECT m.id, m.title, a.name as artist_name, m.youtube_url, m.youtube_thumbnail
        FROM Music m
        JOIN Artists a ON m.artist_id = a.id
        WHERE m.youtube_url IS NULL
        OR m.youtube_url = ''
        OR m.youtube_thumbnail IS NULL
        OR m.youtube_thumbnail = ''
        LIMIT ${BATCH_SIZE}
      `);

      console.log(`Found ${songs.length} songs without YouTube URLs`);

      for (const song of songs) {
        try {
          // Kiểm tra nếu đã có đủ cả URL và thumbnail thì bỏ qua
          if (song.youtube_url && song.youtube_thumbnail) {
            console.log(`⏩ Skipping ${song.title} - already has YouTube data`);
            continue;
          }

          const searchQuery = `${song.title} ${song.artist_name} official audio`;
          console.log(`🔍 Searching YouTube for: ${searchQuery}`);

          const videoData = await this.searchYouTubeVideo(searchQuery);

          if (videoData) {
            await this.retryDbExecute(
              `UPDATE Music
               SET youtube_url = ?,
                   youtube_thumbnail = ?,
                   updated_at = NOW()
               WHERE id = ?`,
              [videoData.videoUrl, videoData.thumbnailUrl, song.id]
            );

            console.log(`✅ Updated YouTube URL for: ${song.title} - ${song.artist_name}`);
          } else {
            console.log(`❌ No YouTube video found for: ${song.title}`);
          }

          // Thêm delay ngắn hơn vì đã có kiểm tra skip
          await new Promise(resolve => setTimeout(resolve, 1500));
        } catch (error) {
          console.error(`Error updating ${song.title}:`, error.message);
          continue;
        }
      }

      // Thống kê kết quả
      const [updatedCount] = await this.retryDbExecute(`
        SELECT COUNT(*) as count
        FROM Music
        WHERE youtube_url IS NOT NULL
        AND youtube_thumbnail IS NOT NULL
      `);

      console.log(`Finished updating YouTube URLs. Total songs with YouTube data: ${updatedCount[0].count}`);
    } catch (error) {
      console.error('Error in updateYouTubeURLs:', error);
    }
  }

  async syncITunesCharts() {
    try {
      console.log('Starting iTunes charts sync...');
      const response = await axios.get(this.ITUNES_API);
      const songs = response.data.feed.entry;
      let processedCount = 0;

      for (const song of songs) {
        try {
          const title = song['im:name'].label;
          const artistName = song['im:artist'].label;
          const imageUrl = song['im:image'][2].label;
          const previewUrl = song.link[1]?.attributes?.href;

          // Kiểm tra và thêm artist
          let [artist] = await this.retryDbExecute('SELECT id FROM Artists WHERE name = ?', [artistName]);

          let artistId;
          if (!artist.length) {
            const [result] = await this.retryDbExecute(
              'INSERT INTO Artists (name) VALUES (?)',
              [artistName]
            );
            artistId = result.insertId;
            console.log(`✅ Created new artist: ${artistName}`);
          } else {
            artistId = artist[0].id;
          }

          // Kiểm tra và thêm bài hát
          const [existingSong] = await this.retryDbExecute(
            'SELECT id FROM Music WHERE title = ? AND artist_id = ?',
            [title, artistId]
          );

          if (!existingSong.length) {
            await this.retryDbExecute(`
              INSERT INTO Music (title, artist_id, image_url, preview_url, source, source_id)
              VALUES (?, ?, ?, ?, 'itunes', ?)
            `, [
              title,
              artistId,
              imageUrl,
              previewUrl,
              song.id.attributes['im:id']
            ]);
            console.log(`✅ Added new song: ${title} - ${artistName}`);
          }

          processedCount++;
          console.log(`Progress: ${processedCount}/${songs.length} songs processed`);

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
      const [rows] = await this.retryDbExecute('SELECT value FROM System_Settings WHERE key = "last_itunes_sync"');
      return rows[0]?.value;
    } catch (error) {
      console.error('Error getting last sync time:', error);
      return null;
    }
  }

  async updateLastSyncTime() {
    try {
      await this.retryDbExecute(`
        INSERT INTO System_Settings (key, value)
        VALUES ("last_itunes_sync", NOW())
        ON DUPLICATE KEY UPDATE value = NOW()
      `);
    } catch (error) {
      console.error('Error updating last sync time:', error);
    }
  }

  async syncITunesMusic() {
    try {
      console.log('Starting iTunes music sync...');

      // Lấy data từ cả 2 thị trường
      for (const url of this.ITUNES_URLS) {
        console.log(`Fetching data from: ${url}`);
        const response = await axios.get(url);
        const songs = response.data.feed.entry;

        for (const song of songs) {
          try {
            const title = song['im:name'].label;
            const artistName = song['im:artist'].label;

            console.log(`Processing: ${title} - ${artistName}`);

            // ... code xử lý tiếp theo ...
          } catch (error) {
            console.error(`Error processing song: ${error.message}`);
            continue;
          }
        }

        // Thêm delay nhỏ giữa các request để tránh quá tải
        await new Promise(resolve => setTimeout(resolve, 1000));
      }

      console.log('iTunes sync completed successfully');
    } catch (error) {
      console.error('iTunes sync failed:', error);
      throw error;
    }
  }

  async retryDbExecute(query, params, retries = 5) {
    for (let i = 0; i < retries; i++) {
      try {
        return await db.execute(query, params);
      } catch (error) {
        if (i === retries - 1) throw error;
        console.error(`Database connection failed. Retrying (${i + 1}/${retries})...`);
        await new Promise(resolve => setTimeout(resolve, 2000));
      }
    }
  }

  async initializeRankings() {
    try {
      // Kiểm tra xem đã có rankings chưa
      const [rankings] = await db.execute('SELECT COUNT(*) as count FROM Rankings');

      if (rankings[0].count === 0) {
        console.log('No rankings found. Initializing rankings...');
        await rankingService.updateRankings();
      }
    } catch (error) {
      console.error('Error initializing rankings:', error);
    }
  }
}

export default new SyncService();

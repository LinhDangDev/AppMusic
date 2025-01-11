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
      cron.schedule('*/5 * * * *', async () => {
        console.log('Starting scheduled sync...', new Date());
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
          console.log(`✅ Found YouTube video for: ${query}`);
          return {
            videoId: video.id,
            videoUrl: `https://www.youtube.com/watch?v=${video.id}`,
            thumbnailUrl: video.thumbnail?.url || video.thumbnails[0]?.url
          };
        }

        console.log(`⚠️ No results found for: ${query}`);

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

  async updateYouTubeURLs() {
    try {
      console.log('Starting YouTube URL update...');

      // Lấy số lượng nhỏ hơn mỗi lần
      const BATCH_SIZE = 200; // Giảm batch size xuống

      const [songs] = await this.retryDbExecute(`
        SELECT m.id, m.title, a.name as artist_name
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
        const searchQuery = `${song.title} ${song.artist_name} official audio`;
        console.log(`\n🔍 Searching for: ${song.title} - ${song.artist_name}`);

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
          console.log(`✅ Updated: ${song.title}`);
        }

        // Thêm delay giữa các bài hát
        await new Promise(resolve => setTimeout(resolve, 3000));
      }

      console.log('\nYouTube URL update completed');

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
      console.log('Starting iTunes sync process...');

      // Sync từ US store
      console.log('Syncing US iTunes store...');
      for (const url of this.ITUNES_URLS) {
        console.log(`Fetching from: ${url}`);
        const response = await axios.get(url);
        const songs = response.data.feed.entry;

        for (const song of songs) {
          try {
            const title = song['im:name'].label;
            const artistName = song['im:artist'].label;
            console.log(`Processing: ${title} - ${artistName}`);

            // Thêm artist
            let [artist] = await this.retryDbExecute(
              'SELECT id FROM Artists WHERE name = ?',
              [artistName]
            );

            let artistId;
            if (!artist.length) {
              const [result] = await this.retryDbExecute(
                'INSERT INTO Artists (name) VALUES (?)',
                [artistName]
              );
              artistId = result.insertId;
              console.log(`Created new artist: ${artistName} (ID: ${artistId})`);
            } else {
              artistId = artist[0].id;
            }

            // Kiểm tra và thêm bài hát
            const [existingSong] = await this.retryDbExecute(
              'SELECT id FROM Music WHERE title = ? AND artist_id = ?',
              [title, artistId]
            );

            if (!existingSong.length) {
              const imageUrl = song['im:image'][2].label;
              const previewUrl = song.link[1]?.attributes?.href;

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
              console.log(`Added new song: ${title}`);

              // Tìm và thêm YouTube URL ngay sau khi thêm bài hát
              const searchQuery = `${title} ${artistName} official audio`;
              const videoData = await this.searchYouTubeVideo(searchQuery);
              if (videoData) {
                console.log(`Found YouTube data for: ${title}`);
                await this.retryDbExecute(
                  `UPDATE Music
                   SET youtube_url = ?, youtube_thumbnail = ?
                   WHERE title = ? AND artist_id = ?`,
                  [videoData.videoUrl, videoData.thumbnailUrl, title, artistId]
                );
              }
            }
          } catch (error) {
            console.error(`Error processing song ${song['im:name'].label}:`, error);
          }
        }
      }

      console.log('iTunes sync completed');

      // Update YouTube URLs cho những bài chưa có
      await this.updateYouTubeURLs();

    } catch (error) {
      console.error('Sync failed:', error);
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

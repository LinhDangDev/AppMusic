import db from '../model/db.js';
import musicService from '../services/musicService.js';
import ytdl from 'ytdl-core';

async function updateMusicSources() {
  try {
    // Lấy danh sách bài hát chưa có nguồn YouTube
    const [songs] = await db.execute(`
      SELECT m.id, m.title, m.artist_id, a.name as artist_name
      FROM Music m
      JOIN Artists a ON m.artist_id = a.id
      WHERE m.source IS NULL 
      OR m.source = 'itunes'
      OR (m.source = 'youtube' AND m.youtube_url IS NULL)
      LIMIT 10
    `);

    console.log(`Found ${songs.length} songs to update`);

    for (const song of songs) {
      try {
        // Tìm kiếm trên YouTube
        const searchQuery = `${song.title} ${song.artist_name} official audio`;
        console.log(`Searching for: ${searchQuery}`);

        const searchResults = await ytdl.search(searchQuery, { limit: 1 });
        
        if (searchResults && searchResults.length > 0) {
          const video = searchResults[0];
          const videoId = video.id;
          const videoUrl = `https://www.youtube.com/watch?v=${videoId}`;
          const thumbnailUrl = `https://img.youtube.com/vi/${videoId}/maxresdefault.jpg`;

          // Cập nhật vào database
          await db.execute(
            'CALL update_youtube_source(?, ?, ?, ?)',
            [song.id, videoId, videoUrl, thumbnailUrl]
          );

          console.log(`✅ Updated source for: ${song.title} - ${song.artist_name}`);
        } else {
          console.log(`❌ No YouTube results found for: ${song.title}`);
        }

        // Đợi 1 giây trước khi xử lý bài tiếp theo để tránh rate limit
        await new Promise(resolve => setTimeout(resolve, 1000));

      } catch (error) {
        console.error(`❌ Failed to update ${song.title}:`, error.message);
        continue;
      }
    }

    console.log('✨ Finished updating music sources');
  } catch (error) {
    console.error('Error updating music sources:', error);
  } finally {
    // Đóng kết nối database
    await db.end();
    process.exit(0);
  }
}

// Chạy script
console.log('🎵 Starting YouTube source update...');
updateMusicSources();

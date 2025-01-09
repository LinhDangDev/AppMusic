import { google } from 'googleapis';
import db from '../model/db.js';

const youtube = google.youtube({
  version: 'v3',
  auth: process.env.YOUTUBE_API_KEY
});

const BATCH_SIZE = 100;

async function searchYouTubeVideo(query) {
  try {
    const response = await youtube.search.list({
      part: ['snippet'],
      q: query,
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
    console.error('YouTube API Error:', error.message);
    return null;
  }
}

async function getTotalSongsCount() {
  const [result] = await db.execute(`
    SELECT COUNT(*) as total 
    FROM Music m
    JOIN Artists a ON m.artist_id = a.id
    WHERE m.youtube_url IS NULL
  `);
  return result[0].total;
}

async function updateMusicSources() {
  try {
    const totalSongs = await getTotalSongsCount();
    console.log(`Total songs to process: ${totalSongs}`);

    let processedCount = 0;
    
    while (processedCount < totalSongs) {
      // Lấy batch tiếp theo
      const [songs] = await db.execute(`
        SELECT m.id, m.title, m.artist_id, a.name as artist_name 
        FROM Music m
        JOIN Artists a ON m.artist_id = a.id
        WHERE m.youtube_url IS NULL
        LIMIT ${BATCH_SIZE}
      `);

      if (songs.length === 0) break;

      console.log(`Processing batch of ${songs.length} songs (${processedCount + 1} - ${processedCount + songs.length} of ${totalSongs})`);

      for (const song of songs) {
        try {
          const searchQuery = `${song.title} ${song.artist_name} official audio`;
          console.log(`🔍 Searching YouTube for: ${searchQuery}`);

          const videoData = await searchYouTubeVideo(searchQuery);

          if (videoData) {
            await db.execute(
              `UPDATE Music 
               SET youtube_url = ?,
                   youtube_thumbnail = ?,
                   updated_at = NOW()
               WHERE id = ?`,
              [videoData.videoUrl, videoData.thumbnailUrl, song.id]
            );

            console.log(`✅ Updated YouTube URL for: ${song.title} - ${song.artist_name}`);
          } else {
            console.log(`❌ No suitable YouTube video found for: ${song.title}`);
          }

          // Delay để tránh rate limit của YouTube API
          await new Promise(resolve => setTimeout(resolve, 1000));

        } catch (error) {
          console.error(`❌ Error updating ${song.title}:`, error.message);
          continue;
        }
      }

      processedCount += songs.length;
      console.log(`Completed ${processedCount}/${totalSongs} songs`);
    }

    console.log('✨ Finished updating YouTube URLs');

  } catch (error) {
    console.error('Error in updateMusicSources:', error);
  }
}

export const startYouTubeSync = async () => {
  console.log('🎵 Starting YouTube URL sync...');
  await updateMusicSources();
  
  // Chạy lại mỗi 12 giờ
  setInterval(updateMusicSources, 12 * 60 * 60 * 1000);
};

export default updateMusicSources;

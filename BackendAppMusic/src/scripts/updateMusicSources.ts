import YouTube from 'youtube-sr';
import db from '../config/database.js';

const BATCH_SIZE = 50;

interface VideoData {
    videoId: string;
    videoUrl: string;
    thumbnailUrl: string;
}

interface Song {
    id: number;
    title: string;
    artist_id: number;
    artist_name: string;
}

async function searchYouTubeVideo(query: string): Promise<VideoData | null> {
    try {
        await new Promise(resolve => setTimeout(resolve, 1000 + Math.random() * 2000));

        const videos = await (YouTube as any).search(query, {
            limit: 1,
            type: 'video',
            safeSearch: true
        });

        if (videos && videos.length > 0) {
            const video = videos[0];
            return {
                videoId: video.id,
                videoUrl: `https://www.youtube.com/watch?v=${video.id}`,
                thumbnailUrl: video.thumbnail?.url || video.thumbnails?.[0]?.url || ''
            };
        }
        return null;
    } catch (error) {
        const err = error as Error;
        console.error('YouTube search error:', err.message);
        return null;
    }
}

async function getTotalSongsCount(): Promise<number> {
    const [result] = await db.execute(`
    SELECT COUNT(*) as total
    FROM Music m
    JOIN Artists a ON m.artist_id = a.id
    WHERE m.youtube_url IS NULL
  `);
    return result[0]?.total || 0;
}

async function updateMusicSources(): Promise<void> {
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
        LIMIT $1
      `, [BATCH_SIZE]);

            if (!songs || songs.length === 0) break;

            console.log(`Processing batch of ${songs.length} songs (${processedCount + 1} - ${processedCount + songs.length} of ${totalSongs})`);

            for (const song of songs as Song[]) {
                try {
                    const searchQuery = `${song.title} ${song.artist_name} official audio`;
                    console.log(`🔍 Searching YouTube for: ${searchQuery}`);

                    const videoData = await searchYouTubeVideo(searchQuery);

                    if (videoData) {
                        await db.execute(
                            `UPDATE Music
               SET youtube_url = $1,
                   youtube_thumbnail = $2,
                   updated_at = NOW()
               WHERE id = $3`,
                            [videoData.videoUrl, videoData.thumbnailUrl, song.id]
                        );

                        console.log(`✅ Updated YouTube URL for: ${song.title} - ${song.artist_name}`);
                    } else {
                        console.log(`❌ No suitable YouTube video found for: ${song.title}`);
                    }

                    // Delay để tránh rate limit của YouTube API
                    await new Promise(resolve => setTimeout(resolve, 1000));

                } catch (error) {
                    const err = error as Error;
                    console.error(`❌ Error updating ${song.title}:`, err.message);
                    continue;
                }
            }

            processedCount += songs.length;
            console.log(`Completed ${processedCount}/${totalSongs} songs`);
        }

        console.log('✨ Finished updating YouTube URLs');

    } catch (error) {
        const err = error as Error;
        console.error('Error in updateMusicSources:', err.message);
    }
}

export const startYouTubeSync = async (): Promise<void> => {
    console.log('🎵 Starting YouTube URL sync...');
    await updateMusicSources();

    // Chạy lại mỗi 12 giờ
    setInterval(updateMusicSources, 12 * 60 * 60 * 1000);
};

export default updateMusicSources;

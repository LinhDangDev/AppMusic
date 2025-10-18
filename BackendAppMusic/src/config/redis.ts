import db from '../config/database.js';
import Redis from 'ioredis';

interface MusicRecord {
    id: number;
    title: string;
    artist_id: number;
    artist_name: string;
    artist_image: string;
    favorite_count: number;
    play_count: number;
    youtube_url: string | null;
    youtube_thumbnail: string | null;
}

interface VideoData {
    videoId: string;
    videoUrl: string;
    thumbnailUrl: string;
}

const redis = new Redis({
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379'),
    password: process.env.REDIS_PASSWORD || undefined
});

class MusicService {
    async getAllMusic(limit: number = 20, offset: number = 0): Promise<MusicRecord[]> {
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
      LIMIT $1 OFFSET $2
    `, [limit, offset]);
        return rows as MusicRecord[];
    }

    async getMusicById(id: number): Promise<MusicRecord | null> {
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
      WHERE m.id = $1
    `, [id]);

        if (!rows || rows.length === 0) return null;

        const music = rows[0] as MusicRecord;

        // Nếu chưa có YouTube URL, tìm và cập nhật
        if (!music.youtube_url) {
            const videoData = await this.searchYouTubeVideo(
                music.title,
                music.artist_name
            );

            if (videoData) {
                await this.updateYouTubeData(id, videoData);
                music.youtube_url = videoData.videoUrl;
                music.youtube_thumbnail = videoData.thumbnailUrl;
            }
        }

        return music;
    }

    async searchMusic(query: string): Promise<MusicRecord[]> {
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
      WHERE m.title ILIKE $1 OR a.name ILIKE $2
    `, [`%${query}%`, `%${query}%`]);
        return rows as MusicRecord[];
    }

    async searchYouTubeVideo(title: string, artistName: string): Promise<VideoData | null> {
        try {
            const searchQuery = `${title} ${artistName} official audio`;
            // Note: This is a placeholder for YouTube search logic
            // In production, you'd use youtube-sr or official YouTube API
            console.log(`Searching YouTube for: ${searchQuery}`);
            return null;
        } catch (error) {
            console.error('YouTube search error:', error);
            return null;
        }
    }

    async updateYouTubeData(musicId: number, videoData: VideoData): Promise<void> {
        await db.execute(
            `UPDATE Music
       SET youtube_url = $1,
           youtube_thumbnail = $2,
           updated_at = NOW()
       WHERE id = $3`,
            [videoData.videoUrl, videoData.thumbnailUrl, musicId]
        );
    }
}

export default new MusicService();

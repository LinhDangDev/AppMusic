import { PoolWithExecute } from '../config/database';
import { Music, MusicGenre } from '../types/database.types';
import { createError } from '../utils/error';
import db from '../config/database';
import lyricsService from './lyricsService';

/**
 * Music search result interface
 */
interface MusicSearchResult {
    items: Music[];
    total: number;
    limit: number;
    offset: number;
}

/**
 * YouTube video metadata
 */
interface YouTubeVideoMetadata {
    id: string;
    title: string;
    channel?: { name: string };
    duration: number;
    thumbnail?: { url: string };
    views?: number;
    description?: string;
    uploadedAt?: string;
}

/**
 * Genre rule mapping
 */
interface GenreRules {
    [key: string]: string[];
}

/**
 * Music Service - Handles music catalog operations, search, and recommendations
 * Integrates database queries, YouTube search, and lyrics service
 */
class MusicService {
    private db: PoolWithExecute = db;

    /**
     * Get all music with pagination and sorting
     */
    async getAllMusic(limit: number = 20, offset: number = 0, sort: string = 'newest'): Promise<MusicSearchResult> {
        try {
            const limitNum = Math.max(1, Math.min(Number(limit) || 20, 100));
            const offsetNum = Math.max(0, Number(offset) || 0);

            const orderBy = sort === 'popular' ? 'play_count DESC' : 'created_at DESC';

            const [result]: any = await this.db.execute(
                `SELECT
          m.id,
          m.title,
          m.artist_id,
          m.album,
          m.duration,
          m.release_date,
          m.youtube_thumbnail,
          m.youtube_id,
          m.youtube_url,
          m.image_url,
          m.preview_url,
          m.source,
          m.source_id,
          m.play_count,
          m.lyrics,
          m.genius_id,
          m.lyrics_state,
          m.created_at,
          m.updated_at,
          a.name as artist_name,
          a.image_url as artist_image,
          (SELECT COUNT(*) FROM favorites f WHERE f.music_id = m.id) as favorite_count,
          string_agg(DISTINCT g.name, ',') as genres,
          (SELECT COALESCE(SUM(play_duration), 0) FROM play_history WHERE music_id = m.id) as total_play_duration
        FROM music m
        LEFT JOIN artists a ON m.artist_id = a.id
        LEFT JOIN music_genres mg ON m.id = mg.music_id
        LEFT JOIN genres g ON mg.genre_id = g.id
        GROUP BY m.id, a.id, a.name, a.image_url
        ORDER BY ${orderBy}
        LIMIT $1 OFFSET $2`,
                [limitNum, offsetNum]
            );

            // Get total count
            const [totalResult]: any = await this.db.execute(
                'SELECT COUNT(*) as total FROM music',
                []
            );

            const formatted = result.map((row: any) => this.mapRowToMusic(row));

            return {
                items: formatted,
                total: parseInt(totalResult[0].total) || 0,
                limit: limitNum,
                offset: offsetNum
            };
        } catch (error) {
            console.error('Error getting all music:', error);
            throw error;
        }
    }

    /**
     * Get music by ID with full details
     */
    async getMusicById(id: number): Promise<Music | null> {
        try {
            const [result]: any = await this.db.execute(
                `SELECT
          m.id,
          m.title,
          m.artist_id,
          m.album,
          m.duration,
          m.release_date,
          m.youtube_thumbnail,
          m.youtube_id,
          m.youtube_url,
          m.image_url,
          m.preview_url,
          m.source,
          m.source_id,
          m.play_count,
          m.lyrics,
          m.genius_id,
          m.lyrics_state,
          m.created_at,
          m.updated_at,
          a.name as artist_name,
          a.image_url as artist_image,
          (SELECT COUNT(*) FROM favorites f WHERE f.music_id = m.id) as favorite_count
        FROM music m
        LEFT JOIN artists a ON m.artist_id = a.id
        WHERE m.id = $1`,
                [id]
            );

            if (!result || result.length === 0) {
                return null;
            }

            const music = this.mapRowToMusic(result[0]);

            // Auto-fetch lyrics if pending
            if (!music.lyrics && music.lyrics_state === 'PENDING') {
                // Note: Lyrics update is handled separately, here we just skip for now
                return music;
            }

            return music;
        } catch (error) {
            console.error('Error getting music by id:', error);
            throw error;
        }
    }

    /**
     * Search music in database
     */
    async searchDatabase(query: string, limit: number = 20): Promise<Music[]> {
        try {
            const searchQuery = `%${query}%`;

            const [result]: any = await this.db.execute(
                `SELECT
          m.id,
          m.title,
          m.artist_id,
          m.album,
          m.duration,
          m.release_date,
          m.youtube_thumbnail,
          m.youtube_id,
          m.youtube_url,
          m.image_url,
          m.preview_url,
          m.source,
          m.source_id,
          m.play_count,
          m.lyrics,
          m.genius_id,
          m.lyrics_state,
          m.created_at,
          m.updated_at,
          a.name as artist_name,
          a.image_url as artist_image,
          (SELECT COUNT(*) FROM favorites f WHERE f.music_id = m.id) as favorite_count
        FROM music m
        LEFT JOIN artists a ON m.artist_id = a.id
        WHERE m.title ILIKE $1 OR a.name ILIKE $2
        ORDER BY m.play_count DESC
        LIMIT $3`,
                [searchQuery, searchQuery, limit]
            );

            return result.map((row: any) => this.mapRowToMusic(row));
        } catch (error) {
            console.error('Database search error:', error);
            return [];
        }
    }

    /**
     * Get music by artist
     */
    async getMusicByArtist(artistId: number, limit: number = 20): Promise<Music[]> {
        try {
            const [result]: any = await this.db.execute(
                `SELECT
          m.id,
          m.title,
          m.artist_id,
          m.album,
          m.duration,
          m.release_date,
          m.youtube_thumbnail,
          m.youtube_id,
          m.youtube_url,
          m.image_url,
          m.preview_url,
          m.source,
          m.source_id,
          m.play_count,
          m.lyrics,
          m.genius_id,
          m.lyrics_state,
          m.created_at,
          m.updated_at,
          a.name as artist_name,
          a.image_url as artist_image,
          (SELECT COUNT(*) FROM favorites f WHERE f.music_id = m.id) as favorite_count
        FROM music m
        LEFT JOIN artists a ON m.artist_id = a.id
        WHERE m.artist_id = $1
        ORDER BY m.release_date DESC
        LIMIT $2`,
                [artistId, limit]
            );

            return result.map((row: any) => this.mapRowToMusic(row));
        } catch (error) {
            console.error('Error getting music by artist:', error);
            return [];
        }
    }

    /**
     * Get music by genres (multi-genre filtering)
     */
    async getMusicByGenres(genreIds: number[], limit: number = 20): Promise<Music[]> {
        try {
            if (genreIds.length === 0) {
                return [];
            }

            const [result]: any = await this.db.execute(
                `SELECT DISTINCT
          m.id,
          m.title,
          m.artist_id,
          m.album,
          m.duration,
          m.release_date,
          m.youtube_thumbnail,
          m.youtube_id,
          m.youtube_url,
          m.image_url,
          m.preview_url,
          m.source,
          m.source_id,
          m.play_count,
          m.lyrics,
          m.genius_id,
          m.lyrics_state,
          m.created_at,
          m.updated_at,
          a.name as artist_name,
          a.image_url as artist_image,
          (SELECT COUNT(*) FROM favorites f WHERE f.music_id = m.id) as favorite_count
        FROM music m
        LEFT JOIN artists a ON m.artist_id = a.id
        LEFT JOIN music_genres mg ON m.id = mg.music_id
        WHERE mg.genre_id = ANY($1)
        ORDER BY m.play_count DESC
        LIMIT $2`,
                [genreIds, limit]
            );

            return result.map((row: any) => this.mapRowToMusic(row));
        } catch (error) {
            console.error('Error getting music by genres:', error);
            return [];
        }
    }

    /**
     * Update play count for a music
     */
    async updatePlayCount(musicId: number, increment: number = 1): Promise<void> {
        try {
            await this.db.execute(
                `UPDATE music
         SET play_count = play_count + $1, updated_at = NOW()
         WHERE id = $2`,
                [increment, musicId]
            );
        } catch (error) {
            console.error('Error updating play count:', error);
            throw error;
        }
    }

    /**
     * Get top music by play count
     */
    async getTopMusic(limit: number = 10): Promise<Music[]> {
        try {
            const [result]: any = await this.db.execute(
                `SELECT
          m.id,
          m.title,
          m.artist_id,
          m.album,
          m.duration,
          m.release_date,
          m.youtube_thumbnail,
          m.youtube_id,
          m.youtube_url,
          m.image_url,
          m.preview_url,
          m.source,
          m.source_id,
          m.play_count,
          m.lyrics,
          m.genius_id,
          m.lyrics_state,
          m.created_at,
          m.updated_at,
          a.name as artist_name,
          a.image_url as artist_image,
          (SELECT COUNT(*) FROM favorites f WHERE f.music_id = m.id) as favorite_count
        FROM music m
        LEFT JOIN artists a ON m.artist_id = a.id
        WHERE m.youtube_url IS NOT NULL
        ORDER BY m.play_count DESC
        LIMIT $1`,
                [limit]
            );

            return result.map((row: any) => this.mapRowToMusic(row));
        } catch (error) {
            console.error('Error getting top music:', error);
            return [];
        }
    }

    /**
     * Get random music (for recommendations)
     */
    async getRandomMusic(limit: number = 10): Promise<Music[]> {
        try {
            const [result]: any = await this.db.execute(
                `SELECT
          m.id,
          m.title,
          m.artist_id,
          m.album,
          m.duration,
          m.release_date,
          m.youtube_thumbnail,
          m.youtube_id,
          m.youtube_url,
          m.image_url,
          m.preview_url,
          m.source,
          m.source_id,
          m.play_count,
          m.lyrics,
          m.genius_id,
          m.lyrics_state,
          m.created_at,
          m.updated_at,
          a.name as artist_name,
          a.image_url as artist_image,
          string_agg(DISTINCT g.name, ',') as genres,
          (SELECT COUNT(*) FROM favorites f WHERE f.music_id = m.id) as favorite_count
        FROM music m
        LEFT JOIN artists a ON m.artist_id = a.id
        LEFT JOIN music_genres mg ON m.id = mg.music_id
        LEFT JOIN genres g ON mg.genre_id = g.id
        WHERE m.youtube_url IS NOT NULL AND m.youtube_thumbnail IS NOT NULL
        GROUP BY m.id, a.id, a.name, a.image_url
        ORDER BY RANDOM()
        LIMIT $1`,
                [limit]
            );

            return result.map((row: any) => this.mapRowToMusic(row));
        } catch (error) {
            console.error('Error getting random music:', error);
            return [];
        }
    }

    /**
     * Classify genres based on title and artist name
     */
    private async classifyGenres(title: string = '', artist: string = ''): Promise<any[]> {
        try {
            const text = `${title} ${artist}`.toLowerCase();
            const genreRules: GenreRules = {
                'Romance': ['love', 'heart', 'romantic', 'yêu', 'tình yêu', 'valentine'],
                'Sad': ['sad', 'buồn', 'lonely', 'alone', 'cry', 'khóc', 'nước mắt'],
                'Party': ['party', 'dance', 'club', 'remix', 'edm'],
                'K-Pop': ['k-pop', 'kpop', 'korean', 'korea', 'bts', 'blackpink'],
                'Hip-Hop': ['rap', 'hip hop', 'hip-hop', 'trap'],
                'Chill': ['chill', 'relax', 'acoustic'],
                'Pop': ['pop', 'nhạc trẻ'],
                'Dance & Electronic': ['edm', 'electronic', 'dance'],
                'Indie & Alternative': ['indie', 'alternative'],
                'R&B & Soul': ['r&b', 'soul', 'rhythm and blues']
            };

            const matchedGenres: string[] = [];

            // Find matching genres
            for (const [genre, keywords] of Object.entries(genreRules)) {
                if (keywords.some(keyword => text.includes(keyword))) {
                    matchedGenres.push(genre);
                }
            }

            // Default to Pop if no match
            if (matchedGenres.length === 0) {
                matchedGenres.push('Pop');
            }

            // Get genre IDs from database
            const [genreRows]: any = await this.db.execute(
                `SELECT id, name FROM genres WHERE name = ANY($1)`,
                [matchedGenres]
            );

            return genreRows;
        } catch (error) {
            console.error('Error classifying genres:', error);
            return [];
        }
    }

    /**
     * Search on YouTube (stub - requires youtube-sr package)
     */
    async searchYouTube(query: string, limit: number = 10): Promise<any[]> {
        try {
            // NOTE: This requires the youtube-sr package which needs to be installed
            console.log(`YouTube search for: "${query}" (limit: ${limit})`);
            // Return empty for now - would integrate youtube-sr here
            return [];
        } catch (error) {
            console.error('YouTube search error:', error);
            return [];
        }
    }

    /**
     * Combined search across database and external sources
     */
    async searchAll(query: string, limit: number = 20): Promise<Music[]> {
        try {
            // Search database
            const dbResults = await this.searchDatabase(query, Math.floor(limit / 2));

            // Search YouTube (would be integrated)
            const youtubeResults = await this.searchYouTube(query, Math.ceil(limit / 2));

            // Combine results (prioritize database, then add YouTube)
            const combinedResults = [...dbResults, ...youtubeResults];

            // Sort by play count descending
            combinedResults.sort((a: any, b: any) => (b.play_count || 0) - (a.play_count || 0));

            return combinedResults.slice(0, limit);
        } catch (error) {
            console.error('Search error:', error);
            return [];
        }
    }

    // ============================================
    // PRIVATE MAPPING METHOD
    // ============================================

    /**
     * Map database row to Music interface
     */
    private mapRowToMusic(row: any): Music {
        return {
            id: row.id,
            title: row.title,
            artist_id: row.artist_id,
            album: row.album,
            duration: row.duration,
            release_date: row.release_date ? new Date(row.release_date) : undefined,
            youtube_thumbnail: row.youtube_thumbnail,
            youtube_id: row.youtube_id,
            youtube_url: row.youtube_url,
            image_url: row.image_url,
            preview_url: row.preview_url,
            source: row.source,
            source_id: row.source_id,
            play_count: row.play_count || 0,
            lyrics: row.lyrics,
            genius_id: row.genius_id,
            lyrics_state: row.lyrics_state,
            created_at: new Date(row.created_at),
            updated_at: new Date(row.updated_at)
        };
    }
}

export default new MusicService();

import { Pool } from 'pg';
import {
    Favorite,
    Music,
    ErrorCode,
    PaginationInfo,
} from '../types/api.types';

export class FavoriteService {
    private pool: Pool;

    constructor(pool: Pool) {
        this.pool = pool;
    }

    /**
     * Get user's favorite songs with pagination
     */
    async getFavorites(
        userId: number,
        page: number = 1,
        limit: number = 20
    ): Promise<{ data: Music.MusicResponse[]; pagination: PaginationInfo }> {
        // Validate pagination
        if (page < 1) page = 1;
        if (limit < 1) limit = 1;
        if (limit > 100) limit = 100;

        const offset = (page - 1) * limit;

        // Get total count
        const countResult = await this.pool.query(
            'SELECT COUNT(*) as count FROM favorites WHERE user_id = $1',
            [userId]
        );

        const total = parseInt(countResult.rows[0].count);
        const totalPages = Math.ceil(total / limit);

        // Get favorites
        const result = await this.pool.query(
            `SELECT
        m.id, m.title, m.artist_id, a.name as artist_name, m.album,
        m.duration, m.release_date, m.youtube_id, m.image_url,
        m.play_count, m.created_at, f.created_at as favorited_at
       FROM favorites f
       JOIN music m ON f.music_id = m.id
       LEFT JOIN artists a ON m.artist_id = a.id
       WHERE f.user_id = $1
       ORDER BY f.created_at DESC
       LIMIT $2 OFFSET $3`,
            [userId, limit, offset]
        );

        return {
            data: result.rows.map((row) => ({
                id: row.id,
                title: row.title,
                artist_id: row.artist_id,
                artist_name: row.artist_name || 'Unknown Artist',
                album: row.album,
                duration: row.duration,
                release_date: row.release_date,
                youtube_id: row.youtube_id,
                image_url: row.image_url,
                play_count: row.play_count,
                created_at: row.created_at,
            })),
            pagination: {
                page,
                limit,
                total,
                total_pages: totalPages,
            },
        };
    }

    /**
     * Add song to favorites
     */
    async addFavorite(userId: number, musicId: number): Promise<void> {
        // Verify music exists
        const musicResult = await this.pool.query('SELECT id FROM music WHERE id = $1', [musicId]);

        if (musicResult.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'Music not found',
                statusCode: 404,
            };
        }

        // Add to favorites
        try {
            await this.pool.query(
                'INSERT INTO favorites (user_id, music_id) VALUES ($1, $2)',
                [userId, musicId]
            );
        } catch (error: any) {
            if (error.code === '23505') {
                // Unique constraint violation
                throw {
                    code: ErrorCode.CONFLICT,
                    message: 'Song already in favorites',
                    statusCode: 409,
                };
            }
            throw error;
        }
    }

    /**
     * Remove song from favorites
     */
    async removeFavorite(userId: number, musicId: number): Promise<void> {
        const result = await this.pool.query(
            'DELETE FROM favorites WHERE user_id = $1 AND music_id = $2 RETURNING id',
            [userId, musicId]
        );

        if (result.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'Favorite not found',
                statusCode: 404,
            };
        }
    }

    /**
     * Check if song is favorited
     */
    async isFavorited(userId: number, musicId: number): Promise<boolean> {
        const result = await this.pool.query(
            'SELECT id FROM favorites WHERE user_id = $1 AND music_id = $2 LIMIT 1',
            [userId, musicId]
        );

        return result.rows.length > 0;
    }

    /**
     * Get favorite count for a song
     */
    async getFavoriteCount(musicId: number): Promise<number> {
        const result = await this.pool.query(
            'SELECT COUNT(*) as count FROM favorites WHERE music_id = $1',
            [musicId]
        );

        return parseInt(result.rows[0].count);
    }

    /**
     * Get favorite count for user
     */
    async getUserFavoriteCount(userId: number): Promise<number> {
        const result = await this.pool.query(
            'SELECT COUNT(*) as count FROM favorites WHERE user_id = $1',
            [userId]
        );

        return parseInt(result.rows[0].count);
    }

    /**
     * Get most favorited songs
     */
    async getMostFavoritedSongs(limit: number = 50): Promise<Music.MusicResponse[]> {
        if (limit > 1000) limit = 1000;

        const result = await this.pool.query(
            `SELECT
        m.id, m.title, m.artist_id, a.name as artist_name, m.album,
        m.duration, m.release_date, m.youtube_id, m.image_url,
        m.play_count, m.created_at,
        COUNT(f.id) as favorite_count
       FROM music m
       LEFT JOIN favorites f ON m.id = f.music_id
       LEFT JOIN artists a ON m.artist_id = a.id
       GROUP BY m.id, a.id
       ORDER BY favorite_count DESC
       LIMIT $1`,
            [limit]
        );

        return result.rows.map((row) => ({
            id: row.id,
            title: row.title,
            artist_id: row.artist_id,
            artist_name: row.artist_name || 'Unknown Artist',
            album: row.album,
            duration: row.duration,
            release_date: row.release_date,
            youtube_id: row.youtube_id,
            image_url: row.image_url,
            play_count: row.play_count,
            created_at: row.created_at,
        }));
    }

    /**
     * Get user favorite statistics
     */
    async getUserFavoriteStats(userId: number): Promise<{
        total_favorites: number;
        favorite_artists: { artist_id: number; artist_name: string; count: number }[];
        favorite_genres: { genre_id: number; genre_name: string; count: number }[];
    }> {
        // Get total favorites
        const totalResult = await this.pool.query(
            'SELECT COUNT(*) as count FROM favorites WHERE user_id = $1',
            [userId]
        );

        const totalFavorites = parseInt(totalResult.rows[0].count);

        // Get favorite artists
        const artistsResult = await this.pool.query(
            `SELECT
        a.id as artist_id, a.name as artist_name,
        COUNT(*) as count
       FROM favorites f
       JOIN music m ON f.music_id = m.id
       JOIN artists a ON m.artist_id = a.id
       WHERE f.user_id = $1
       GROUP BY a.id, a.name
       ORDER BY count DESC
       LIMIT 10`,
            [userId]
        );

        // Get favorite genres
        const genresResult = await this.pool.query(
            `SELECT
        g.id as genre_id, g.name as genre_name,
        COUNT(*) as count
       FROM favorites f
       JOIN music m ON f.music_id = m.id
       JOIN music_genres mg ON m.id = mg.music_id
       JOIN genres g ON mg.genre_id = g.id
       WHERE f.user_id = $1
       GROUP BY g.id, g.name
       ORDER BY count DESC
       LIMIT 10`,
            [userId]
        );

        return {
            total_favorites: totalFavorites,
            favorite_artists: artistsResult.rows.map((row) => ({
                artist_id: row.artist_id,
                artist_name: row.artist_name,
                count: parseInt(row.count),
            })),
            favorite_genres: genresResult.rows.map((row) => ({
                genre_id: row.genre_id,
                genre_name: row.genre_name,
                count: parseInt(row.count),
            })),
        };
    }

    /**
     * Batch check if songs are favorited
     */
    async areFavorited(userId: number, musicIds: number[]): Promise<Map<number, boolean>> {
        if (musicIds.length === 0) {
            return new Map();
        }

        const result = await this.pool.query(
            'SELECT DISTINCT music_id FROM favorites WHERE user_id = $1 AND music_id = ANY($2)',
            [userId, musicIds]
        );

        const favoritedIds = new Set(result.rows.map((row) => row.music_id));

        const map = new Map<number, boolean>();
        musicIds.forEach((id) => {
            map.set(id, favoritedIds.has(id));
        });

        return map;
    }

    /**
     * Clear all favorites for a user
     */
    async clearFavorites(userId: number): Promise<void> {
        await this.pool.query('DELETE FROM favorites WHERE user_id = $1', [userId]);
    }
}

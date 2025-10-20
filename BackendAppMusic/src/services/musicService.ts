import { Pool } from 'pg';
import {
    Music,
    ErrorCode,
    PaginationInfo,
    DatabaseMusic,
} from '../types/api.types';

export class MusicService {
    private pool: Pool;

    constructor(pool: Pool) {
        this.pool = pool;
    }

    /**
     * Get paginated list of music with optional filtering
     */
    async getMusic(
        page: number = 1,
        limit: number = 20,
        sort: string = 'created_at',
        order: 'asc' | 'desc' = 'desc',
        genreId?: number,
        artistId?: number
    ): Promise<{ data: Music.MusicResponse[]; pagination: PaginationInfo }> {
        // Validate pagination
        if (page < 1) page = 1;
        if (limit < 1) limit = 1;
        if (limit > 100) limit = 100;

        // Validate sort field
        const allowedSorts = ['created_at', 'play_count', 'title'];
        if (!allowedSorts.includes(sort)) {
            sort = 'created_at';
        }

        // Validate order
        if (!['asc', 'desc'].includes(order)) {
            order = 'desc';
        }

        const offset = (page - 1) * limit;

        // Build query
        let whereConditions: string[] = [];
        const params: any[] = [];
        let paramCount = 1;

        if (genreId) {
            whereConditions.push(
                `m.id IN (SELECT music_id FROM music_genres WHERE genre_id = $${paramCount})`
            );
            params.push(genreId);
            paramCount++;
        }

        if (artistId) {
            whereConditions.push(`m.artist_id = $${paramCount}`);
            params.push(artistId);
            paramCount++;
        }

        const whereClause = whereConditions.length > 0 ? `WHERE ${whereConditions.join(' AND ')}` : '';

        // Get total count
        const countQuery = `SELECT COUNT(*) as count FROM music m ${whereClause}`;
        const countResult = await this.pool.query(countQuery, params);
        const total = parseInt(countResult.rows[0].count);
        const totalPages = Math.ceil(total / limit);

        // Get data
        params.push(limit, offset);
        const dataQuery = `
      SELECT
        m.id, m.title, m.artist_id, a.name as artist_name, m.album,
        m.duration, m.release_date, m.youtube_id, m.image_url,
        m.play_count, m.created_at
      FROM music m
      LEFT JOIN artists a ON m.artist_id = a.id
      ${whereClause}
      ORDER BY m.${sort} ${order.toUpperCase()}
      LIMIT $${paramCount} OFFSET $${paramCount + 1}
    `;

        const result = await this.pool.query(dataQuery, params);

        return {
            data: result.rows.map((row) => this.mapRowToMusicResponse(row)),
            pagination: {
                page,
                limit,
                total,
                total_pages: totalPages,
            },
        };
    }

    /**
     * Get single music by ID
     */
    async getMusicById(musicId: number): Promise<Music.MusicResponse> {
        const result = await this.pool.query(
            `SELECT
        m.id, m.title, m.artist_id, a.name as artist_name, m.album,
        m.duration, m.release_date, m.youtube_id, m.image_url,
        m.play_count, m.created_at
       FROM music m
       LEFT JOIN artists a ON m.artist_id = a.id
       WHERE m.id = $1`,
            [musicId]
        );

        if (result.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'Music not found',
                statusCode: 404,
            };
        }

        return this.mapRowToMusicResponse(result.rows[0]);
    }

    /**
     * Search music by title, artist, or album
     */
    async searchMusic(
        query: string,
        limit: number = 20,
        searchType?: 'title' | 'artist' | 'album'
    ): Promise<{ results: Music.MusicResponse[]; total: number }> {
        if (!query || query.trim().length === 0) {
            throw {
                code: ErrorCode.VALIDATION_ERROR,
                message: 'Search query cannot be empty',
                statusCode: 400,
            };
        }

        if (limit > 100) limit = 100;

        const searchQuery = `%${query}%`;
        let sqlQuery: string;
        const params: any[] = [searchQuery];

        if (searchType === 'title') {
            sqlQuery = `
        SELECT
          m.id, m.title, m.artist_id, a.name as artist_name, m.album,
          m.duration, m.release_date, m.youtube_id, m.image_url,
          m.play_count, m.created_at
        FROM music m
        LEFT JOIN artists a ON m.artist_id = a.id
        WHERE LOWER(m.title) LIKE LOWER($1)
        ORDER BY m.play_count DESC
        LIMIT $2
      `;
            params.push(limit);
        } else if (searchType === 'artist') {
            sqlQuery = `
        SELECT
          m.id, m.title, m.artist_id, a.name as artist_name, m.album,
          m.duration, m.release_date, m.youtube_id, m.image_url,
          m.play_count, m.created_at
        FROM music m
        LEFT JOIN artists a ON m.artist_id = a.id
        WHERE LOWER(a.name) LIKE LOWER($1)
        ORDER BY m.play_count DESC
        LIMIT $2
      `;
            params.push(limit);
        } else if (searchType === 'album') {
            sqlQuery = `
        SELECT
          m.id, m.title, m.artist_id, a.name as artist_name, m.album,
          m.duration, m.release_date, m.youtube_id, m.image_url,
          m.play_count, m.created_at
        FROM music m
        LEFT JOIN artists a ON m.artist_id = a.id
        WHERE LOWER(m.album) LIKE LOWER($1)
        ORDER BY m.play_count DESC
        LIMIT $2
      `;
            params.push(limit);
        } else {
            // Full-text search across all fields
            sqlQuery = `
        SELECT
          m.id, m.title, m.artist_id, a.name as artist_name, m.album,
          m.duration, m.release_date, m.youtube_id, m.image_url,
          m.play_count, m.created_at
        FROM music m
        LEFT JOIN artists a ON m.artist_id = a.id
        WHERE LOWER(m.title) LIKE LOWER($1)
          OR LOWER(a.name) LIKE LOWER($1)
          OR LOWER(m.album) LIKE LOWER($1)
        ORDER BY m.play_count DESC
        LIMIT $2
      `;
            params.push(limit);
        }

        const result = await this.pool.query(sqlQuery, params);

        // Get total count
        let countQuery: string;
        if (searchType === 'title') {
            countQuery = `SELECT COUNT(*) as count FROM music WHERE LOWER(title) LIKE LOWER($1)`;
        } else if (searchType === 'artist') {
            countQuery = `SELECT COUNT(*) as count FROM music m JOIN artists a ON m.artist_id = a.id WHERE LOWER(a.name) LIKE LOWER($1)`;
        } else if (searchType === 'album') {
            countQuery = `SELECT COUNT(*) as count FROM music WHERE LOWER(album) LIKE LOWER($1)`;
        } else {
            countQuery = `
        SELECT COUNT(*) as count FROM music m
        LEFT JOIN artists a ON m.artist_id = a.id
        WHERE LOWER(m.title) LIKE LOWER($1)
          OR LOWER(a.name) LIKE LOWER($1)
          OR LOWER(m.album) LIKE LOWER($1)
      `;
        }

        const countResult = await this.pool.query(countQuery, [searchQuery]);
        const total = parseInt(countResult.rows[0].count);

        return {
            results: result.rows.map((row) => this.mapRowToMusicResponse(row)),
            total,
        };
    }

    /**
     * Create new music (admin only)
     */
    async createMusic(payload: Music.CreateMusicRequest): Promise<Music.MusicResponse> {
        // Validate required fields
        if (!payload.title || payload.title.trim().length === 0) {
            throw {
                code: ErrorCode.VALIDATION_ERROR,
                message: 'Title is required',
                statusCode: 400,
            };
        }

        if (!payload.artist_id) {
            throw {
                code: ErrorCode.VALIDATION_ERROR,
                message: 'Artist ID is required',
                statusCode: 400,
            };
        }

        if (!payload.duration || payload.duration < 0) {
            throw {
                code: ErrorCode.VALIDATION_ERROR,
                message: 'Duration must be a positive number',
                statusCode: 400,
            };
        }

        // Verify artist exists
        const artistResult = await this.pool.query('SELECT id FROM artists WHERE id = $1', [
            payload.artist_id,
        ]);

        if (artistResult.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'Artist not found',
                statusCode: 404,
            };
        }

        // Insert music
        const result = await this.pool.query(
            `INSERT INTO music (title, artist_id, album, duration, release_date, youtube_id, image_url)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, title, artist_id, album, duration, release_date, youtube_id, image_url, play_count, created_at`,
            [
                payload.title,
                payload.artist_id,
                payload.album || null,
                payload.duration,
                payload.release_date || null,
                payload.youtube_id || null,
                payload.image_url || null,
            ]
        );

        const music = result.rows[0];

        // Get artist name
        const artistNameResult = await this.pool.query('SELECT name FROM artists WHERE id = $1', [
            payload.artist_id,
        ]);

        return {
            id: music.id,
            title: music.title,
            artist_id: music.artist_id,
            artist_name: artistNameResult.rows[0].name,
            album: music.album,
            duration: music.duration,
            release_date: music.release_date,
            youtube_id: music.youtube_id,
            image_url: music.image_url,
            play_count: music.play_count,
            created_at: music.created_at,
        };
    }

    /**
     * Update music (admin only)
     */
    async updateMusic(
        musicId: number,
        payload: Music.UpdateMusicRequest
    ): Promise<Music.MusicResponse> {
        // Verify music exists
        const musicResult = await this.pool.query('SELECT * FROM music WHERE id = $1', [musicId]);

        if (musicResult.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'Music not found',
                statusCode: 404,
            };
        }

        // Build update query
        const updates: string[] = [];
        const values: any[] = [];
        let paramCount = 1;

        if (payload.title) {
            updates.push(`title = $${paramCount}`);
            values.push(payload.title);
            paramCount++;
        }

        if (payload.album !== undefined) {
            updates.push(`album = $${paramCount}`);
            values.push(payload.album || null);
            paramCount++;
        }

        if (payload.duration !== undefined) {
            updates.push(`duration = $${paramCount}`);
            values.push(payload.duration);
            paramCount++;
        }

        if (payload.release_date !== undefined) {
            updates.push(`release_date = $${paramCount}`);
            values.push(payload.release_date || null);
            paramCount++;
        }

        if (payload.image_url !== undefined) {
            updates.push(`image_url = $${paramCount}`);
            values.push(payload.image_url || null);
            paramCount++;
        }

        if (updates.length === 0) {
            return this.getMusicById(musicId);
        }

        updates.push(`updated_at = NOW()`);
        values.push(musicId);

        const query = `
      UPDATE music
      SET ${updates.join(', ')}
      WHERE id = $${paramCount}
      RETURNING id, title, artist_id, album, duration, release_date, youtube_id, image_url, play_count, created_at
    `;

        const updateResult = await this.pool.query(query, values);
        const music = updateResult.rows[0];

        // Get artist name
        const artistResult = await this.pool.query('SELECT name FROM artists WHERE id = $1', [
            music.artist_id,
        ]);

        return {
            id: music.id,
            title: music.title,
            artist_id: music.artist_id,
            artist_name: artistResult.rows[0].name,
            album: music.album,
            duration: music.duration,
            release_date: music.release_date,
            youtube_id: music.youtube_id,
            image_url: music.image_url,
            play_count: music.play_count,
            created_at: music.created_at,
        };
    }

    /**
     * Delete music (admin only)
     */
    async deleteMusic(musicId: number): Promise<void> {
        const result = await this.pool.query('DELETE FROM music WHERE id = $1 RETURNING id', [
            musicId,
        ]);

        if (result.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'Music not found',
                statusCode: 404,
            };
        }
    }

    /**
     * Increment play count
     */
    async incrementPlayCount(musicId: number): Promise<void> {
        const result = await this.pool.query(
            'UPDATE music SET play_count = play_count + 1 WHERE id = $1 RETURNING id',
            [musicId]
        );

        if (result.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'Music not found',
                statusCode: 404,
            };
        }
    }

    /**
     * Get top music by play count
     */
    async getTopMusic(limit: number = 50): Promise<Music.MusicResponse[]> {
        if (limit > 1000) limit = 1000;

        const result = await this.pool.query(
            `SELECT
        m.id, m.title, m.artist_id, a.name as artist_name, m.album,
        m.duration, m.release_date, m.youtube_id, m.image_url,
        m.play_count, m.created_at
       FROM music m
       LEFT JOIN artists a ON m.artist_id = a.id
       ORDER BY m.play_count DESC
       LIMIT $1`,
            [limit]
        );

        return result.rows.map((row) => this.mapRowToMusicResponse(row));
    }

    /**
     * Get total music count
     */
    async getTotalMusicCount(): Promise<number> {
        const result = await this.pool.query('SELECT COUNT(*) as count FROM music');
        return parseInt(result.rows[0].count);
    }

    /**
     * Get music by genre
     */
    async getMusicByGenre(genreId: number, limit: number = 20): Promise<Music.MusicResponse[]> {
        const result = await this.pool.query(
            `SELECT
        m.id, m.title, m.artist_id, a.name as artist_name, m.album,
        m.duration, m.release_date, m.youtube_id, m.image_url,
        m.play_count, m.created_at
       FROM music m
       LEFT JOIN artists a ON m.artist_id = a.id
       JOIN music_genres mg ON m.id = mg.music_id
       WHERE mg.genre_id = $1
       ORDER BY m.play_count DESC
       LIMIT $2`,
            [genreId, limit]
        );

        return result.rows.map((row) => this.mapRowToMusicResponse(row));
    }

    /**
     * Helper: Map database row to MusicResponse
     */
    private mapRowToMusicResponse(row: any): Music.MusicResponse {
        return {
            id: row.id,
            title: row.title,
            artist_id: row.artist_id,
            artist_name: row.artist_name || 'Unknown Artist',
            album: row.album,
            duration: row.duration,
            release_date: row.release_date,
            youtube_id: row.youtube_id,
            image_url: row.image_url,
            play_count: row.play_count || 0,
            created_at: row.created_at,
        };
    }
}

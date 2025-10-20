import { Pool } from 'pg';
import {
    Playlist,
    Music,
    ErrorCode,
    DatabasePlaylist,
} from '../types/api.types';

export class PlaylistService {
    private pool: Pool;

    constructor(pool: Pool) {
        this.pool = pool;
    }

    /**
     * Get all playlists for a user
     */
    async getUserPlaylists(userId: number): Promise<Playlist.PlaylistResponse[]> {
        const result = await this.pool.query(
            `SELECT
        p.id, p.user_id, p.name, p.description, p.is_shared,
        COUNT(ps.music_id) as songs_count,
        p.created_at, p.updated_at
       FROM playlists p
       LEFT JOIN playlist_songs ps ON p.id = ps.playlist_id
       WHERE p.user_id = $1
       GROUP BY p.id, p.user_id, p.name, p.description, p.is_shared, p.created_at, p.updated_at
       ORDER BY p.created_at DESC`,
            [userId]
        );

        return result.rows.map((row) => this.mapRowToPlaylistResponse(row));
    }

    /**
     * Get single playlist by ID
     */
    async getPlaylistById(playlistId: number): Promise<Playlist.PlaylistDetailResponse> {
        // Get playlist info
        const playlistResult = await this.pool.query(
            `SELECT
        p.id, p.user_id, p.name, p.description, p.is_shared,
        COUNT(ps.music_id) as songs_count,
        p.created_at, p.updated_at
       FROM playlists p
       LEFT JOIN playlist_songs ps ON p.id = ps.playlist_id
       WHERE p.id = $1
       GROUP BY p.id, p.user_id, p.name, p.description, p.is_shared, p.created_at, p.updated_at`,
            [playlistId]
        );

        if (playlistResult.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'Playlist not found',
                statusCode: 404,
            };
        }

        const playlist = playlistResult.rows[0];

        // Get songs in playlist
        const songsResult = await this.pool.query(
            `SELECT
        m.id, m.title, m.artist_id, a.name as artist_name, m.album,
        m.duration, m.release_date, m.youtube_id, m.image_url,
        m.play_count, m.created_at,
        ps.position
       FROM playlist_songs ps
       JOIN music m ON ps.music_id = m.id
       LEFT JOIN artists a ON m.artist_id = a.id
       WHERE ps.playlist_id = $1
       ORDER BY ps.position ASC`,
            [playlistId]
        );

        return {
            id: playlist.id,
            user_id: playlist.user_id,
            name: playlist.name,
            description: playlist.description,
            is_shared: playlist.is_shared,
            songs_count: parseInt(playlist.songs_count),
            created_at: playlist.created_at,
            updated_at: playlist.updated_at,
            songs: songsResult.rows.map((row) => ({
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
        };
    }

    /**
     * Create new playlist
     */
    async createPlaylist(
        userId: number,
        payload: Playlist.CreatePlaylistRequest
    ): Promise<Playlist.PlaylistResponse> {
        // Validate name
        if (!payload.name || payload.name.trim().length === 0) {
            throw {
                code: ErrorCode.VALIDATION_ERROR,
                message: 'Playlist name is required',
                statusCode: 400,
            };
        }

        if (payload.name.length > 100) {
            throw {
                code: ErrorCode.VALIDATION_ERROR,
                message: 'Playlist name cannot exceed 100 characters',
                statusCode: 400,
            };
        }

        if (payload.description && payload.description.length > 500) {
            throw {
                code: ErrorCode.VALIDATION_ERROR,
                message: 'Description cannot exceed 500 characters',
                statusCode: 400,
            };
        }

        const result = await this.pool.query(
            `INSERT INTO playlists (user_id, name, description, is_shared)
       VALUES ($1, $2, $3, $4)
       RETURNING id, user_id, name, description, is_shared, created_at, updated_at`,
            [userId, payload.name, payload.description || null, payload.is_shared || false]
        );

        const playlist = result.rows[0];

        return {
            id: playlist.id,
            user_id: playlist.user_id,
            name: playlist.name,
            description: playlist.description,
            is_shared: playlist.is_shared,
            songs_count: 0,
            created_at: playlist.created_at,
            updated_at: playlist.updated_at,
        };
    }

    /**
     * Update playlist
     */
    async updatePlaylist(
        playlistId: number,
        userId: number,
        payload: Playlist.UpdatePlaylistRequest
    ): Promise<Playlist.PlaylistResponse> {
        // Verify ownership
        const ownershipResult = await this.pool.query(
            'SELECT user_id FROM playlists WHERE id = $1',
            [playlistId]
        );

        if (ownershipResult.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'Playlist not found',
                statusCode: 404,
            };
        }

        if (ownershipResult.rows[0].user_id !== userId) {
            throw {
                code: ErrorCode.FORBIDDEN,
                message: 'You do not have permission to update this playlist',
                statusCode: 403,
            };
        }

        // Build update query
        const updates: string[] = [];
        const values: any[] = [];
        let paramCount = 1;

        if (payload.name) {
            if (payload.name.length > 100) {
                throw {
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Playlist name cannot exceed 100 characters',
                    statusCode: 400,
                };
            }
            updates.push(`name = $${paramCount}`);
            values.push(payload.name);
            paramCount++;
        }

        if (payload.description !== undefined) {
            if (payload.description && payload.description.length > 500) {
                throw {
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Description cannot exceed 500 characters',
                    statusCode: 400,
                };
            }
            updates.push(`description = $${paramCount}`);
            values.push(payload.description || null);
            paramCount++;
        }

        if (payload.is_shared !== undefined) {
            updates.push(`is_shared = $${paramCount}`);
            values.push(payload.is_shared);
            paramCount++;
        }

        if (updates.length === 0) {
            // Return current playlist if no updates
            const currentResult = await this.pool.query(
                `SELECT
          p.id, p.user_id, p.name, p.description, p.is_shared,
          COUNT(ps.music_id) as songs_count,
          p.created_at, p.updated_at
         FROM playlists p
         LEFT JOIN playlist_songs ps ON p.id = ps.playlist_id
         WHERE p.id = $1
         GROUP BY p.id`,
                [playlistId]
            );

            const playlist = currentResult.rows[0];
            return this.mapRowToPlaylistResponse(playlist);
        }

        updates.push(`updated_at = NOW()`);
        values.push(playlistId);

        const query = `
      UPDATE playlists
      SET ${updates.join(', ')}
      WHERE id = $${paramCount}
      RETURNING id, user_id, name, description, is_shared, created_at, updated_at
    `;

        const result = await this.pool.query(query, values);
        const playlist = result.rows[0];

        // Get songs count
        const countResult = await this.pool.query(
            'SELECT COUNT(*) as count FROM playlist_songs WHERE playlist_id = $1',
            [playlistId]
        );

        return {
            id: playlist.id,
            user_id: playlist.user_id,
            name: playlist.name,
            description: playlist.description,
            is_shared: playlist.is_shared,
            songs_count: parseInt(countResult.rows[0].count),
            created_at: playlist.created_at,
            updated_at: playlist.updated_at,
        };
    }

    /**
     * Delete playlist
     */
    async deletePlaylist(playlistId: number, userId: number): Promise<void> {
        // Verify ownership
        const ownershipResult = await this.pool.query(
            'SELECT user_id FROM playlists WHERE id = $1',
            [playlistId]
        );

        if (ownershipResult.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'Playlist not found',
                statusCode: 404,
            };
        }

        if (ownershipResult.rows[0].user_id !== userId) {
            throw {
                code: ErrorCode.FORBIDDEN,
                message: 'You do not have permission to delete this playlist',
                statusCode: 403,
            };
        }

        // Delete playlist (cascade will delete songs)
        await this.pool.query('DELETE FROM playlists WHERE id = $1', [playlistId]);
    }

    /**
     * Add song to playlist
     */
    async addSong(
        playlistId: number,
        userId: number,
        musicId: number
    ): Promise<void> {
        // Verify ownership
        const ownershipResult = await this.pool.query(
            'SELECT user_id FROM playlists WHERE id = $1',
            [playlistId]
        );

        if (ownershipResult.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'Playlist not found',
                statusCode: 404,
            };
        }

        if (ownershipResult.rows[0].user_id !== userId) {
            throw {
                code: ErrorCode.FORBIDDEN,
                message: 'You do not have permission to modify this playlist',
                statusCode: 403,
            };
        }

        // Verify music exists
        const musicResult = await this.pool.query('SELECT id FROM music WHERE id = $1', [musicId]);

        if (musicResult.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'Music not found',
                statusCode: 404,
            };
        }

        // Get next position
        const positionResult = await this.pool.query(
            'SELECT MAX(position) as max_position FROM playlist_songs WHERE playlist_id = $1',
            [playlistId]
        );

        const nextPosition = (positionResult.rows[0].max_position || 0) + 1;

        // Add song
        try {
            await this.pool.query(
                `INSERT INTO playlist_songs (playlist_id, music_id, position)
         VALUES ($1, $2, $3)`,
                [playlistId, musicId, nextPosition]
            );

            // Update playlist updated_at
            await this.pool.query('UPDATE playlists SET updated_at = NOW() WHERE id = $1', [
                playlistId,
            ]);
        } catch (error: any) {
            if (error.code === '23505') {
                // Unique constraint violation
                throw {
                    code: ErrorCode.CONFLICT,
                    message: 'Song already in playlist',
                    statusCode: 409,
                };
            }
            throw error;
        }
    }

    /**
     * Remove song from playlist
     */
    async removeSong(playlistId: number, userId: number, musicId: number): Promise<void> {
        // Verify ownership
        const ownershipResult = await this.pool.query(
            'SELECT user_id FROM playlists WHERE id = $1',
            [playlistId]
        );

        if (ownershipResult.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'Playlist not found',
                statusCode: 404,
            };
        }

        if (ownershipResult.rows[0].user_id !== userId) {
            throw {
                code: ErrorCode.FORBIDDEN,
                message: 'You do not have permission to modify this playlist',
                statusCode: 403,
            };
        }

        // Remove song
        const result = await this.pool.query(
            'DELETE FROM playlist_songs WHERE playlist_id = $1 AND music_id = $2 RETURNING position',
            [playlistId, musicId]
        );

        if (result.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'Song not in playlist',
                statusCode: 404,
            };
        }

        // Update playlist updated_at
        await this.pool.query('UPDATE playlists SET updated_at = NOW() WHERE id = $1', [
            playlistId,
        ]);

        // Reorder remaining songs
        const deletedPosition = result.rows[0].position;
        await this.pool.query(
            `UPDATE playlist_songs
       SET position = position - 1
       WHERE playlist_id = $1 AND position > $2`,
            [playlistId, deletedPosition]
        );
    }

    /**
     * Get shared playlists
     */
    async getSharedPlaylists(limit: number = 50): Promise<Playlist.PlaylistResponse[]> {
        const result = await this.pool.query(
            `SELECT
        p.id, p.user_id, p.name, p.description, p.is_shared,
        COUNT(ps.music_id) as songs_count,
        p.created_at, p.updated_at
       FROM playlists p
       LEFT JOIN playlist_songs ps ON p.id = ps.playlist_id
       WHERE p.is_shared = true
       GROUP BY p.id, p.user_id, p.name, p.description, p.is_shared, p.created_at, p.updated_at
       ORDER BY p.created_at DESC
       LIMIT $1`,
            [limit]
        );

        return result.rows.map((row) => this.mapRowToPlaylistResponse(row));
    }

    /**
     * Get playlist count for user
     */
    async getUserPlaylistCount(userId: number): Promise<number> {
        const result = await this.pool.query(
            'SELECT COUNT(*) as count FROM playlists WHERE user_id = $1',
            [userId]
        );

        return parseInt(result.rows[0].count);
    }

    /**
     * Helper: Map database row to PlaylistResponse
     */
    private mapRowToPlaylistResponse(row: any): Playlist.PlaylistResponse {
        return {
            id: row.id,
            user_id: row.user_id,
            name: row.name,
            description: row.description,
            is_shared: row.is_shared,
            songs_count: parseInt(row.songs_count) || 0,
            created_at: row.created_at,
            updated_at: row.updated_at,
        };
    }
}

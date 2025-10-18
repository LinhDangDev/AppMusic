import { PoolWithExecute } from '../config/database';
import { Playlist, Music, PlaylistSong } from '../types/database.types';
import { createError } from '../utils/error';
import db from '../config/database';

/**
 * Playlist with songs information
 */
interface PlaylistWithSongs {
    playlist: Playlist;
    songs: PlaylistSongDetail[];
    total: number;
}

/**
 * Detailed playlist song for API response
 */
interface PlaylistSongDetail {
    id: number;
    title: string;
    duration?: number;
    play_count: number;
    image_url?: string;
    preview_url?: string;
    youtube_url?: string;
    youtube_thumbnail?: string;
    artist: { name?: string; image_url?: string };
    genres: string[];
    added_at: Date;
}

/**
 * Playlist Service - Handles user playlists, songs management
 * Supports transaction-based operations for data consistency
 */
class PlaylistService {
    private db: PoolWithExecute = db;

    /**
     * Get all playlists for a user
     */
    async getUserPlaylists(userId: number): Promise<any[]> {
        try {
            const [rows]: any = await this.db.execute(
                `SELECT
          p.id,
          p.user_id,
          p.name,
          p.description,
          p.is_shared,
          p.created_at,
          p.updated_at,
          COUNT(ps.music_id) as song_count
        FROM playlists p
        LEFT JOIN playlist_songs ps ON p.id = ps.playlist_id
        WHERE p.user_id = $1
        GROUP BY p.id, p.user_id, p.name, p.description, p.is_shared, p.created_at, p.updated_at
        ORDER BY p.created_at DESC`,
                [userId]
            );

            return rows.map((row: any) => ({
                id: row.id,
                user_id: row.user_id,
                name: row.name,
                description: row.description,
                is_shared: row.is_shared,
                song_count: parseInt(row.song_count) || 0,
                created_at: new Date(row.created_at),
                updated_at: new Date(row.updated_at)
            }));
        } catch (error) {
            console.error('Error getting user playlists:', error);
            throw error;
        }
    }

    /**
     * Create new playlist
     */
    async createPlaylist(
        name: string,
        description: string = '',
        userId: number
    ): Promise<Playlist> {
        try {
            const [result]: any = await this.db.execute(
                `INSERT INTO playlists (user_id, name, description, created_at, updated_at)
         VALUES ($1, $2, $3, NOW(), NOW())
         RETURNING *`,
                [userId, name, description]
            );

            if (!result || result.length === 0) {
                throw createError('Failed to create playlist', 500);
            }

            return this.mapRowToPlaylist(result[0]);
        } catch (error) {
            console.error('Error creating playlist:', error);
            throw error;
        }
    }

    /**
     * Get playlist by ID
     */
    async getPlaylistById(playlistId: number): Promise<Playlist | null> {
        try {
            const [rows]: any = await this.db.execute(
                'SELECT * FROM playlists WHERE id = $1',
                [playlistId]
            );

            if (!rows || rows.length === 0) {
                return null;
            }

            return this.mapRowToPlaylist(rows[0]);
        } catch (error) {
            console.error('Error getting playlist by id:', error);
            throw error;
        }
    }

    /**
     * Update playlist metadata
     */
    async updatePlaylist(
        playlistId: number,
        data: { name?: string; description?: string; is_shared?: boolean }
    ): Promise<Playlist | null> {
        try {
            // Verify playlist exists
            const existing = await this.getPlaylistById(playlistId);
            if (!existing) {
                throw createError('Playlist not found', 404);
            }

            const updates: string[] = [];
            const values: any[] = [];
            let paramCount = 1;

            if (data.name !== undefined) {
                updates.push(`name = $${paramCount++}`);
                values.push(data.name);
            }
            if (data.description !== undefined) {
                updates.push(`description = $${paramCount++}`);
                values.push(data.description);
            }
            if (data.is_shared !== undefined) {
                updates.push(`is_shared = $${paramCount++}`);
                values.push(data.is_shared);
            }

            if (updates.length === 0) {
                return existing;
            }

            updates.push(`updated_at = NOW()`);
            values.push(playlistId);

            const query = `UPDATE playlists SET ${updates.join(', ')} WHERE id = $${paramCount} RETURNING *`;

            const [result]: any = await this.db.execute(query, values);

            if (!result || result.length === 0) {
                return null;
            }

            return this.mapRowToPlaylist(result[0]);
        } catch (error) {
            console.error('Error updating playlist:', error);
            throw error;
        }
    }

    /**
     * Delete playlist
     */
    async deletePlaylist(playlistId: number): Promise<void> {
        try {
            await this.db.execute(
                'DELETE FROM playlists WHERE id = $1',
                [playlistId]
            );
        } catch (error) {
            console.error('Error deleting playlist:', error);
            throw error;
        }
    }

    /**
     * Add song to playlist with auto-incremented position
     */
    async addSongToPlaylist(playlistId: number, musicId: number): Promise<void> {
        try {
            // Get next position
            const [maxResult]: any = await this.db.execute(
                'SELECT MAX(position) as max_position FROM playlist_songs WHERE playlist_id = $1',
                [playlistId]
            );

            const nextPosition = (maxResult[0]?.max_position || 0) + 1;

            // Add song with new position
            await this.db.execute(
                `INSERT INTO playlist_songs (playlist_id, music_id, position, added_at)
         VALUES ($1, $2, $3, NOW())
         ON CONFLICT (playlist_id, music_id) DO NOTHING`,
                [playlistId, musicId, nextPosition]
            );
        } catch (error) {
            console.error('Error adding song to playlist:', error);
            throw error;
        }
    }

    /**
     * Remove song from playlist
     */
    async removeSongFromPlaylist(playlistId: number, musicId: number): Promise<void> {
        try {
            await this.db.execute(
                'DELETE FROM playlist_songs WHERE playlist_id = $1 AND music_id = $2',
                [playlistId, musicId]
            );
        } catch (error) {
            console.error('Error removing song from playlist:', error);
            throw error;
        }
    }

    /**
     * Get all songs in a playlist with full details
     */
    async getPlaylistSongs(playlistId: number): Promise<PlaylistWithSongs> {
        try {
            // Verify playlist exists
            const playlist = await this.getPlaylistById(playlistId);
            if (!playlist) {
                throw createError('Playlist not found', 404);
            }

            // Get songs in playlist
            const [songs]: any = await this.db.execute(
                `SELECT
          m.id,
          m.title,
          m.duration,
          m.play_count,
          m.image_url,
          m.preview_url,
          m.youtube_url,
          m.youtube_thumbnail,
          a.name as artist_name,
          a.image_url as artist_image,
          ps.added_at,
          string_agg(DISTINCT g.name, ',') as genres
        FROM playlist_songs ps
        JOIN music m ON ps.music_id = m.id
        LEFT JOIN artists a ON m.artist_id = a.id
        LEFT JOIN music_genres mg ON m.id = mg.music_id
        LEFT JOIN genres g ON mg.genre_id = g.id
        WHERE ps.playlist_id = $1
        GROUP BY m.id, a.id, a.name, a.image_url, ps.added_at
        ORDER BY ps.added_at DESC`,
                [playlistId]
            );

            const formatted: PlaylistSongDetail[] = songs.map((song: any) => ({
                id: song.id,
                title: song.title,
                duration: song.duration,
                play_count: song.play_count || 0,
                image_url: song.image_url,
                preview_url: song.preview_url,
                youtube_url: song.youtube_url,
                youtube_thumbnail: song.youtube_thumbnail,
                artist: {
                    name: song.artist_name,
                    image_url: song.artist_image
                },
                genres: song.genres ? song.genres.split(',') : [],
                added_at: new Date(song.added_at)
            }));

            return {
                playlist,
                songs: formatted,
                total: formatted.length
            };
        } catch (error) {
            console.error('Error getting playlist songs:', error);
            throw error;
        }
    }

    /**
     * Reorder song in playlist
     */
    async reorderPlaylistSong(
        playlistId: number,
        musicId: number,
        newPosition: number
    ): Promise<void> {
        try {
            // Update position
            await this.db.execute(
                `UPDATE playlist_songs
         SET position = $1
         WHERE playlist_id = $2 AND music_id = $3`,
                [newPosition, playlistId, musicId]
            );
        } catch (error) {
            console.error('Error reordering playlist song:', error);
            throw error;
        }
    }

    // ============================================
    // PRIVATE MAPPING METHOD
    // ============================================

    /**
     * Map database row to Playlist interface
     */
    private mapRowToPlaylist(row: any): Playlist {
        return {
            id: row.id,
            user_id: row.user_id,
            name: row.name,
            description: row.description,
            is_shared: row.is_shared || false,
            created_at: new Date(row.created_at),
            updated_at: new Date(row.updated_at)
        };
    }
}

export default new PlaylistService();

import { PoolWithExecute } from '../config/database';
import { User, Favorite, PlayHistory } from '../types/database.types';
import { createError } from '../utils/error';
import db from '../config/database';

/**
 * User Service - Handles all user-related database operations
 * Maps PostgreSQL rows to TypeScript User interfaces
 */
class UserService {
    private db: PoolWithExecute = db;

    /**
     * Get user by ID with full profile
     */
    async getUserById(uid: number): Promise<User | null> {
        try {
            const [rows]: any = await this.db.execute(
                `SELECT
          id,
          email,
          password_hash,
          name,
          profile_pic_url,
          avatar,
          is_premium,
          is_email_verified,
          favorite_genres,
          favorite_artists,
          created_at,
          updated_at,
          last_login,
          status
        FROM users
        WHERE id = $1`,
                [uid]
            );

            if (!rows || rows.length === 0) {
                return null;
            }

            return this.mapRowToUser(rows[0]);
        } catch (error) {
            console.error('Error getting user:', error);
            throw error;
        }
    }

    /**
     * Update user profile information
     */
    async updateUser(
        uid: number,
        data: { name?: string; avatar?: string; favorite_genres?: any; favorite_artists?: any }
    ): Promise<User | null> {
        try {
            const updates: string[] = [];
            const values: any[] = [];
            let paramCount = 1;

            if (data.name !== undefined) {
                updates.push(`name = $${paramCount++}`);
                values.push(data.name);
            }
            if (data.avatar !== undefined) {
                updates.push(`avatar = $${paramCount++}`);
                values.push(data.avatar);
            }
            if (data.favorite_genres !== undefined) {
                updates.push(`favorite_genres = $${paramCount++}`);
                values.push(data.favorite_genres);
            }
            if (data.favorite_artists !== undefined) {
                updates.push(`favorite_artists = $${paramCount++}`);
                values.push(data.favorite_artists);
            }

            if (updates.length === 0) {
                return this.getUserById(uid);
            }

            values.push(uid);
            const query = `UPDATE users SET ${updates.join(', ')} WHERE id = $${paramCount}`;

            await this.db.execute(query, values);
            return this.getUserById(uid);
        } catch (error) {
            console.error('Error updating user:', error);
            throw error;
        }
    }

    /**
     * Get user's play history
     */
    async getPlayHistory(uid: number, limit: number = 50): Promise<PlayHistory[]> {
        try {
            const [rows]: any = await this.db.execute(
                `SELECT
          id,
          user_id,
          music_id,
          play_duration,
          source_type,
          source_id,
          played_at
        FROM play_history
        WHERE user_id = $1
        ORDER BY played_at DESC
        LIMIT $2`,
                [uid, limit]
            );

            return rows.map((row: any) => this.mapRowToPlayHistory(row));
        } catch (error) {
            console.error('Error getting play history:', error);
            throw error;
        }
    }

    /**
     * Get user's favorite songs
     */
    async getFavorites(uid: number): Promise<Favorite[]> {
        try {
            const [rows]: any = await this.db.execute(
                `SELECT
          user_id,
          music_id,
          created_at
        FROM favorites
        WHERE user_id = $1
        ORDER BY created_at DESC`,
                [uid]
            );

            return rows.map((row: any) => this.mapRowToFavorite(row));
        } catch (error) {
            console.error('Error getting favorites:', error);
            throw error;
        }
    }

    /**
     * Add song to favorites
     */
    async addToFavorites(uid: number, musicId: number): Promise<void> {
        try {
            await this.db.execute(
                `INSERT INTO favorites (user_id, music_id, created_at)
         VALUES ($1, $2, NOW())`,
                [uid, musicId]
            );
        } catch (error: any) {
            if (error.code === '23505') {
                // Unique constraint violation
                throw createError('Song already in favorites', 400);
            }
            console.error('Error adding to favorites:', error);
            throw error;
        }
    }

    /**
     * Remove song from favorites
     */
    async removeFromFavorites(uid: number, musicId: number): Promise<void> {
        try {
            await this.db.execute(
                `DELETE FROM favorites
         WHERE user_id = $1 AND music_id = $2`,
                [uid, musicId]
            );
        } catch (error) {
            console.error('Error removing from favorites:', error);
            throw error;
        }
    }

    /**
     * Check if user has a song in favorites
     */
    async isFavorited(uid: number, musicId: number): Promise<boolean> {
        try {
            const [rows]: any = await this.db.execute(
                `SELECT 1 FROM favorites
         WHERE user_id = $1 AND music_id = $2
         LIMIT 1`,
                [uid, musicId]
            );
            return rows.length > 0;
        } catch (error) {
            console.error('Error checking favorite:', error);
            throw error;
        }
    }

    // ============================================
    // PRIVATE MAPPING METHODS
    // ============================================

    /**
     * Map database row to User interface
     */
    private mapRowToUser(row: any): User {
        return {
            id: row.id,
            email: row.email,
            password_hash: row.password_hash,
            name: row.name,
            profile_pic_url: row.profile_pic_url,
            avatar: row.avatar,
            is_premium: row.is_premium || false,
            is_email_verified: row.is_email_verified || false,
            favorite_genres: row.favorite_genres,
            favorite_artists: row.favorite_artists,
            created_at: new Date(row.created_at),
            updated_at: new Date(row.updated_at),
            last_login: row.last_login ? new Date(row.last_login) : undefined,
            status: row.status
        };
    }

    /**
     * Map database row to PlayHistory interface
     */
    private mapRowToPlayHistory(row: any): PlayHistory {
        return {
            id: row.id,
            user_id: row.user_id,
            music_id: row.music_id,
            play_duration: row.play_duration || 0,
            source_type: row.source_type,
            source_id: row.source_id,
            played_at: new Date(row.played_at)
        };
    }

    /**
     * Map database row to Favorite interface
     */
    private mapRowToFavorite(row: any): Favorite {
        return {
            user_id: row.user_id,
            music_id: row.music_id,
            created_at: new Date(row.created_at)
        };
    }
}

export default new UserService();

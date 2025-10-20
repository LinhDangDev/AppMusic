import { Pool } from 'pg';
import {
    User,
    ErrorCode,
    DatabaseUser,
} from '../types/api.types';

export class UserService {
    private pool: Pool;

    constructor(pool: Pool) {
        this.pool = pool;
    }

    /**
     * Get user profile
     */
    async getProfile(userId: number): Promise<User.ProfileResponse> {
        const result = await this.pool.query(
            `SELECT id, email, name, profile_pic_url, is_premium, is_email_verified,
              favorite_genres, favorite_artists, created_at, last_login
       FROM users WHERE id = $1 AND status = 'ACTIVE'`,
            [userId]
        );

        if (result.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'User not found',
                statusCode: 404,
            };
        }

        const user = result.rows[0];

        return {
            id: user.id,
            email: user.email,
            name: user.name,
            profile_pic_url: user.profile_pic_url,
            is_premium: user.is_premium,
            is_email_verified: user.is_email_verified,
            favorite_genres: user.favorite_genres ? JSON.parse(user.favorite_genres) : [],
            favorite_artists: user.favorite_artists ? JSON.parse(user.favorite_artists) : [],
            created_at: user.created_at,
            last_login: user.last_login,
        };
    }

    /**
     * Update user profile
     */
    async updateProfile(
        userId: number,
        payload: User.UpdateProfileRequest
    ): Promise<User.ProfileResponse> {
        // Validate name length
        if (payload.name && payload.name.length < 2) {
            throw {
                code: ErrorCode.VALIDATION_ERROR,
                message: 'Name must be at least 2 characters',
                statusCode: 400,
            };
        }

        if (payload.name && payload.name.length > 100) {
            throw {
                code: ErrorCode.VALIDATION_ERROR,
                message: 'Name cannot exceed 100 characters',
                statusCode: 400,
            };
        }

        // Build update query dynamically
        const updates: string[] = [];
        const values: any[] = [];
        let paramCount = 1;

        if (payload.name) {
            updates.push(`name = $${paramCount}`);
            values.push(payload.name);
            paramCount++;
        }

        if (payload.profile_pic_url) {
            updates.push(`profile_pic_url = $${paramCount}`);
            values.push(payload.profile_pic_url);
            paramCount++;
        }

        if (payload.favorite_genres) {
            updates.push(`favorite_genres = $${paramCount}`);
            values.push(JSON.stringify(payload.favorite_genres));
            paramCount++;
        }

        if (payload.favorite_artists) {
            updates.push(`favorite_artists = $${paramCount}`);
            values.push(JSON.stringify(payload.favorite_artists));
            paramCount++;
        }

        if (updates.length === 0) {
            // Return current profile if no updates
            return this.getProfile(userId);
        }

        updates.push(`updated_at = NOW()`);
        values.push(userId);

        const query = `
      UPDATE users
      SET ${updates.join(', ')}
      WHERE id = $${paramCount} AND status = 'ACTIVE'
      RETURNING id, email, name, profile_pic_url, is_premium, is_email_verified,
                favorite_genres, favorite_artists, created_at, last_login
    `;

        const result = await this.pool.query(query, values);

        if (result.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'User not found',
                statusCode: 404,
            };
        }

        const user = result.rows[0];

        return {
            id: user.id,
            email: user.email,
            name: user.name,
            profile_pic_url: user.profile_pic_url,
            is_premium: user.is_premium,
            is_email_verified: user.is_email_verified,
            favorite_genres: user.favorite_genres ? JSON.parse(user.favorite_genres) : [],
            favorite_artists: user.favorite_artists ? JSON.parse(user.favorite_artists) : [],
            created_at: user.created_at,
            last_login: user.last_login,
        };
    }

    /**
     * Get user preferences
     */
    async getPreferences(userId: number): Promise<User.PreferencesResponse> {
        const result = await this.pool.query(
            `SELECT favorite_genres, favorite_artists FROM users WHERE id = $1 AND status = 'ACTIVE'`,
            [userId]
        );

        if (result.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'User not found',
                statusCode: 404,
            };
        }

        const user = result.rows[0];

        return {
            user_id: userId,
            favorite_genres: user.favorite_genres ? JSON.parse(user.favorite_genres) : [],
            favorite_artists: user.favorite_artists ? JSON.parse(user.favorite_artists) : [],
            notification_enabled: true, // Default value
            privacy_mode: false, // Default value
        };
    }

    /**
     * Update user preferences
     */
    async updatePreferences(
        userId: number,
        payload: User.UpdatePreferencesRequest
    ): Promise<User.PreferencesResponse> {
        // Validate genres if provided
        if (payload.favorite_genres) {
            if (!Array.isArray(payload.favorite_genres)) {
                throw {
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Favorite genres must be an array',
                    statusCode: 400,
                };
            }

            if (payload.favorite_genres.length > 20) {
                throw {
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Cannot select more than 20 genres',
                    statusCode: 400,
                };
            }
        }

        // Validate artists if provided
        if (payload.favorite_artists) {
            if (!Array.isArray(payload.favorite_artists)) {
                throw {
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Favorite artists must be an array',
                    statusCode: 400,
                };
            }

            if (payload.favorite_artists.length > 50) {
                throw {
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Cannot select more than 50 artists',
                    statusCode: 400,
                };
            }
        }

        // Get current values
        const currentResult = await this.pool.query(
            `SELECT favorite_genres, favorite_artists FROM users WHERE id = $1 AND status = 'ACTIVE'`,
            [userId]
        );

        if (currentResult.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'User not found',
                statusCode: 404,
            };
        }

        const currentUser = currentResult.rows[0];
        const genres = payload.favorite_genres !== undefined
            ? JSON.stringify(payload.favorite_genres)
            : currentUser.favorite_genres;
        const artists = payload.favorite_artists !== undefined
            ? JSON.stringify(payload.favorite_artists)
            : currentUser.favorite_artists;

        // Update user
        await this.pool.query(
            `UPDATE users
       SET favorite_genres = $1, favorite_artists = $2, updated_at = NOW()
       WHERE id = $3 AND status = 'ACTIVE'`,
            [genres, artists, userId]
        );

        return {
            user_id: userId,
            favorite_genres: payload.favorite_genres ??
                (currentUser.favorite_genres ? JSON.parse(currentUser.favorite_genres) : []),
            favorite_artists: payload.favorite_artists ??
                (currentUser.favorite_artists ? JSON.parse(currentUser.favorite_artists) : []),
            notification_enabled: true,
            privacy_mode: false,
        };
    }

    /**
   * Get user statistics
   */
    async getUserStats(userId: number): Promise<User.UserStatsResponse> {
        // Verify user exists
        const userResult = await this.pool.query(
            'SELECT id FROM users WHERE id = $1 AND status = \'ACTIVE\'',
            [userId]
        );

        if (userResult.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'User not found',
                statusCode: 404,
            };
        }

        // Get play history stats
        const playResult = await this.pool.query(
            `SELECT COUNT(DISTINCT music_id) as songs_played,
              SUM(play_duration) as total_play_time,
              MAX(music_id) as last_played_music_id
       FROM play_history WHERE user_id = $1`,
            [userId]
        );

        const playStats = playResult.rows[0];

        // Get favorites count
        const favResult = await this.pool.query(
            'SELECT COUNT(*) as count FROM favorites WHERE user_id = $1',
            [userId]
        );

        const favCount = parseInt(favResult.rows[0].count);

        // Get playlists count
        const playlistResult = await this.pool.query(
            'SELECT COUNT(*) as count FROM playlists WHERE user_id = $1',
            [userId]
        );

        const playlistCount = parseInt(playlistResult.rows[0].count);

        // Get favorite genre from play history
        const genreResult = await this.pool.query(
            `SELECT mg.genre_id, g.name, COUNT(*) as count
       FROM play_history ph
       JOIN music m ON ph.music_id = m.id
       JOIN music_genres mg ON m.id = mg.music_id
       JOIN genres g ON mg.genre_id = g.id
       WHERE ph.user_id = $1
       GROUP BY mg.genre_id, g.name
       ORDER BY count DESC
       LIMIT 1`,
            [userId]
        );

        const favoriteGenre = genreResult.rows.length > 0 ? genreResult.rows[0].name : undefined;

        return {
            user_id: userId,
            songs_played: parseInt(playStats.songs_played) || 0,
            songs_favorited: favCount,
            playlists_count: playlistCount,
            total_play_time: parseInt(playStats.total_play_time) || 0,
            last_played_music_id: playStats.last_played_music_id,
            favorite_genre: favoriteGenre,
        };
    }

    /**
   * Deactivate user account
   */
    async deactivateAccount(userId: number): Promise<void> {
        const result = await this.pool.query(
            'UPDATE users SET status = \'INACTIVE\', updated_at = NOW() WHERE id = $1 RETURNING id',
            [userId]
        );

        if (result.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'User not found',
                statusCode: 404,
            };
        }

        // Revoke all refresh tokens
        await this.pool.query(
            'UPDATE refresh_tokens SET is_revoked = true WHERE user_id = $1',
            [userId]
        );
    }

    /**
     * Get user by email
     */
    async getUserByEmail(email: string): Promise<DatabaseUser | null> {
        const result = await this.pool.query(
            'SELECT * FROM users WHERE LOWER(email) = LOWER($1) AND status = \'ACTIVE\'',
            [email]
        );

        return result.rows.length > 0 ? result.rows[0] : null;
    }

    /**
     * Check if email exists
     */
    async emailExists(email: string): Promise<boolean> {
        const result = await this.pool.query(
            'SELECT id FROM users WHERE LOWER(email) = LOWER($1)',
            [email]
        );

        return result.rows.length > 0;
    }

    /**
     * Get total users count
     */
    async getTotalUsersCount(): Promise<number> {
        const result = await this.pool.query(
            'SELECT COUNT(*) as count FROM users WHERE status = \'ACTIVE\''
        );

        return parseInt(result.rows[0].count);
    }

    /**
     * Get premium users count
     */
    async getPremiumUsersCount(): Promise<number> {
        const result = await this.pool.query(
            'SELECT COUNT(*) as count FROM users WHERE is_premium = true AND status = \'ACTIVE\''
        );

        return parseInt(result.rows[0].count);
    }
}

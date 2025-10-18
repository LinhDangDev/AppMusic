import { PoolWithExecute } from '../config/database';
import { Artist } from '../types/database.types';
import db from '../config/database';

/**
 * Artist Service - Artist catalog operations and search
 */
class ArtistService {
    private db: PoolWithExecute = db;

    /**
     * Get artist by ID
     */
    async getArtistById(artistId: number): Promise<Artist | null> {
        try {
            const [rows]: any = await this.db.execute(
                'SELECT * FROM artists WHERE id = $1',
                [artistId]
            );
            return rows.length > 0 ? this.mapRowToArtist(rows[0]) : null;
        } catch (error) {
            console.error('Error getting artist:', error);
            throw error;
        }
    }

    /**
     * Search artists by name
     */
    async searchArtists(query: string, limit: number = 20): Promise<Artist[]> {
        try {
            const searchQuery = `%${query}%`;
            const [rows]: any = await this.db.execute(
                `SELECT * FROM artists
         WHERE LOWER(name) ILIKE LOWER($1)
         ORDER BY name
         LIMIT $2`,
                [searchQuery, limit]
            );
            return rows.map((row: any) => this.mapRowToArtist(row));
        } catch (error) {
            console.error('Error searching artists:', error);
            return [];
        }
    }

    /**
     * Get top artists by music play count
     */
    async getTopArtists(limit: number = 10): Promise<Artist[]> {
        try {
            const [rows]: any = await this.db.execute(
                `SELECT a.*, COUNT(m.id) as music_count, COALESCE(SUM(m.play_count), 0) as total_plays
         FROM artists a
         LEFT JOIN music m ON a.id = m.artist_id
         GROUP BY a.id
         ORDER BY total_plays DESC, music_count DESC
         LIMIT $1`,
                [limit]
            );
            return rows.map((row: any) => this.mapRowToArtist(row));
        } catch (error) {
            console.error('Error getting top artists:', error);
            return [];
        }
    }

    /**
     * Get artist with music count
     */
    async getArtistWithStats(artistId: number): Promise<any | null> {
        try {
            const [rows]: any = await this.db.execute(
                `SELECT a.*, COUNT(DISTINCT m.id) as music_count
         FROM artists a
         LEFT JOIN music m ON a.id = m.artist_id
         WHERE a.id = $1
         GROUP BY a.id`,
                [artistId]
            );
            return rows.length > 0 ? rows[0] : null;
        } catch (error) {
            console.error('Error getting artist stats:', error);
            throw error;
        }
    }

    private mapRowToArtist(row: any): Artist {
        return {
            id: row.id,
            name: row.name,
            bio: row.bio,
            image_url: row.image_url,
            description: row.description,
            created_at: new Date(row.created_at),
            updated_at: new Date(row.updated_at)
        };
    }
}

export default new ArtistService();

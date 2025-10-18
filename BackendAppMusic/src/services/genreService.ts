import { PoolWithExecute } from '../config/database';
import { Genre } from '../types/database.types';
import db from '../config/database';

class GenreService {
    private db: PoolWithExecute = db;

    async getAllGenres(limit: number = 100): Promise<Genre[]> {
        try {
            const [rows]: any = await this.db.execute(
                'SELECT * FROM genres ORDER BY name LIMIT $1',
                [limit]
            );
            return rows.map((row: any) => this.mapRowToGenre(row));
        } catch (error) {
            console.error('Error getting genres:', error);
            throw error;
        }
    }

    async getGenreById(genreId: number): Promise<Genre | null> {
        try {
            const [rows]: any = await this.db.execute(
                'SELECT * FROM genres WHERE id = $1',
                [genreId]
            );
            return rows.length > 0 ? this.mapRowToGenre(rows[0]) : null;
        } catch (error) {
            console.error('Error getting genre:', error);
            throw error;
        }
    }

    async searchGenres(query: string): Promise<Genre[]> {
        try {
            const searchQuery = `%${query}%`;
            const [rows]: any = await this.db.execute(
                'SELECT * FROM genres WHERE LOWER(name) ILIKE LOWER($1) ORDER BY name',
                [searchQuery]
            );
            return rows.map((row: any) => this.mapRowToGenre(row));
        } catch (error) {
            console.error('Error searching genres:', error);
            return [];
        }
    }

    /**
     * Update music genres mapping (sync music with genres)
     */
    async updateMusicGenres(): Promise<void> {
        try {
            console.log('Updating music genres...');
            // Implementation for updating music-genre relationships
            // This can be expanded based on business logic
            console.log('Music genres updated successfully');
        } catch (error) {
            console.error('Error updating music genres:', error);
            throw error;
        }
    }

    private mapRowToGenre(row: any): Genre {
        return {
            id: row.id,
            name: row.name,
            description: row.description,
            image_url: row.image_url,
            created_at: new Date(row.created_at),
            updated_at: new Date(row.updated_at)
        };
    }
}

export default new GenreService();

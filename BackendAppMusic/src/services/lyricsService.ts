import pool, { PoolWithExecute } from '../config/database';

interface LyricsData {
    id?: number;
    title: string;
    artist: string;
    lyrics: string;
    source?: string;
    created_at?: Date;
}

/**
 * Lyrics Service - handles lyrics database operations
 */
class LyricsService {
    /**
     * Search lyrics by title and artist
     */
    public async searchLyrics(title: string, artist: string): Promise<LyricsData | null> {
        try {
            const query = `
        SELECT * FROM lyrics_database
        WHERE LOWER(title) = LOWER($1) AND LOWER(artist) = LOWER($2)
        LIMIT 1
      `;
            const result = await (pool as any).query(query, [title, artist]);
            return result.rows[0] || null;
        } catch (error) {
            console.error('Error searching lyrics:', error);
            throw error;
        }
    }

    /**
     * Save lyrics to database
     */
    public async saveLyrics(lyrics: LyricsData): Promise<LyricsData> {
        try {
            const query = `
        INSERT INTO lyrics_database (title, artist, lyrics, source)
        VALUES ($1, $2, $3, $4)
        RETURNING *
      `;
            const result = await (pool as any).query(query, [
                lyrics.title,
                lyrics.artist,
                lyrics.lyrics,
                lyrics.source || 'genius'
            ]);
            return result.rows[0];
        } catch (error) {
            console.error('Error saving lyrics:', error);
            throw error;
        }
    }

    /**
     * Update existing lyrics
     */
    public async updateLyrics(id: number, lyrics: Partial<LyricsData>): Promise<LyricsData> {
        try {
            const updates: string[] = [];
            const values: any[] = [];
            let paramIndex = 1;

            if (lyrics.title) {
                updates.push(`title = $${paramIndex++}`);
                values.push(lyrics.title);
            }
            if (lyrics.lyrics) {
                updates.push(`lyrics = $${paramIndex++}`);
                values.push(lyrics.lyrics);
            }
            if (lyrics.source) {
                updates.push(`source = $${paramIndex++}`);
                values.push(lyrics.source);
            }

            values.push(id);
            const query = `
        UPDATE lyrics_database
        SET ${updates.join(', ')}
        WHERE id = $${paramIndex}
        RETURNING *
      `;
            const result = await (pool as any).query(query, values);
            return result.rows[0];
        } catch (error) {
            console.error('Error updating lyrics:', error);
            throw error;
        }
    }
}

export default new LyricsService();

import { PoolWithExecute } from '../config/database';
import { Ranking } from '../types/database.types';
import db from '../config/database';

class RankingService {
    private db: PoolWithExecute = db;

    async getRankingsByPlatform(platform: string, limit: number = 50): Promise<Ranking[]> {
        try {
            const [rows]: any = await this.db.execute(
                `SELECT r.*, m.title, a.name as artist_name
         FROM rankings r
         JOIN music m ON r.music_id = m.id
         LEFT JOIN artists a ON m.artist_id = a.id
         WHERE r.platform = $1
         ORDER BY r.rank_position ASC
         LIMIT $2`,
                [platform, limit]
            );
            return rows.map((row: any) => this.mapRowToRanking(row));
        } catch (error) {
            console.error('Error getting rankings:', error);
            throw error;
        }
    }

    async getRankingsByRegion(region: string, limit: number = 50): Promise<any[]> {
        try {
            const [rows]: any = await this.db.execute(
                `SELECT
                    r.id,
                    r.rank_position,
                    r.position,
                    r.region,
                    r.ranking_date,
                    r.created_at,
                    r.updated_at,
                    m.id as music_id,
                    m.title,
                    m.artist_id,
                    a.name as artist_name,
                    m.youtube_id,
                    m.youtube_thumbnail,
                    m.youtube_url,
                    m.duration,
                    m.play_count,
                    m.genre
                FROM rankings r
                JOIN music m ON r.music_id = m.id
                LEFT JOIN artists a ON m.artist_id = a.id
                WHERE r.region = $1
                ORDER BY r.rank_position ASC
                LIMIT $2`,
                [region, limit]
            );

            return rows.map((row: any) => ({
                id: row.id,
                rank_position: row.rank_position,
                position: row.position || row.rank_position,
                region: row.region,
                ranking_date: row.ranking_date,
                created_at: row.created_at,
                updated_at: row.updated_at,
                music_id: row.music_id,
                title: row.title || 'Unknown',
                artist_id: row.artist_id,
                artist_name: row.artist_name || 'Unknown Artist',
                youtube_id: row.youtube_id,
                youtube_thumbnail: row.youtube_thumbnail,
                youtube_url: row.youtube_url,
                duration: row.duration,
                play_count: row.play_count || 0,
                genre: row.genre
            }));
        } catch (error) {
            console.error('Error getting regional rankings:', error);
            return [];
        }
    }

    async updateRanking(musicId: number, platform: string, position: number): Promise<Ranking | null> {
        try {
            const [result]: any = await this.db.execute(
                `INSERT INTO rankings (platform, music_id, rank_position, ranking_date, created_at, updated_at)
         VALUES ($1, $2, $3, CURRENT_DATE, NOW(), NOW())
         ON CONFLICT (platform, music_id, ranking_date)
         DO UPDATE SET rank_position = $3, updated_at = NOW()
         RETURNING *`,
                [platform, musicId, position]
            );
            return result.length > 0 ? this.mapRowToRanking(result[0]) : null;
        } catch (error) {
            console.error('Error updating ranking:', error);
            throw error;
        }
    }

    private mapRowToRanking(row: any): Ranking {
        return {
            id: row.id,
            platform: row.platform,
            region: row.region,
            music_id: row.music_id,
            rank_position: row.rank_position,
            position: row.position,
            ranking_date: new Date(row.ranking_date),
            created_at: new Date(row.created_at),
            updated_at: new Date(row.updated_at)
        };
    }
}

export default new RankingService();

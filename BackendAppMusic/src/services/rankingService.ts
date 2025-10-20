import { Pool } from 'pg';
import { Ranking, Music, ErrorCode } from '../types/api.types';

export class RankingService {
    private pool: Pool;

    constructor(pool: Pool) {
        this.pool = pool;
    }

    /**
     * Get rankings with filtering
     */
    async getRankings(
        platform?: string,
        region?: string,
        limit: number = 50
    ): Promise<Ranking.RankingResponse[]> {
        if (limit > 1000) limit = 1000;

        let query = `
      SELECT
        r.id, r.rank_position, r.music_id, r.platform, r.region,
        r.ranking_date, m.title, a.name as artist_name
       FROM rankings r
       JOIN music m ON r.music_id = m.id
       LEFT JOIN artists a ON m.artist_id = a.id
       WHERE 1=1
    `;

        const params: any[] = [];
        let paramCount = 1;

        if (platform) {
            query += ` AND r.platform = $${paramCount}`;
            params.push(platform);
            paramCount++;
        }

        if (region) {
            query += ` AND r.region = $${paramCount}`;
            params.push(region);
            paramCount++;
        }

        query += `
      ORDER BY r.ranking_date DESC, r.rank_position ASC
      LIMIT $${paramCount}
    `;
        params.push(limit);

        const result = await this.pool.query(query, params);

        return result.rows.map((row) => ({
            id: row.id,
            rank_position: row.rank_position,
            music_id: row.music_id,
            title: row.title,
            artist_name: row.artist_name || 'Unknown Artist',
            platform: row.platform,
            region: row.region,
            ranking_date: row.ranking_date,
        }));
    }

    /**
     * Get rankings by specific date
     */
    async getRankingsByDate(
        date: string,
        platform?: string,
        region?: string,
        limit: number = 50
    ): Promise<Ranking.RankingResponse[]> {
        if (limit > 1000) limit = 1000;

        let query = `
      SELECT
        r.id, r.rank_position, r.music_id, r.platform, r.region,
        r.ranking_date, m.title, a.name as artist_name
       FROM rankings r
       JOIN music m ON r.music_id = m.id
       LEFT JOIN artists a ON m.artist_id = a.id
       WHERE r.ranking_date = $1
    `;

        const params: any[] = [date];
        let paramCount = 2;

        if (platform) {
            query += ` AND r.platform = $${paramCount}`;
            params.push(platform);
            paramCount++;
        }

        if (region) {
            query += ` AND r.region = $${paramCount}`;
            params.push(region);
            paramCount++;
        }

        query += `
      ORDER BY r.rank_position ASC
      LIMIT $${paramCount}
    `;
        params.push(limit);

        const result = await this.pool.query(query, params);

        return result.rows.map((row) => ({
            id: row.id,
            rank_position: row.rank_position,
            music_id: row.music_id,
            title: row.title,
            artist_name: row.artist_name || 'Unknown Artist',
            platform: row.platform,
            region: row.region,
            ranking_date: row.ranking_date,
        }));
    }

    /**
     * Get top rankings
     */
    async getTopRankings(limit: number = 50): Promise<Ranking.RankingResponse[]> {
        if (limit > 1000) limit = 1000;

        const result = await this.pool.query(
            `SELECT
        r.id, r.rank_position, r.music_id, r.platform, r.region,
        r.ranking_date, m.title, a.name as artist_name
       FROM rankings r
       JOIN music m ON r.music_id = m.id
       LEFT JOIN artists a ON m.artist_id = a.id
       WHERE r.rank_position <= 100
       ORDER BY r.ranking_date DESC, r.rank_position ASC
       LIMIT $1`,
            [limit]
        );

        return result.rows.map((row) => ({
            id: row.id,
            rank_position: row.rank_position,
            music_id: row.music_id,
            title: row.title,
            artist_name: row.artist_name || 'Unknown Artist',
            platform: row.platform,
            region: row.region,
            ranking_date: row.ranking_date,
        }));
    }

    /**
     * Get music ranking history
     */
    async getMusicRankingHistory(musicId: number, platform?: string): Promise<Ranking.RankingResponse[]> {
        let query = `
      SELECT
        r.id, r.rank_position, r.music_id, r.platform, r.region,
        r.ranking_date, m.title, a.name as artist_name
       FROM rankings r
       JOIN music m ON r.music_id = m.id
       LEFT JOIN artists a ON m.artist_id = a.id
       WHERE r.music_id = $1
    `;

        const params: any[] = [musicId];
        let paramCount = 2;

        if (platform) {
            query += ` AND r.platform = $${paramCount}`;
            params.push(platform);
            paramCount++;
        }

        query += ` ORDER BY r.ranking_date DESC, r.rank_position ASC`;

        const result = await this.pool.query(query, params);

        return result.rows.map((row) => ({
            id: row.id,
            rank_position: row.rank_position,
            music_id: row.music_id,
            title: row.title,
            artist_name: row.artist_name || 'Unknown Artist',
            platform: row.platform,
            region: row.region,
            ranking_date: row.ranking_date,
        }));
    }

    /**
     * Get available platforms
     */
    async getAvailablePlatforms(): Promise<string[]> {
        const result = await this.pool.query(
            'SELECT DISTINCT platform FROM rankings ORDER BY platform'
        );

        return result.rows.map((row) => row.platform);
    }

    /**
     * Get available regions
     */
    async getAvailableRegions(platform?: string): Promise<string[]> {
        let query = 'SELECT DISTINCT region FROM rankings WHERE region IS NOT NULL';
        const params: any[] = [];

        if (platform) {
            query += ` AND platform = $1`;
            params.push(platform);
        }

        query += ` ORDER BY region`;

        const result = await this.pool.query(query, params);

        return result.rows.map((row) => row.region).filter((r) => r !== null);
    }

    /**
     * Get ranking statistics
     */
    async getRankingStats(): Promise<{
        total_rankings: number;
        platforms: string[];
        regions: string[];
        latest_date: string;
    }> {
        // Total rankings
        const totalResult = await this.pool.query('SELECT COUNT(*) as count FROM rankings');
        const totalRankings = parseInt(totalResult.rows[0].count);

        // Platforms
        const platformsResult = await this.pool.query(
            'SELECT DISTINCT platform FROM rankings ORDER BY platform'
        );
        const platforms = platformsResult.rows.map((row) => row.platform);

        // Regions
        const regionsResult = await this.pool.query(
            'SELECT DISTINCT region FROM rankings WHERE region IS NOT NULL ORDER BY region'
        );
        const regions = regionsResult.rows.map((row) => row.region);

        // Latest date
        const latestResult = await this.pool.query(
            'SELECT MAX(ranking_date) as latest_date FROM rankings'
        );
        const latestDate = latestResult.rows[0].latest_date;

        return {
            total_rankings: totalRankings,
            platforms,
            regions,
            latest_date: latestDate || '',
        };
    }

    /**
     * Get artist ranking position
     */
    async getArtistRankingPosition(artistId: number, platform?: string): Promise<{
        position: number;
        count: number;
    }> {
        let query = `
      SELECT
        MIN(r.rank_position) as best_position,
        COUNT(DISTINCT r.music_id) as song_count
       FROM rankings r
       JOIN music m ON r.music_id = m.id
       WHERE m.artist_id = $1
    `;

        const params: any[] = [artistId];
        let paramCount = 2;

        if (platform) {
            query += ` AND r.platform = $${paramCount}`;
            params.push(platform);
            paramCount++;
        }

        const result = await this.pool.query(query, params);

        return {
            position: result.rows[0].best_position || 0,
            count: parseInt(result.rows[0].song_count) || 0,
        };
    }

    /**
     * Insert ranking (for admin/batch operations)
     */
    async insertRanking(
        musicId: number,
        platform: string,
        rankPosition: number,
        region?: string,
        rankingDate?: string
    ): Promise<void> {
        // Verify music exists
        const musicResult = await this.pool.query('SELECT id FROM music WHERE id = $1', [musicId]);

        if (musicResult.rows.length === 0) {
            throw {
                code: ErrorCode.NOT_FOUND,
                message: 'Music not found',
                statusCode: 404,
            };
        }

        // Validate rank position
        if (rankPosition < 1 || rankPosition > 10000) {
            throw {
                code: ErrorCode.VALIDATION_ERROR,
                message: 'Rank position must be between 1 and 10000',
                statusCode: 400,
            };
        }

        const finalDate = rankingDate || new Date().toISOString().split('T')[0];

        try {
            await this.pool.query(
                `INSERT INTO rankings (music_id, platform, region, rank_position, ranking_date)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (platform, music_id, ranking_date)
         DO UPDATE SET rank_position = $4, region = $3`,
                [musicId, platform, region || null, rankPosition, finalDate]
            );
        } catch (error) {
            throw error;
        }
    }

    /**
     * Get trending songs (biggest rank improvements)
     */
    async getTrendingSongs(platform?: string, limit: number = 50): Promise<any[]> {
        if (limit > 1000) limit = 1000;

        let query = `
      SELECT
        m.id, m.title, a.name as artist_name,
        r1.rank_position as current_position,
        r2.rank_position as previous_position,
        (r2.rank_position - r1.rank_position) as improvement,
        r1.ranking_date,
        r1.platform
       FROM rankings r1
       JOIN music m ON r1.music_id = m.id
       LEFT JOIN artists a ON m.artist_id = a.id
       LEFT JOIN rankings r2 ON r1.music_id = r2.music_id
         AND r1.platform = r2.platform
         AND r2.ranking_date < r1.ranking_date
         AND r2.ranking_date = (
           SELECT MAX(ranking_date) FROM rankings r3
           WHERE r3.music_id = r1.music_id
             AND r3.platform = r1.platform
             AND r3.ranking_date < r1.ranking_date
         )
       WHERE 1=1
    `;

        const params: any[] = [];
        let paramCount = 1;

        if (platform) {
            query += ` AND r1.platform = $${paramCount}`;
            params.push(platform);
            paramCount++;
        }

        query += `
      ORDER BY improvement DESC NULLS LAST
      LIMIT $${paramCount}
    `;
        params.push(limit);

        const result = await this.pool.query(query, params);

        return result.rows.map((row) => ({
            music_id: row.id,
            title: row.title,
            artist_name: row.artist_name || 'Unknown Artist',
            current_position: row.current_position,
            previous_position: row.previous_position,
            improvement: row.improvement,
            ranking_date: row.ranking_date,
            platform: row.platform,
        }));
    }
}

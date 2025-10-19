import axios from 'axios';
import pool from '../config/database';
import { PoolWithExecute } from '../config/database';

interface iTunesRanking {
    rank: number;
    title: string;
    artist: string;
    link?: string;
    thumbnail?: string;
}

/**
 * iTunes Rankings Service
 * Fetches top songs from iTunes charts and saves them to database
 */
class iTunesService {
    private db: PoolWithExecute = pool as any;

    /**
     * Fetch iTunes top songs from chart
     * Tries multiple endpoints to find valid data
     */
    async fetchiTunesRankings(region: string = 'us', limit: number = 50): Promise<iTunesRanking[]> {
        try {
            console.log(`📱 Fetching iTunes rankings for region: ${region}, limit: ${limit}`);

            // ✅ FIXED: Use correct endpoint /topsongs/ instead of /topcharts/
            const urls = [
                `https://itunes.apple.com/${region}/rss/topsongs/limit=${limit}/json`,
                `https://itunes.apple.com/${region}/rss/topalbums/limit=${limit}/json`,
                `https://itunes.apple.com/${region}/rss/topgrossingapps/limit=${limit}/json`
            ];

            let rankings: iTunesRanking[] = [];
            let lastError: any = null;

            // Try multiple endpoints
            for (const url of urls) {
                try {
                    console.log(`  Trying endpoint: ${url.split('/').slice(-3).join('/')}`);

                    const response = await axios.get(url, {
                        timeout: 10000,
                        headers: {
                            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
                        }
                    });

                    if (response.data?.feed?.entry) {
                        response.data.feed.entry.forEach((entry: any, index: number) => {
                            if (entry['im:name'] && entry['im:artist']) {
                                rankings.push({
                                    rank: index + 1,
                                    title: entry['im:name'].label || '',
                                    artist: entry['im:artist'].label || 'Unknown Artist',
                                    link: entry.link?.[0]?.attributes?.href || '',
                                    thumbnail: entry['im:image']?.[2]?.label || ''
                                });
                            }
                        });

                        if (rankings.length > 0) {
                            console.log(`  ✅ Success with endpoint: ${url.split('/').slice(-3).join('/')}`);
                            break; // Use first successful endpoint
                        }
                    }
                } catch (err: any) {
                    console.log(`  ⚠️ Endpoint failed: ${err.message}`);
                    lastError = err;
                    // Try next endpoint
                }
            }

            if (rankings.length === 0 && lastError) {
                console.error(`❌ All iTunes endpoints failed. Last error:`, lastError.message);
                // Return empty array, don't crash
                return [];
            }

            console.log(`✅ Fetched ${rankings.length} songs from iTunes`);
            return rankings;

        } catch (error) {
            console.error('❌ Error fetching iTunes rankings:', error);
            return [];
        }
    }

    /**
     * Find YouTube URL for a song by searching YouTube
     */
    private async findYouTubeUrl(title: string, artist: string): Promise<string | null> {
        try {
            // This would require youtube-api integration or scraping
            // For now, return null - can be implemented with youtube_explode
            // In production, use: youtube_explode_dart or similar
            return null;
        } catch (error) {
            console.error('Error finding YouTube URL:', error);
            return null;
        }
    }

    /**
     * Save rankings to database
     */
    async saveiTunesRankings(rankings: iTunesRanking[], region: string = 'US'): Promise<number> {
        let savedCount = 0;

        try {
            for (const ranking of rankings) {
                try {
                    // 1. Insert or get artist
                    const [artistResult]: any = await this.db.execute(
                        `INSERT INTO artists (name) VALUES ($1)
                         ON CONFLICT (name) DO UPDATE SET name = $1
                         RETURNING id`,
                        [ranking.artist.trim()]
                    );
                    const artistId = artistResult[0]?.id;

                    // 2. Insert music - without ON CONFLICT since no UNIQUE constraint exists
                    // Just insert, if duplicate it will still work (multiple can have same title/artist)
                    const youtubeUrl = await this.findYouTubeUrl(ranking.title, ranking.artist);

                    const [musicResult]: any = await this.db.execute(
                        `INSERT INTO music (
                            title,
                            artist_id,
                            youtube_url,
                            youtube_thumbnail,
                            duration,
                            play_count,
                            created_at,
                            updated_at
                        ) VALUES ($1, $2, $3, $4, 0, 0, NOW(), NOW())
                         RETURNING id`,
                        [
                            ranking.title.trim(),
                            artistId,
                            youtubeUrl || ranking.link || '',
                            ranking.thumbnail || ''
                        ]
                    );
                    const musicId = musicResult[0]?.id;

                    // 3. Insert ranking - with ON CONFLICT on rankings table (which has UNIQUE constraint)
                    if (musicId) {
                        await this.db.execute(
                            `INSERT INTO rankings (
                                music_id,
                                region,
                                rank_position,
                                position,
                                ranking_date,
                                platform,
                                created_at,
                                updated_at
                            ) VALUES ($1, $2, $3, $4, CURRENT_DATE, 'iTunes', NOW(), NOW())
                             ON CONFLICT (platform, music_id, ranking_date)
                             DO UPDATE SET
                                rank_position = EXCLUDED.rank_position,
                                position = EXCLUDED.position,
                                updated_at = NOW()`,
                            [musicId, region, ranking.rank, ranking.rank]
                        );
                        savedCount++;
                    }
                } catch (err: any) {
                    // Log but continue - some inserts might fail due to constraints
                    if (err.message && !err.message.includes('duplicate')) {
                        console.error(`⚠️ Error saving ranking for "${ranking.title}":`, err.message);
                    }
                    // Continue with next song
                }
            }

            if (savedCount > 0) {
                console.log(`✅ Saved ${savedCount}/${rankings.length} songs from iTunes to database`);
            }
            return savedCount;

        } catch (error) {
            console.error('❌ Error saving iTunes rankings:', error);
            throw error;
        }
    }

    /**
     * Full sync: Fetch and save iTunes rankings
     */
    async syncItunesRankings(regions: string[] = ['us', 'vn'], limit: number = 50): Promise<void> {
        try {
            console.log('🎵 Starting iTunes rankings sync...');

            let totalSaved = 0;
            for (const region of regions) {
                try {
                    const rankings = await this.fetchiTunesRankings(region, limit);
                    if (rankings.length > 0) {
                        const saved = await this.saveiTunesRankings(rankings, region.toUpperCase());
                        totalSaved += saved;
                    } else {
                        console.log(`⚠️ No rankings fetched for region: ${region}`);
                    }
                } catch (err) {
                    console.error(`Error syncing iTunes for region ${region}:`, err);
                }
            }

            if (totalSaved > 0) {
                console.log(`✅ iTunes rankings sync completed - Saved ${totalSaved} songs total`);
            } else {
                console.log(`⚠️ iTunes rankings sync completed - No songs saved (may need to check API)`);
            }
        } catch (error) {
            console.error('❌ iTunes rankings sync failed:', error);
            throw error;
        }
    }
}

export default new iTunesService();

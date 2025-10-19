import axios from 'axios';
import pool from '../config/database';
import { PoolWithExecute } from '../config/database';

/**
 * Artist Enricher Service
 * Fetches artist information (images, bio) from multiple sources:
 * 1. Wikipedia (FREE)
 * 2. Wikimedia Commons (FREE)
 * 3. MusicBrainz (FREE)
 * 4. Gemini API (fallback for tough cases)
 */
class ArtistEnricherService {
    private db: PoolWithExecute = pool as any;
    private geminiApiKey: string | null = null;

    constructor() {
        this.geminiApiKey = process.env.GEMINI_API_KEY || null;
    }

    /**
     * Search for artist on MusicBrainz (FREE open source API)
     */
    private async searchMusicBrainz(artistName: string): Promise<{
        image_url: string | null;
        bio: string | null;
        wikipediaUrl: string | null;
    } | null> {
        try {
            const response = await axios.get('https://musicbrainz.org/ws/2/artist', {
                params: {
                    query: `artist:"${artistName}"`,
                    fmt: 'json',
                    limit: 1
                },
                headers: {
                    'User-Agent': 'AppMusic/1.0 (https://github.com/your-repo)'
                },
                timeout: 5000
            });

            const artists = response.data.artists;
            if (!artists || artists.length === 0) {
                return null;
            }

            const artist = artists[0];
            let wikipediaUrl = null;

            if (artist.relations) {
                const wikiRelation = artist.relations.find(
                    (rel: any) => rel['type-id'] === 'd4dcd0c0-b341-3612-a332-c0ce797b25cf'
                );
                if (wikiRelation && wikiRelation.url) {
                    wikipediaUrl = wikiRelation.url.resource;
                }
            }

            return {
                image_url: null,
                bio: artist.comment || artist.type || 'Artist',
                wikipediaUrl
            };
        } catch (error: any) {
            console.error(`⚠️ Error searching MusicBrainz for "${artistName}":`, error.message);
            return null;
        }
    }

    /**
     * Fetch artist info from Wikipedia (FREE)
     */
    private async fetchWikipediaInfo(artistName: string): Promise<{
        image_url: string | null;
        bio: string | null;
    } | null> {
        try {
            const response = await axios.get('https://en.wikipedia.org/w/api.php', {
                params: {
                    action: 'query',
                    format: 'json',
                    srsearch: `${artistName} musician`,
                    srnamespace: 0,
                    srlimit: 1,
                    list: 'search'
                },
                timeout: 5000
            });

            const results = response.data.query?.search;
            if (!results || results.length === 0) {
                return null;
            }

            const pageTitle = results[0].title;

            const pageResponse = await axios.get('https://en.wikipedia.org/w/api.php', {
                params: {
                    action: 'query',
                    format: 'json',
                    titles: pageTitle,
                    prop: 'pageimages|extracts',
                    exintro: true,
                    explaintext: true,
                    pithumbsize: 300
                },
                timeout: 5000
            });

            const pages = pageResponse.data.query?.pages;
            if (!pages) return null;

            const page = Object.values(pages)[0] as any;
            const imageUrl = page.thumbnail?.source || null;
            const extract = (page.extract || 'Artist').substring(0, 500);

            return {
                image_url: imageUrl,
                bio: extract
            };
        } catch (error: any) {
            console.error(`⚠️ Error fetching Wikipedia info for "${artistName}":`, error.message);
            return null;
        }
    }

    /**
     * Search for artist image using Wikimedia Commons (FREE)
     */
    private async searchWikimediaImage(artistName: string): Promise<string | null> {
        try {
            const response = await axios.get('https://commons.wikimedia.org/w/api.php', {
                params: {
                    action: 'query',
                    format: 'json',
                    srsearch: `${artistName} portrait`,
                    srnamespace: 6,
                    srlimit: 1,
                    list: 'search'
                },
                timeout: 5000
            });

            const results = response.data.query?.search;
            if (!results || results.length === 0) {
                return null;
            }

            const fileName = results[0].title.replace('File:', '');

            const fileResponse = await axios.get('https://commons.wikimedia.org/w/api.php', {
                params: {
                    action: 'query',
                    format: 'json',
                    titles: `File:${fileName}`,
                    prop: 'imageinfo',
                    iiprop: 'url'
                },
                timeout: 5000
            });

            const pages = fileResponse.data.query?.pages;
            if (!pages) return null;

            const page = Object.values(pages)[0] as any;
            const imageUrl = page.imageinfo?.[0]?.url || null;

            return imageUrl;
        } catch (error: any) {
            console.error(`⚠️ Error searching Wikimedia for "${artistName}":`, error.message);
            return null;
        }
    }

    /**
     * Use Gemini API to find artist info when free APIs fail
     * Powerful fallback for obscure artists
     */
    private async searchGeminiArtist(artistName: string): Promise<{
        image_url: string | null;
        bio: string | null;
    } | null> {
        try {
            if (!this.geminiApiKey) {
                console.log(`  ⚠️ Gemini API key not configured - skipping fallback`);
                return null;
            }

            // Validate API key format (should be at least 20 chars)
            if (this.geminiApiKey.length < 20) {
                console.log(`  ⚠️ Gemini API key looks invalid (too short) - skipping fallback`);
                return null;
            }

            console.log(`  🤖 Trying Gemini API for "${artistName}"...`);

            // Use correct Gemini API endpoint and format
            const response = await axios.post(
                `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${this.geminiApiKey}`,
                {
                    contents: [
                        {
                            parts: [
                                {
                                    text: `Provide information about the artist or band: "${artistName}"\n\nRespond with:\nBIO: [1-2 sentence bio]\nIMAGE_URL: [image URL or NOT_FOUND]\n\nIf not found:\nBIO: NOT_FOUND\nIMAGE_URL: NOT_FOUND`
                                }
                            ]
                        }
                    ],
                    generationConfig: {
                        maxOutputTokens: 200,
                        temperature: 0.1
                    }
                },
                {
                    timeout: 15000,
                    headers: {
                        'Content-Type': 'application/json'
                    }
                }
            );

            const responseText = response.data?.candidates?.[0]?.content?.parts?.[0]?.text || '';

            if (!responseText) {
                console.log(`  ⚠️ Gemini returned empty response for "${artistName}"`);
                return null;
            }

            let bio: string | null = null;
            let imageUrl: string | null = null;

            // Parse BIO
            const bioMatch = responseText.match(/BIO:\s*(.+?)(?=IMAGE_URL:|$)/is);
            if (bioMatch) {
                bio = bioMatch[1].trim();
                if (!bio || bio === 'NOT_FOUND' || bio.length < 10 || bio.length > 500) {
                    bio = null;
                }
            }

            // Parse IMAGE_URL
            const imageMatch = responseText.match(/IMAGE_URL:\s*(.+?)$/im);
            if (imageMatch) {
                const url = imageMatch[1].trim();
                if (url !== 'NOT_FOUND' && url.startsWith('http') && url.length < 500) {
                    imageUrl = url;
                }
            }

            if (bio || imageUrl) {
                console.log(`  ✅ Gemini found info for "${artistName}"`);
                return { bio, image_url: imageUrl };
            }

            console.log(`  ⚠️ Gemini found no useful info for "${artistName}"`);
            return null;
        } catch (error: any) {
            const errorMsg = error.response?.data?.error?.message || error.message;

            // Don't log 404 errors repeatedly - they're expected for invalid keys
            if (!error.message.includes('404')) {
                console.error(`⚠️ Gemini API error for "${artistName}": ${errorMsg}`);
            }
            return null;
        }
    }

    /**
     * Enrich artist with image and bio from multiple sources
     */
    async enrichArtist(artistId: number, artistName: string): Promise<void> {
        try {
            // Validate and trim artist name (max 255 chars in DB)
            const trimmedName = artistName.substring(0, 255).trim();

            if (!trimmedName) {
                console.log(`  ⚠️ Skipped: Invalid artist name`);
                return;
            }

            // Check if already enriched
            const [existingArtist]: any = await this.db.execute(
                `SELECT image_url, bio FROM artists WHERE id = $1`,
                [artistId]
            );

            if (existingArtist[0]?.image_url && existingArtist[0]?.bio) {
                console.log(`  ✓ Artist "${trimmedName}" already enriched`);
                return;
            }

            console.log(`  🔍 Enriching artist: "${trimmedName}"`);

            let imageUrl: string | null = null;
            let bio: string | null = null;

            // Step 1: Try Wikipedia first (has images + bio)
            const wikipediaInfo = await this.fetchWikipediaInfo(trimmedName);
            if (wikipediaInfo) {
                imageUrl = wikipediaInfo.image_url;
                bio = wikipediaInfo.bio;
            }

            // Step 2: If no image from Wikipedia, try Wikimedia Commons
            if (!imageUrl) {
                imageUrl = await this.searchWikimediaImage(trimmedName);
            }

            // Step 3: If still no bio, try MusicBrainz
            if (!bio) {
                const mbInfo = await this.searchMusicBrainz(trimmedName);
                if (mbInfo?.bio) {
                    bio = mbInfo.bio;
                }
            }

            // Step 4: If still missing data, try Gemini API (powerful fallback)
            if (!imageUrl || !bio) {
                const geminiInfo = await this.searchGeminiArtist(trimmedName);
                if (geminiInfo) {
                    if (!imageUrl && geminiInfo.image_url) {
                        imageUrl = geminiInfo.image_url;
                    }
                    if (!bio && geminiInfo.bio) {
                        bio = geminiInfo.bio;
                    }
                }
            }

            // Truncate bio if too long (max 1000 chars)
            if (bio && bio.length > 1000) {
                bio = bio.substring(0, 1000) + '...';
            }

            // Truncate image URL if too long (max 255 chars)
            if (imageUrl && imageUrl.length > 255) {
                console.log(`  ⚠️ Image URL too long for "${trimmedName}", skipping`);
                imageUrl = null;
            }

            // Update database
            if (imageUrl || bio) {
                await this.db.execute(
                    `UPDATE artists
                     SET image_url = COALESCE($2, image_url),
                         bio = COALESCE($3, bio),
                         updated_at = NOW()
                     WHERE id = $1`,
                    [artistId, imageUrl, bio]
                );

                const enrichedWith = [];
                if (imageUrl) enrichedWith.push('image');
                if (bio) enrichedWith.push('bio');

                console.log(`  ✅ Enriched: ${trimmedName} (${enrichedWith.join(', ')})`);
            } else {
                console.log(`  ⚠️ Could not enrich: ${trimmedName} (all sources failed)`);
            }
        } catch (error: any) {
            // Handle specific database errors
            if (error.message.includes('character varying')) {
                console.log(`  ⚠️ Artist name too long: ${artistName.substring(0, 50)}...`);
            } else {
                console.error(`Error enriching artist:`, error.message);
            }
        }
    }

    /**
     * Enrich all artists without images/bio
     * Uses FREE APIs + Gemini fallback
     */
    async enrichAllArtists(): Promise<void> {
        try {
            console.log('🎤 Starting artist enrichment (using FREE APIs + Gemini fallback)...');

            const [artists]: any = await this.db.execute(
                `SELECT id, name FROM artists
                 WHERE (image_url IS NULL OR image_url = '')
                   AND (bio IS NULL OR bio = '')
                 ORDER BY id DESC
                 LIMIT 50`
            );

            if (!artists || artists.length === 0) {
                console.log('✓ All artists are already enriched');
                return;
            }

            console.log(`Found ${artists.length} artists to enrich`);
            console.log('📚 Using: Wikipedia + Wikimedia Commons + MusicBrainz (all FREE)');
            if (this.geminiApiKey) {
                console.log('🤖 + Gemini API (for tough cases)');
            }
            console.log('💰 Cost: MINIMAL - mostly free, Gemini as fallback only\n');

            for (const artist of artists) {
                await this.enrichArtist(artist.id, artist.name);
                // Add small delay to avoid overwhelming free APIs
                await new Promise(resolve => setTimeout(resolve, 1000));
            }

            console.log(`✅ Artist enrichment completed`);
        } catch (error: any) {
            console.error('Error enriching artists:', error.message);
        }
    }
}

export default new ArtistEnricherService();

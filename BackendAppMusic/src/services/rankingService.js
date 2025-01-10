import axios from 'axios';
import db from '../model/db.js';
import YouTube from 'youtube-sr';

class RankingService {
  constructor() {
    this.ITUNES_URLS = {
      US: 'https://itunes.apple.com/us/rss/topsongs/limit=100/json',
      VN: 'https://itunes.apple.com/vn/rss/topsongs/limit=100/json'
    };
  }

  async searchYouTubeVideo(title, artist) {
    try {
      const query = `${title} ${artist} official audio`;
      console.log(`🔍 Searching YouTube for: ${query}`);
      
      // Sử dụng YouTube.default.search thay vì YouTube.search
      const videos = await YouTube.default.search(query, {
        limit: 1,
        type: 'video',
        safeSearch: true
      });

      if (videos && videos.length > 0) {
        const video = videos[0];
        console.log(`✅ Found YouTube video for: ${title}`);
        return {
          youtube_url: `https://www.youtube.com/watch?v=${video.id}`,
          youtube_thumbnail: video.thumbnail?.url || video.thumbnails?.[0]?.url
        };
      }
      console.log(`❌ No YouTube video found for: ${title}`);
      return null;
    } catch (error) {
      console.error(`YouTube search error for ${title}:`, error);
      return null;
    }
  }

  // Helper function để phân loại thể loại
  async classifyGenres(title = '', artist = '') {
    const text = `${title} ${artist}`.toLowerCase();
    const genres = [];

    // Các rule để phân loại
    const genreRules = {
      'pop': ['pop', 'nhạc trẻ'],
      'romance': ['love', 'heart', 'romantic', 'yêu', 'tình yêu', 'valentine'],
      'sad': ['sad', 'buồn', 'lonely', 'alone', 'cry', 'khóc', 'nước mắt'],
      'party': ['party', 'dance', 'club', 'remix'],
      'k-pop': ['k-pop', 'kpop', 'korean', 'korea', 'bts', 'blackpink'],
      'hip-hop': ['rap', 'hip hop', 'hip-hop', 'trap'],
      'r&b & soul': ['r&b', 'soul', 'rhythm and blues'],
      'dance & electronic': ['edm', 'electronic', 'dance'],
      'indie & alternative': ['indie', 'alternative'],
      'classical': ['classical', 'orchestra', 'symphony'],
      'folk & acoustic': ['folk', 'acoustic', 'traditional'],
      'chill': ['chill', 'relax', 'acoustic'],
      'mandopop & cantopop': ['chinese', 'mandarin', 'cantonese', '华语'],
      'feel good': ['happy', 'feel good', 'positive', 'vui'],
      'sleep': ['sleep', 'ngủ', 'relax'],
      'workout': ['workout', 'gym', 'exercise', 'tập'],
      'focus': ['focus', 'study', 'concentration', 'tập trung']
    };

    // Check từng rule
    for (const [genre, keywords] of Object.entries(genreRules)) {
      if (keywords.some(keyword => text.includes(keyword))) {
        genres.push(genre);
      }
    }

    // Thêm genre mặc định nếu không tìm thấy genre nào
    if (genres.length === 0) {
      genres.push('pop');
    }

    // Lấy genre IDs từ database
    const placeholders = genres.map(() => '?').join(',');
    const [rows] = await db.query(
      `SELECT id, name FROM Genres WHERE name IN (${placeholders})`,
      genres
    );

    return rows;
  }

  async updateRankings() {
    const connection = await db.getConnection();
    
    try {
      console.log('Starting rankings update...');

      for (const [region, url] of Object.entries(this.ITUNES_URLS)) {
        console.log(`Fetching ${region} rankings...`);
        const response = await axios.get(url);
        const songs = response.data.feed.entry;

        await connection.beginTransaction();

        try {
          await connection.execute('DELETE FROM Rankings WHERE region = ?', [region]);

          for (let i = 0; i < songs.length; i++) {
            const song = songs[i];
            const title = song['im:name'].label;
            const artistName = song['im:artist'].label;
            const imageUrl = song['im:image'][2]?.label || null;
            const previewUrl = song.link[1]?.attributes?.href || null;
            const sourceId = song.id?.attributes?.['im:id'] || null;

            console.log(`Processing ${i + 1}/${songs.length}: ${title} - ${artistName}`);

            // Tìm hoặc tạo artist
            let [artist] = await connection.execute(
              'SELECT id FROM Artists WHERE name = ?', 
              [artistName]
            );

            let artistId;
            if (artist.length === 0) {
              const [result] = await connection.execute(
                'INSERT INTO Artists (name) VALUES (?)',
                [artistName]
              );
              artistId = result.insertId;
            } else {
              artistId = artist[0].id;
            }

            // Tìm YouTube data
            const youtubeData = await this.searchYouTubeVideo(title, artistName);

            // Phân loại genres
            const genres = await this.classifyGenres(title, artistName);

            // Tìm hoặc tạo bài hát
            let [existingSong] = await connection.execute(`
              SELECT m.id 
              FROM Music m
              WHERE m.title = ? AND m.artist_id = ?
            `, [title, artistId]);

            let musicId;
            if (existingSong.length === 0) {
              const [result] = await connection.execute(`
                INSERT INTO Music (
                  title, artist_id, image_url, preview_url,
                  source, source_id, youtube_url, youtube_thumbnail
                ) VALUES (?, ?, ?, ?, 'itunes', ?, ?, ?)
              `, [
                title, 
                artistId,
                imageUrl,
                previewUrl,
                sourceId,
                youtubeData?.youtube_url || null,
                youtubeData?.youtube_thumbnail || null
              ]);
              musicId = result.insertId;

              // Thêm genres cho bài hát mới
              for (const genre of genres) {
                await connection.execute(
                  'INSERT INTO Music_Genres (music_id, genre_id) VALUES (?, ?)',
                  [musicId, genre.id]
                );
              }

              console.log(`✅ Created new song: ${title} with ${genres.length} genres`);
            } else {
              musicId = existingSong[0].id;
              
              // Cập nhật thông tin bài hát
              await connection.execute(`
                UPDATE Music 
                SET image_url = ?,
                    preview_url = ?,
                    youtube_url = ?,
                    youtube_thumbnail = ?
                WHERE id = ?
              `, [
                imageUrl,
                previewUrl,
                youtubeData?.youtube_url || null,
                youtubeData?.youtube_thumbnail || null,
                musicId
              ]);

              // Cập nhật genres
              await connection.execute('DELETE FROM Music_Genres WHERE music_id = ?', [musicId]);
              for (const genre of genres) {
                await connection.execute(
                  'INSERT INTO Music_Genres (music_id, genre_id) VALUES (?, ?)',
                  [musicId, genre.id]
                );
              }

              console.log(`✅ Updated song: ${title} with ${genres.length} genres`);
            }

            // Cập nhật ranking
            await connection.execute(`
              INSERT INTO Rankings (music_id, region, position)
              VALUES (?, ?, ?)
            `, [musicId, region, i + 1]);

            // Thêm delay để tránh rate limit
            await new Promise(resolve => setTimeout(resolve, 1500));
          }

          await connection.commit();
          console.log(`✅ Updated ${region} rankings successfully`);

        } catch (error) {
          await connection.rollback();
          throw error;
        }
      }

    } catch (error) {
      console.error('Error updating rankings:', error);
      throw error;
    } finally {
      connection.release();
    }
  }
}

export default new RankingService(); 
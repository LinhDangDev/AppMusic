import db from '../model/db.js';
import { createError } from '../utils/error.js';

class GenreService {
  async getAllGenres() {
    const [rows] = await db.execute('SELECT * FROM Genres');
    return rows;
  }

  async getGenreById(id) {
    const [rows] = await db.execute('SELECT * FROM Genres WHERE id = ?', [id]);
    return rows[0];
  }

  async getGenreSongs(genreId) {
    const [rows] = await db.execute(`
      SELECT m.*, a.name as artist_name 
      FROM Music m
      JOIN Music_Genres mg ON m.id = mg.music_id
      JOIN Artists a ON m.artist_id = a.id
      WHERE mg.genre_id = ?
    `, [genreId]);
    return rows;
  }

  async updateMusicGenres() {
    try {
      console.log('Starting automatic genre update...');

      // Lấy tất cả bài hát chưa có genre
      const [songs] = await db.execute(`
        SELECT m.id, m.title, a.name as artist_name 
        FROM Music m
        JOIN Artists a ON m.artist_id = a.id
        LEFT JOIN Music_Genres mg ON m.id = mg.music_id
        WHERE mg.music_id IS NULL
      `);

      console.log(`Found ${songs.length} songs without genres`);

      for (const song of songs) {
        try {
          // Phân tích title và artist_name để xác định genres
          const text = `${song.title} ${song.artist_name}`.toLowerCase();
          const genres = [];

          // Rules để phân loại thể loại
          const genreRules = {
            'romance': ['love', 'heart', 'romantic', 'yêu', 'tình yêu', 'valentine', 'người yêu'],
            'sad': ['sad', 'buồn', 'lonely', 'alone', 'cry', 'khóc', 'nước mắt', 'đau'],
            'party': ['party', 'dance', 'club', 'remix', 'edm', 'nhảy'],
            'k-pop': ['k-pop', 'kpop', 'korean', 'korea', 'bts', 'blackpink', 'twice'],
            'hip-hop': ['rap', 'hip hop', 'hip-hop', 'trap'],
            'r&b & soul': ['r&b', 'soul', 'rhythm and blues'],
            'pop': ['pop', 'nhạc trẻ'],
            'dance & electronic': ['edm', 'electronic', 'dance', 'dj'],
            'indie & alternative': ['indie', 'alternative'],
            'folk & acoustic': ['acoustic', 'folk', 'guitar'],
            'chill': ['chill', 'relax', 'acoustic', 'thư giãn'],
            'workout': ['workout', 'gym', 'exercise', 'tập'],
            'sleep': ['sleep', 'ngủ', 'ru', 'lullaby'],
            'focus': ['focus', 'study', 'học', 'tập trung'],
            'classical': ['classical', 'classic', 'orchestra', 'piano'],
            'mandopop & cantopop': ['chinese', 'mandarin', 'cantonese', 'trung quốc'],
            '2000s': ['2000s', 'những năm 2000'],
            '1980s': ['1980s', 'những năm 80'],
            'korean hip-hop': ['korean rap', 'k-hip hop', 'k-rap'],
            'soundtracks & musicals': ['ost', 'soundtrack', 'musical', 'nhạc phim']
          };

          // Kiểm tra từng rule
          for (const [genre, keywords] of Object.entries(genreRules)) {
            if (keywords.some(keyword => text.includes(keyword))) {
              genres.push(genre);
            }
          }

          // Thêm pop làm genre mặc định nếu không tìm thấy genre nào
          if (genres.length === 0) {
            genres.push('pop');
          }

          // Lấy genre IDs từ database
          const [genreRows] = await db.execute(
            `SELECT id FROM Genres WHERE name IN (${genres.map(() => '?').join(',')})`,
            genres
          );

          // Thêm vào bảng Music_Genres
          if (genreRows.length > 0) {
            const values = genreRows.map(genre => [song.id, genre.id]);
            await db.query(
              'INSERT INTO Music_Genres (music_id, genre_id) VALUES ?',
              [values]
            );
            console.log(`✅ Updated genres for: ${song.title}`);
          }

        } catch (error) {
          console.error(`Error updating genres for song ${song.title}:`, error);
          continue;
        }
      }

      console.log('Genre update completed successfully');
    } catch (error) {
      console.error('Error in updateMusicGenres:', error);
      throw error;
    }
  }
}

export default new GenreService(); 
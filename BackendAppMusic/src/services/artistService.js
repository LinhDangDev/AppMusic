import db from '../model/db.js';

class ArtistService {
  async getAllArtists() {
    const [rows] = await db.execute('SELECT * FROM Artists');
    return rows;
  }

  async getArtistById(id) {
    const [rows] = await db.execute('SELECT * FROM Artists WHERE id = ?', [id]);
    return rows[0];
  }

  async getArtistSongs(artistId) {
    const [rows] = await db.execute(
      'SELECT * FROM Music WHERE artist_id = ?',
      [artistId]
    );
    return rows;
  }

  async searchArtists(query) {
    const [rows] = await db.execute(
      'SELECT * FROM Artists WHERE MATCH(name) AGAINST(? IN NATURAL LANGUAGE MODE)',
      [query]
    );
    return rows;
  }
}

export default new ArtistService();

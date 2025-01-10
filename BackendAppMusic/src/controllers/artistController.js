import artistService from '../services/artistService.js';

class ArtistController {
  async getAllArtists(req, res, next) {
    try {
      const artists = await artistService.getAllArtists();
      res.json({
        status: 'success',
        data: artists
      });
    } catch (error) {
      next(error);
    }
  }

  async getArtistById(req, res, next) {
    try {
      const artist = await artistService.getArtistById(req.params.id);
      res.json({
        status: 'success',
        data: artist
      });
    } catch (error) {
      next(error);
    }
  }

  async getArtistSongs(req, res, next) {
    try {
      const songs = await artistService.getArtistSongs(req.params.id);
      res.json({
        status: 'success',
        data: songs
      });
    } catch (error) {
      next(error);
    }
  }

  async searchArtists(req, res, next) {
    try {
      const { q } = req.query;
      const artists = await artistService.searchArtists(q);
      res.json({
        status: 'success',
        data: artists
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new ArtistController();

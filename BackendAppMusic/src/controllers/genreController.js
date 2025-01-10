import genreService from '../services/genreService.js';
import { createError } from '../utils/error.js';

class GenreController {
  async getAllGenres(req, res, next) {
    try {
      const genres = await genreService.getAllGenres();
      res.json({
        status: 'success',
        data: genres
      });
    } catch (error) {
      next(error);
    }
  }

  async getGenreById(req, res, next) {
    try {
      const genre = await genreService.getGenreById(req.params.id);
      if (!genre) {
        throw createError('Genre not found', 404);
      }
      res.json({
        status: 'success',
        data: genre
      });
    } catch (error) {
      next(error);
    }
  }

  async getGenreSongs(req, res, next) {
    try {
      const songs = await genreService.getGenreSongs(req.params.id);
      res.json({
        status: 'success',
        data: songs
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new GenreController(); 
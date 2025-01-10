import express from 'express';

import genreController from '../controllers/genreController.js';
import genreService from '../services/genreService.js';

const router = express.Router();

// Lấy tất cả thể loại
router.get('/', genreController.getAllGenres);

// Lấy chi tiết thể loại
router.get('/:id',  genreController.getGenreById);

// Lấy danh sách bài hát theo thể loại
router.get('/:id/songs',  genreController.getGenreSongs);

router.post('/update-all', async (req, res) => {
  try {
    await genreService.updateMusicGenres();
    res.json({
      status: 'success',
      message: 'Genre update completed'
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

export default router;

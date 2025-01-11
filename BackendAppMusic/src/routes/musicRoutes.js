import express from 'express';
import musicController from '../controllers/musicController.js';
import syncService from '../services/syncService.js';

const router = express.Router();

router.get('/', musicController.getAllMusic);
router.get('/search', musicController.searchMusic);
router.get('/rankings/:region', musicController.getRankings);
router.get('/:id', musicController.getMusicById);

// Queue routes
router.post('/queue', musicController.addToQueue);
router.get('/queue', musicController.getQueue);
router.delete('/queue/:id', musicController.removeFromQueue);

router.post('/sync', async (req, res) => {
  try {
    console.log('Manual sync triggered');
    await syncService.syncITunesMusic();
    res.json({ success: true, message: 'Sync completed' });
  } catch (error) {
    console.error('Manual sync failed:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

export default router;
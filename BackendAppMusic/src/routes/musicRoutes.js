const express = require('express');
const router = express.Router();
const musicController = require('../controllers/musicController');
const auth = require('../middleware/auth');

router.get('/search', auth, musicController.searchSongs);
router.get('/stream/:songId', auth, musicController.getStreamingUrl);
router.post('/songs', auth, musicController.addSong);
router.post('/artists', auth, musicController.addArtist);

module.exports = router;

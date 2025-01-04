const musicService = require('../services/musicService');

exports.searchSongs = async (req, res) => {
  try {
    const { query } = req.query;
    const songs = await musicService.searchSong(query);
    res.json(songs);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to search songs' });
  }
};

exports.getStreamingUrl = async (req, res) => {
  try {
    const { songId } = req.params;
    const { userId } = req.user;

    const streamData = await musicService.getStreamingData(songId);
    
    // Lưu lịch sử nghe nhạc
    await musicService.savePlayHistory(userId, {
      songId: songId,
      title: streamData.title,
      artist: streamData.artist
    });

    res.json(streamData);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to get streaming URL' });
  }
};

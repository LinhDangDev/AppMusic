router.post('/update-youtube-urls', async (req, res) => {
  try {
    const limit = req.body.limit || 100; // Số lượng bài hát cần cập nhật
    await syncService.updateYouTubeURLs(limit);
    res.json({ message: 'YouTube URLs update started' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}); 
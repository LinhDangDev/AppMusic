import rankingService from '../services/rankingService.js';

const rankingController = {
  getRankings: async (req, res) => {
    try {
      const { region = 'VN', refresh = false } = req.query;
      
      let rankings;
      if (refresh === 'true') {
        rankings = await rankingService.updateRankings(region);
      } else {
        rankings = await rankingService.getRankingsByRegion(region);
        if (!rankings.length) {
          rankings = await rankingService.updateRankings(region);
        }
      }

      res.json({
        status: 'success',
        data: {
          region,
          rankings
        }
      });
    } catch (error) {
      console.error('Error in getRankings:', error);
      res.status(500).json({
        status: 'error',
        message: error.message
      });
    }
  }
};

export default rankingController;

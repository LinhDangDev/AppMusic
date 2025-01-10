import syncService from './syncService.js';

class InitService {
  async initializeData() {
    try {
      console.log('Starting data initialization...');
      
      // Sync iTunes data
      console.log('Syncing iTunes data...');
      await syncService.syncITunesMusic();
      
      console.log('Data initialization completed successfully');
    } catch (error) {
      console.error('Error during data initialization:', error);
      // Không throw error để app vẫn chạy được nếu sync fail
    }
  }
}

export default new InitService(); 
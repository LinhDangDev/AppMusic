import express from 'express';
import cors from 'cors';
import { connectWithRetry } from './model/db.js';
import initService from './services/initService.js';
import musicRoutes from './routes/musicRoutes.js';
import errorHandler from './middleware/errorHandler.js';
import cron from 'node-cron';
import genreService from './services/genreService.js';

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/music', musicRoutes);

// Error handling
app.use(errorHandler);

// 404 handler
app.use((req, res) => {
  console.log('404 - Route not found:', req.method, req.url);
  res.status(404).json({
    success: false,
    message: `Route ${req.method} ${req.url} not found`
  });
});

const PORT = process.env.PORT || 3000;

const startServer = async () => {
  try {
    // Kết nối database
    await connectWithRetry();

    // Khởi động server
    app.listen(PORT, () => {
      console.log(`🚀 Server is running on port ${PORT}`);
    });

    // Chạy sync data sau khi server đã khởi động
    setTimeout(async () => {
      await initService.initializeData();
      // Thêm cập nhật genres
      await genreService.updateMusicGenres();
    }, 5000);

    // Thêm cron job để cập nhật genres mỗi 6 giờ
    cron.schedule('0 */6 * * *', async () => {
      console.log('Starting scheduled genre update...');
      try {
        await genreService.updateMusicGenres();
        console.log('Scheduled genre update completed');
      } catch (error) {
        console.error('Scheduled genre update failed:', error);
      }
    });

  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (error) => {
  console.error('Unhandled Rejection:', error);
  process.exit(1);
});

startServer();

export default app;

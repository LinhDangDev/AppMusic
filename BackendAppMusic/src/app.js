import express from 'express';
import cors from 'cors';
import { connectWithRetry } from './model/db.js';
import initService from './services/initService.js';
import routes from './routes/index.js';
import errorHandler from './middleware/errorHandler.js';
import cron from 'node-cron';
import genreService from './services/genreService.js';

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Mount routes
app.use('/', routes);

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
    const server = app.listen(PORT, () => {
      console.log(`🚀 Server is running on port ${PORT}`);
    });

    server.on('error', (err) => {
      if (err.code === 'EADDRINUSE') {
        console.error(`Port ${PORT} is already in use. Please use another port.`);
        process.exit(1);
      } else {
        throw err;
      }
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

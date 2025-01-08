import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import userRoutes from './routes/userRoutes.js';
import authRoutes from './routes/authRoutes.js';
import musicRoutes from './routes/musicRoutes.js';
import playlistRoutes from './routes/playlistRoutes.js';
import errorHandler from './middleware/errorHandler.js';
import rankingService from './services/rankingService.js';
import syncService from './services/syncService.js';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/music', musicRoutes);
app.use('/api/playlists', playlistRoutes);

// Error handling
app.use(errorHandler);

// Start scheduled tasks
const startServices = async () => {
  try {
    // Bắt đầu cập nhật rankings định kỳ
    rankingService.startScheduledUpdates();
    
    // Đồng bộ dữ liệu iTunes lần đầu và thiết lập cập nhật định kỳ
    await syncService.syncITunesCharts();
    setInterval(() => {
      syncService.syncITunesCharts();
    }, 24 * 60 * 60 * 1000); // Cập nhật mỗi 24 giờ
    
    console.log('Services initialized successfully');
  } catch (error) {
    console.error('Failed to initialize services:', error);
  }
};

// Start server
app.listen(PORT, async () => {
  console.log(`Server is running on port ${PORT}`);
  await startServices();
});

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

export default app;

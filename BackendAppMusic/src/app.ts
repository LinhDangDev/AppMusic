import 'dotenv/config';
import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import { connectWithRetry } from './config/database';
import initService from './services/initService';
import routes from './routes/index';
import errorHandler from './middleware/errorHandler';
import cron from 'node-cron';
import genreService from './services/genreService';
import authService from './services/authService';

const app: Express = express();

// Middleware
app.use(cors({
    origin: process.env.CORS_ORIGIN || '*',
    credentials: true // Allow cookies
}));
app.use(express.json());
app.use(cookieParser());

// Mount routes
app.use('/', routes);

// Error handling
app.use(errorHandler);

// 404 handler
app.use((req: Request, res: Response) => {
    console.log('404 - Route not found:', req.method, req.url);
    res.status(404).json({
        success: false,
        message: `Route ${req.method} ${req.url} not found`
    });
});

const PORT = process.env.PORT || 3000;

const startServer = async (): Promise<void> => {
    try {
        // Connect to database
        await connectWithRetry();

        // Start server
        const server = app.listen(PORT, () => {
            console.log(`🚀 Server is running on port ${PORT}`);
        });

        server.on('error', (err: any) => {
            if (err.code === 'EADDRINUSE') {
                console.error(`Port ${PORT} is already in use. Please use another port.`);
                process.exit(1);
            } else {
                throw err;
            }
        });

        // Run data sync after server starts
        setTimeout(async () => {
            await initService.initializeData();
            // Update genres
            await genreService.updateMusicGenres();
        }, 5000);

        // Add cron job to update genres every 6 hours
        cron.schedule('0 */6 * * *', async () => {
            console.log('Starting scheduled genre update...');
            try {
                await genreService.updateMusicGenres();
                console.log('Scheduled genre update completed');
            } catch (error) {
                console.error('Scheduled genre update failed:', error);
            }
        });

        // Cleanup expired tokens daily at 3:00 AM
        cron.schedule('0 3 * * *', async () => {
            console.log('Starting expired tokens cleanup...');
            try {
                await authService.cleanupExpiredTokens();
                console.log('Expired tokens cleanup completed');
            } catch (error) {
                console.error('Token cleanup failed:', error);
            }
        });

    } catch (error) {
        console.error('Failed to start server:', error);
        process.exit(1);
    }
};

// Handle uncaught exceptions
process.on('uncaughtException', (error: Error) => {
    console.error('Uncaught Exception:', error);
    process.exit(1);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (error: any) => {
    console.error('Unhandled Rejection:', error);
    process.exit(1);
});

startServer();

export default app;

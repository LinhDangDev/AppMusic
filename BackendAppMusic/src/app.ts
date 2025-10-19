import 'dotenv/config';
import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import { connectWithRetry } from './config/database';
import initService from './services/initService';
import iTunesService from './services/iTunesService';
import artistEnricherService from './services/artistEnricherService';
import routes from './routes/index';
import errorHandler from './middleware/errorHandler';
import cron from 'node-cron';
import genreService from './services/genreService';
import authService from './services/authService';
import swaggerUi from 'swagger-ui-express';
import swaggerJsdoc from 'swagger-jsdoc';

const app: Express = express();

// Swagger configuration
const swaggerOptions = {
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'Musium - Music Streaming API',
            version: '1.0.0',
            description: 'Comprehensive API documentation for Musium music streaming application',
            contact: {
                name: 'API Support',
                email: 'support@musium.app'
            },
            license: {
                name: 'MIT',
                url: 'https://opensource.org/licenses/MIT'
            }
        },
        servers: [
            {
                url: `http://localhost:${process.env.PORT || 3000}`,
                description: 'Development Server'
            },
            {
                url: 'https://api.musium.app',
                description: 'Production Server'
            }
        ],
        components: {
            securitySchemes: {
                bearerAuth: {
                    type: 'http',
                    scheme: 'bearer',
                    bearerFormat: 'JWT'
                }
            },
            schemas: {
                User: {
                    type: 'object',
                    properties: {
                        id: { type: 'number' },
                        email: { type: 'string' },
                        name: { type: 'string' },
                        profile_pic_url: { type: 'string' },
                        is_premium: { type: 'boolean' },
                        is_email_verified: { type: 'boolean' },
                        created_at: { type: 'string', format: 'date-time' }
                    }
                },
                Music: {
                    type: 'object',
                    properties: {
                        id: { type: 'number' },
                        title: { type: 'string' },
                        artist_id: { type: 'number' },
                        artist_name: { type: 'string' },
                        album: { type: 'string' },
                        duration: { type: 'number' },
                        youtube_url: { type: 'string' },
                        youtube_thumbnail: { type: 'string' },
                        play_count: { type: 'number' },
                        created_at: { type: 'string', format: 'date-time' }
                    }
                },
                Artist: {
                    type: 'object',
                    properties: {
                        id: { type: 'number' },
                        name: { type: 'string' },
                        bio: { type: 'string' },
                        image_url: { type: 'string' },
                        created_at: { type: 'string', format: 'date-time' }
                    }
                },
                Genre: {
                    type: 'object',
                    properties: {
                        id: { type: 'number' },
                        name: { type: 'string' },
                        description: { type: 'string' },
                        image_url: { type: 'string' }
                    }
                },
                Playlist: {
                    type: 'object',
                    properties: {
                        id: { type: 'number' },
                        user_id: { type: 'number' },
                        name: { type: 'string' },
                        description: { type: 'string' },
                        is_shared: { type: 'boolean' },
                        created_at: { type: 'string', format: 'date-time' }
                    }
                },
                Error: {
                    type: 'object',
                    properties: {
                        success: { type: 'boolean' },
                        status: { type: 'number' },
                        message: { type: 'string' },
                        error: {
                            type: 'object',
                            properties: {
                                code: { type: 'string' },
                                details: { type: 'string' }
                            }
                        }
                    }
                }
            }
        },
        security: [
            {
                bearerAuth: []
            }
        ]
    },
    apis: ['./src/routes/*.ts', './src/controllers/*.ts']
};

const specs = swaggerJsdoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs, {
    swaggerOptions: {
        persistAuthorization: true
    }
}));

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

            // Sync iTunes rankings on startup
            console.log('📱 Starting iTunes rankings sync on startup...');
            try {
                await iTunesService.syncItunesRankings(['us', 'vn'], 50);
                console.log('✅ iTunes sync completed on startup');
            } catch (error) {
                console.error('⚠️ iTunes sync failed on startup:', error);
            }

            // ✅ NEW: Enrich artists with images and bio
            console.log('🎤 Starting artist enrichment on startup...');
            try {
                await artistEnricherService.enrichAllArtists();
                console.log('✅ Artist enrichment completed on startup');
            } catch (error) {
                console.error('⚠️ Artist enrichment failed on startup:', error);
            }
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

        // Add cron job to sync iTunes rankings every 12 hours
        cron.schedule('0 */12 * * *', async () => {
            console.log('📱 Starting scheduled iTunes rankings sync...');
            try {
                await iTunesService.syncItunesRankings(['us', 'vn'], 50);
                console.log('✅ Scheduled iTunes sync completed');
            } catch (error) {
                console.error('⚠️ Scheduled iTunes sync failed:', error);
            }
        });

        // ✅ NEW: Add cron job to enrich artists daily
        cron.schedule('0 2 * * *', async () => {
            console.log('🎤 Starting scheduled artist enrichment...');
            try {
                await artistEnricherService.enrichAllArtists();
                console.log('✅ Scheduled artist enrichment completed');
            } catch (error) {
                console.error('⚠️ Scheduled artist enrichment failed:', error);
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

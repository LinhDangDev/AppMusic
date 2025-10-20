import { Request, Response } from 'express';
import { MusicService } from '../services/musicService';
import { ApiResponse, ErrorCode } from '../types/api.types';
import { Pool } from 'pg';

export class MusicController {
    private musicService: MusicService;

    constructor(pool: Pool) {
        this.musicService = new MusicService(pool);
    }

    /**
     * Get all music with pagination and filtering
     * GET /api/v1/music
     */
    async getMusic(req: Request, res: Response): Promise<void> {
        try {
            const page = parseInt(req.query.page as string) || 1;
            const limit = parseInt(req.query.limit as string) || 20;
            const sort = (req.query.sort as string) || 'created_at';
            const order = (req.query.order as string) || 'desc';
            const genreId = req.query.genreId ? parseInt(req.query.genreId as string) : undefined;
            const artistId = req.query.artistId ? parseInt(req.query.artistId as string) : undefined;

            const result = await this.musicService.getMusic(page, limit, sort, order as 'asc' | 'desc', genreId, artistId);

            res.status(200).json({
                success: true,
                data: result.data,
                pagination: result.pagination,
                message: 'Music list retrieved successfully',
                statusCode: 200,
            });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    /**
     * Get music by ID
     * GET /api/v1/music/:id
     */
    async getMusicById(req: Request, res: Response): Promise<void> {
        try {
            const musicId = parseInt(req.params.id);

            if (!musicId) {
                res.status(400).json({
                    success: false,
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Invalid music ID',
                    statusCode: 400,
                });
                return;
            }

            const music = await this.musicService.getMusicById(musicId);

            res.status(200).json({
                success: true,
                data: music,
                message: 'Music retrieved successfully',
                statusCode: 200,
            });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    /**
     * Search music
     * GET /api/v1/music/search
     */
    async searchMusic(req: Request, res: Response): Promise<void> {
        try {
            const query = req.query.q as string;
            const limit = parseInt(req.query.limit as string) || 20;
            const type = (req.query.type as string) || 'all';

            if (!query) {
                res.status(400).json({
                    success: false,
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Search query is required',
                    statusCode: 400,
                });
                return;
            }

            const results = await this.musicService.searchMusic(query, limit, type as 'title' | 'artist' | 'album');

            res.status(200).json({
                success: true,
                data: results,
                message: 'Search completed successfully',
                statusCode: 200,
            });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    /**
     * Create music (admin only)
     * POST /api/v1/music
     */
    async createMusic(req: Request, res: Response): Promise<void> {
        try {
            const { title, artistId, album, duration, releaseDate, youtubeId, imageUrl } = req.body;

            if (!title || !artistId) {
                res.status(400).json({
                    success: false,
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Title and artist ID are required',
                    statusCode: 400,
                });
                return;
            }

            const music = await this.musicService.createMusic({
                title,
                artist_id: artistId,
                album,
                duration,
                release_date: releaseDate,
                youtube_id: youtubeId,
                image_url: imageUrl,
            });

            res.status(201).json({
                success: true,
                data: music,
                message: 'Music created successfully',
                statusCode: 201,
            });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    /**
     * Update music (admin only)
     * PUT /api/v1/music/:id
     */
    async updateMusic(req: Request, res: Response): Promise<void> {
        try {
            const musicId = parseInt(req.params.id);
            const updateData = req.body;

            if (!musicId) {
                res.status(400).json({
                    success: false,
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Invalid music ID',
                    statusCode: 400,
                });
                return;
            }

            const updatedMusic = await this.musicService.updateMusic(musicId, updateData);

            res.status(200).json({
                success: true,
                data: updatedMusic,
                message: 'Music updated successfully',
                statusCode: 200,
            });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    /**
     * Delete music (admin only)
     * DELETE /api/v1/music/:id
     */
    async deleteMusic(req: Request, res: Response): Promise<void> {
        try {
            const musicId = parseInt(req.params.id);

            if (!musicId) {
                res.status(400).json({
                    success: false,
                    code: ErrorCode.VALIDATION_ERROR,
                    message: 'Invalid music ID',
                    statusCode: 400,
                });
                return;
            }

            await this.musicService.deleteMusic(musicId);

            res.status(200).json({
                success: true,
                message: 'Music deleted successfully',
                statusCode: 200,
            });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    private handleError(error: any, res: Response): void {
        const code = error.code || ErrorCode.INTERNAL_ERROR;
        const statusCode = error.statusCode || 500;
        const message = error.message || 'Internal server error';

        res.status(statusCode).json({
            success: false,
            code,
            message,
            statusCode,
        });
    }
}

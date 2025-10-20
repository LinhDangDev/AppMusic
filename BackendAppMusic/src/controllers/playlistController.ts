import { Request, Response } from 'express';
import { PlaylistService } from '../services/playlistService';
import { ApiResponse, ErrorCode } from '../types/api.types';
import { Pool } from 'pg';

export class PlaylistController {
    private playlistService: PlaylistService;

    constructor(pool: Pool) {
        this.playlistService = new PlaylistService(pool);
    }

    async getUserPlaylists(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).userId;
            if (!userId) {
                res.status(401).json({ success: false, code: ErrorCode.UNAUTHORIZED, message: 'Unauthorized', statusCode: 401 });
                return;
            }
            const playlists = await this.playlistService.getUserPlaylists(userId);
            res.status(200).json({ success: true, data: playlists, message: 'Playlists retrieved', statusCode: 200 });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    async getPlaylistById(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).userId;
            const playlistId = parseInt(req.params.id);
            if (!userId) {
                res.status(401).json({ success: false, code: ErrorCode.UNAUTHORIZED, message: 'Unauthorized', statusCode: 401 });
                return;
            }
            const playlist = await this.playlistService.getPlaylistById(playlistId);
            res.status(200).json({ success: true, data: playlist, message: 'Playlist retrieved', statusCode: 200 });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    async createPlaylist(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).userId;
            const { name, description } = req.body;
            if (!userId || !name) {
                res.status(400).json({ success: false, code: ErrorCode.VALIDATION_ERROR, message: 'User ID and name required', statusCode: 400 });
                return;
            }
            const playlist = await this.playlistService.createPlaylist(name, description);
            res.status(201).json({ success: true, data: playlist, message: 'Playlist created', statusCode: 201 });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    async updatePlaylist(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).userId;
            const playlistId = parseInt(req.params.id);
            const { name, description } = req.body;
            if (!userId) {
                res.status(401).json({ success: false, code: ErrorCode.UNAUTHORIZED, message: 'Unauthorized', statusCode: 401 });
                return;
            }
            const playlist = await this.playlistService.updatePlaylist(playlistId, name, description);
            res.status(200).json({ success: true, data: playlist, message: 'Playlist updated', statusCode: 200 });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    async deletePlaylist(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).userId;
            const playlistId = parseInt(req.params.id);
            if (!userId) {
                res.status(401).json({ success: false, code: ErrorCode.UNAUTHORIZED, message: 'Unauthorized', statusCode: 401 });
                return;
            }
            await this.playlistService.deletePlaylist(playlistId, userId);
            res.status(200).json({ success: true, message: 'Playlist deleted', statusCode: 200 });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    async addSong(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).userId;
            const playlistId = parseInt(req.params.id);
            const { musicId } = req.body;
            if (!userId || !musicId) {
                res.status(400).json({ success: false, code: ErrorCode.VALIDATION_ERROR, message: 'User ID and music ID required', statusCode: 400 });
                return;
            }
            const result = await this.playlistService.addSong(playlistId, musicId, userId);
            res.status(201).json({ success: true, data: result, message: 'Song added to playlist', statusCode: 201 });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    async removeSong(req: Request, res: Response): Promise<void> {
        try {
            const userId = (req as any).userId;
            const playlistId = parseInt(req.params.id);
            const musicId = parseInt(req.params.musicId);
            if (!userId) {
                res.status(401).json({ success: false, code: ErrorCode.UNAUTHORIZED, message: 'Unauthorized', statusCode: 401 });
                return;
            }
            await this.playlistService.removeSong(playlistId, musicId, userId);
            res.status(200).json({ success: true, message: 'Song removed from playlist', statusCode: 200 });
        } catch (error: any) {
            this.handleError(error, res);
        }
    }

    private handleError(error: any, res: Response): void {
        const code = error.code || ErrorCode.INTERNAL_ERROR;
        const statusCode = error.statusCode || 500;
        res.status(statusCode).json({ success: false, code, message: error.message, statusCode });
    }
}

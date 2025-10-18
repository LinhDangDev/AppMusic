import { Request, Response, NextFunction } from 'express';
import playlistService from '../services/playlistService';

class PlaylistController {
    async getUserPlaylists(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const userId = (req as any).user?.id;
            const playlists = await playlistService.getUserPlaylists(userId);
            res.json({ success: true, data: playlists });
        } catch (error) {
            next(error);
        }
    }

    async createPlaylist(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { name, description } = req.body;
            const userId = (req as any).user?.id;
            const playlist = await playlistService.createPlaylist(name, description, userId);
            res.status(201).json({ success: true, data: playlist });
        } catch (error) {
            next(error);
        }
    }

    async getPlaylistById(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const playlistId = parseInt(req.params.id);
            const playlist = await playlistService.getPlaylistById(playlistId);
            res.json({ success: true, data: playlist });
        } catch (error) {
            next(error);
        }
    }

    async updatePlaylist(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const playlistId = parseInt(req.params.id);
            const updated = await playlistService.updatePlaylist(playlistId, req.body);
            res.json({ success: true, data: updated });
        } catch (error) {
            next(error);
        }
    }

    async deletePlaylist(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const playlistId = parseInt(req.params.id);
            await playlistService.deletePlaylist(playlistId);
            res.json({ success: true, message: 'Playlist deleted' });
        } catch (error) {
            next(error);
        }
    }

    async getPlaylistSongs(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const playlistId = parseInt(req.params.id);
            const result = await playlistService.getPlaylistSongs(playlistId);
            res.json({ success: true, data: result });
        } catch (error) {
            next(error);
        }
    }

    async addSongToPlaylist(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const playlistId = parseInt(req.params.id);
            const { musicId } = req.body;
            await playlistService.addSongToPlaylist(playlistId, musicId);
            res.json({ success: true, message: 'Song added' });
        } catch (error) {
            next(error);
        }
    }

    async removeSongFromPlaylist(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const playlistId = parseInt(req.params.id);
            const musicId = parseInt(req.params.musicId);
            await playlistService.removeSongFromPlaylist(playlistId, musicId);
            res.json({ success: true, message: 'Song removed' });
        } catch (error) {
            next(error);
        }
    }
}

export default new PlaylistController();

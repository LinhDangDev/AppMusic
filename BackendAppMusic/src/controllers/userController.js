import userService from '../services/userService.js';
import { createError } from '../utils/error.js';

class UserController {
  async getCurrentUser(req, res, next) {
    try {
      const user = await userService.getUserById(req.user.uid);
      res.json({
        status: 'success',
        data: user
      });
    } catch (error) {
      next(error);
    }
  }

  async updateUser(req, res, next) {
    try {
      const { name, avatar } = req.body;
      const updatedUser = await userService.updateUser(req.user.uid, { name, avatar });
      res.json({
        status: 'success',
        data: updatedUser
      });
    } catch (error) {
      next(error);
    }
  }

  async changePassword(req, res, next) {
    try {
      const { currentPassword, newPassword } = req.body;
      if (!currentPassword || !newPassword) {
        throw createError('Current password and new password are required', 400);
      }
      await userService.changePassword(req.user.uid, currentPassword, newPassword);
      res.json({
        status: 'success',
        message: 'Password updated successfully'
      });
    } catch (error) {
      next(error);
    }
  }

  async getPlayHistory(req, res, next) {
    try {
      const history = await userService.getPlayHistory(req.user.uid);
      res.json({
        status: 'success',
        data: history
      });
    } catch (error) {
      next(error);
    }
  }

  async getFavorites(req, res, next) {
    try {
      const favorites = await userService.getFavorites(req.user.uid);
      res.json({
        status: 'success',
        data: favorites
      });
    } catch (error) {
      next(error);
    }
  }

  async addToFavorites(req, res, next) {
    try {
      const { musicId } = req.params;
      await userService.addToFavorites(req.user.uid, musicId);
      res.status(201).json({
        status: 'success',
        message: 'Added to favorites'
      });
    } catch (error) {
      next(error);
    }
  }

  async removeFromFavorites(req, res, next) {
    try {
      const { musicId } = req.params;
      await userService.removeFromFavorites(req.user.uid, musicId);
      res.status(204).send();
    } catch (error) {
      next(error);
    }
  }

  async getUserById(req, res, next) {
    try {
      const user = await userService.getUserById(req.params.id);
      if (!user) {
        throw createError('User not found', 404);
      }
      res.json({
        status: 'success',
        data: user
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new UserController();

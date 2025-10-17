import authService from '../services/authService.js';
import { createError } from '../utils/error.js';

/**
 * Middleware để verify JWT access token
 */
export const authenticateToken = async (req, res, next) => {
  try {
    // Get token from header
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      throw createError('Access token is required', 401);
    }

    // Verify token
    const decoded = authService.verifyAccessToken(token);

    // Attach user data to request
    req.user = {
      id: decoded.id,
      email: decoded.email,
      name: decoded.name,
      is_premium: decoded.is_premium
    };

    next();
  } catch (error) {
    next(error);
  }
};

/**
 * Middleware để verify premium user
 */
export const requirePremium = async (req, res, next) => {
  try {
    if (!req.user) {
      throw createError('Authentication required', 401);
    }

    if (!req.user.is_premium) {
      throw createError('Premium subscription required', 403);
    }

    next();
  } catch (error) {
    next(error);
  }
};

/**
 * Optional authentication - không throw error nếu không có token
 */
export const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (token) {
      try {
        const decoded = authService.verifyAccessToken(token);
        req.user = {
          id: decoded.id,
          email: decoded.email,
          name: decoded.name,
          is_premium: decoded.is_premium
        };
      } catch (error) {
        // Ignore token errors for optional auth
        req.user = null;
      }
    } else {
      req.user = null;
    }

    next();
  } catch (error) {
    next(error);
  }
};

/**
 * Get client IP address
 */
export const getClientIp = (req) => {
  return (
    req.headers['x-forwarded-for']?.split(',')[0] ||
    req.headers['x-real-ip'] ||
    req.connection.remoteAddress ||
    req.socket.remoteAddress ||
    'unknown'
  );
};

/**
 * Get user agent
 */
export const getUserAgent = (req) => {
  return req.headers['user-agent'] || 'unknown';
};

export default {
  authenticateToken,
  requirePremium,
  optionalAuth,
  getClientIp,
  getUserAgent
};


import { Request, Response, NextFunction } from 'express';
import authService from '../services/authService';
import { createError } from '../utils/error';

/**
 * Extend Express Request to include user
 */
declare global {
    namespace Express {
        interface Request {
            user?: { id: number; email: string; name: string; is_premium: boolean };
        }
    }
}

/**
 * Verify JWT access token - Required authentication
 */
export const authenticateToken = async (
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> => {
    try {
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(' ')[1];

        if (!token) {
            throw createError('Access token is required', 401);
        }

        const decoded = authService.verifyAccessToken(token);
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
 * Require premium subscription
 */
export const requirePremium = async (
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> => {
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
 * Optional authentication - doesn't throw if no token
 */
export const optionalAuth = async (
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> => {
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
                req.user = undefined;
            }
        } else {
            req.user = undefined;
        }

        next();
    } catch (error) {
        next(error);
    }
};

/**
 * Get client IP address
 */
export const getClientIp = (req: Request): string => {
    return (
        (req.headers['x-forwarded-for'] as string)?.split(',')[0] ||
        (req.headers['x-real-ip'] as string) ||
        req.socket.remoteAddress ||
        'unknown'
    );
};

/**
 * Get user agent
 */
export const getUserAgent = (req: Request): string => {
    return (req.headers['user-agent'] as string) || 'unknown';
};

export default {
    authenticateToken,
    requirePremium,
    optionalAuth,
    getClientIp,
    getUserAgent
};

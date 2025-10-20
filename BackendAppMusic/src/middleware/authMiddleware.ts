import { Request, Response, NextFunction } from 'express';
import * as jwt from 'jsonwebtoken';
import { ErrorCode, ApiResponse } from '../types/api.types';

export const authMiddleware = (
    req: Request,
    res: Response,
    next: NextFunction
): void => {
    try {
        const token = req.headers.authorization?.split(' ')[1];

        if (!token) {
            res.status(401).json({
                success: false,
                code: ErrorCode.UNAUTHORIZED,
                message: 'No token provided',
                statusCode: 401,
            } as ApiResponse);
            return;
        }

        const decoded = jwt.verify(
            token,
            process.env.JWT_SECRET || 'your-super-secret-jwt-key'
        ) as any;

        (req as any).userId = decoded.id;
        (req as any).user = decoded;

        next();
    } catch (error: any) {
        res.status(401).json({
            success: false,
            code: ErrorCode.UNAUTHORIZED,
            message: error.message === 'jwt expired' ? 'Token expired' : 'Invalid token',
            statusCode: 401,
        } as ApiResponse);
    }
};

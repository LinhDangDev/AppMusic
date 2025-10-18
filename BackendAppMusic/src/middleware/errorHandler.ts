import { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/error';

/**
 * Global error handler middleware
 */
const errorHandler = (
    err: any,
    req: Request,
    res: Response,
    next: NextFunction
): void => {
    err.statusCode = err.statusCode || 500;
    err.status = err.status || 'error';

    // Log error with context
    console.error('ERROR:', {
        path: req.path,
        method: req.method,
        error: err.message,
        statusCode: err.statusCode,
        stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
    });

    if (process.env.NODE_ENV === 'development') {
        // Development: Send full error details
        res.status(err.statusCode).json({
            status: err.status,
            message: err.message,
            error: err,
            stack: err.stack
        });
    } else {
        // Production: Hide sensitive details
        if (err instanceof AppError) {
            res.status(err.statusCode).json({
                status: err.status,
                message: err.message
            });
        } else {
            res.status(500).json({
                status: 'error',
                message: 'Something went wrong!'
            });
        }
    }
};

export default errorHandler;

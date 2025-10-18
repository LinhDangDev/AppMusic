/**
 * Custom Application Error class
 */
export class AppError extends Error {
    public statusCode: number;
    public status: string;

    constructor(message: string, statusCode: number = 500) {
        super(message);
        this.statusCode = statusCode;
        this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
        Error.captureStackTrace(this, this.constructor);
    }
}

/**
 * Create a new AppError instance
 */
export const createError = (message: string, statusCode: number = 500): AppError => {
    return new AppError(message, statusCode);
};

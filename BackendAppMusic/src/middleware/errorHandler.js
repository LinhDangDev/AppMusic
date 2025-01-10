import { AppError } from '../utils/error.js';

const errorHandler = (err, req, res, next) => {
  err.statusCode = err.statusCode || 500;
  err.status = err.status || 'error';

  // Log error
  console.error('ERROR:', {
    path: req.path,
    method: req.method,
    error: err.message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });

  if (process.env.NODE_ENV === 'development') {
    res.status(err.statusCode).json({
      status: err.status,
      error: err,
      message: err.message,
      stack: err.stack
    });
  } else {
    // Production error response
    if (err instanceof AppError) {
      res.status(err.statusCode).json({
        status: err.status,
        message: err.message
      });
    } else {
      // Don't leak error details in production
      res.status(500).json({
        status: 'error',
        message: 'Something went wrong!'
      });
    }
  }
};

export default errorHandler;

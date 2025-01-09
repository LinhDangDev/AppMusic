import admin from '../config/firebase.js';
import { createError } from '../utils/error.js';

const authMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw createError('No token provided', 401);
    }

    const token = authHeader.split(' ')[1];
    
    try {
      // Thử verify ID token
      const decodedToken = await admin.auth().verifyIdToken(token);
      req.user = {
        uid: decodedToken.uid,
        email: decodedToken.email
      };
      next();
    } catch (idTokenError) {
      // Nếu verify ID token thất bại, thử verify custom token
      try {
        const customTokenResult = await admin.auth().verifyCustomToken(token);
        req.user = {
          uid: customTokenResult.uid,
          email: customTokenResult.email
        };
        next();
      } catch (customTokenError) {
        throw createError('Invalid token', 401);
      }
    }
  } catch (error) {
    next(error);
  }
};

export default authMiddleware;

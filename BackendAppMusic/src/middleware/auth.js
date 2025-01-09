import { auth } from '../config/firebase.js';

const authMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    const token = authHeader.split(' ')[1];
    
    try {
      // Verify ID token
      const decodedToken = await auth.verifySessionCookie(token);
      req.user = decodedToken;
      next();
    } catch (error) {
      // Nếu session cookie không hợp lệ, thử verify ID token
      try {
        const decodedToken = await auth.verifyIdToken(token);
        req.user = decodedToken;
        next();
      } catch (idTokenError) {
        console.error('Token verification failed:', idTokenError);
        return res.status(401).json({ message: 'Invalid token' });
      }
    }
  } catch (error) {
    console.error('Auth error:', error);
    res.status(401).json({ message: 'Unauthorized' });
  }
};

export default authMiddleware;

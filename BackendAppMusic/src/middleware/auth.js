/**
 * DEPRECATED: File này không còn được sử dụng
 * Vui lòng sử dụng authMiddleware.js thay thế
 *
 * Import: import { authenticateToken } from '../middleware/authMiddleware.js';
 */

import { authenticateToken } from './authMiddleware.js';

// Export để backward compatibility
export default authenticateToken;

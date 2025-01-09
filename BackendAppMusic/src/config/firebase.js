import admin from 'firebase-admin';
import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Đường dẫn tới service account key
const serviceAccount = path.join(__dirname, '../../app-mussic-firebase-adminsdk-vzz2e-e5ed1b24b5.json');

// Khởi tạo Firebase Admin SDK
try {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log('Firebase initialized successfully');
} catch (error) {
  console.warn('Firebase initialization warning:', error.message);
}

// Export auth service
export const auth = admin.auth();
export default admin;

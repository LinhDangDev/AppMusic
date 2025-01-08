import admin from 'firebase-admin';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Đường dẫn tới file service account key của bạn
const serviceAccount = path.join(__dirname, '../../app-mussic-firebase-adminsdk-vzz2e-e5ed1b24b5.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function createTestToken() {
  try {
    // Tạo một test user nếu chưa có
    let userRecord;
    const testEmail = 'test@example.com';
    const testPassword = 'password123';

    try {
      // Thử lấy user nếu đã tồn tại
      userRecord = await admin.auth().getUserByEmail(testEmail);
    } catch (error) {
      // Nếu user chưa tồn tại, tạo mới
      userRecord = await admin.auth().createUser({
        email: testEmail,
        password: testPassword,
        emailVerified: true,
        displayName: 'Test User'
      });
      console.log('Created new test user:', userRecord.uid);
    }

    // Tạo custom token
    const customToken = await admin.auth().createCustomToken(userRecord.uid);
    console.log('\n=== TEST USER CREDENTIALS ===');
    console.log('Email:', testEmail);
    console.log('Password:', testPassword);
    console.log('User ID:', userRecord.uid);
    console.log('\n=== CUSTOM TOKEN ===');
    console.log(customToken);

    // Tạo ID token
    const idToken = await admin.auth().createCustomToken(userRecord.uid, {
      premium: true,
      role: 'user'
    });
    console.log('\n=== ID TOKEN ===');
    console.log(idToken);

    // Thêm thông tin hữu ích
    console.log('\n=== USAGE ===');
    console.log('Add this to your request headers:');
    console.log('Authorization: Bearer <token>');

  } catch (error) {
    console.error('Error creating test token:', error);
  } finally {
    // Đóng kết nối Firebase Admin
    await admin.app().delete();
  }
}

// Chạy function
createTestToken();

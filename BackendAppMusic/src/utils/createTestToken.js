import admin from '../config/firebase.js';

export async function createTestToken(uid) {
    try {
        // Tạo custom token
        const customToken = await admin.auth().createCustomToken(uid);
        
        // Exchange custom token for ID token
        const signInResult = await admin.auth().signInWithCustomToken(customToken);
        const idToken = await signInResult.user.getIdToken();
        
        return idToken;
    } catch (error) {
        console.error('Error creating test token:', error);
        throw error;
    }
} 
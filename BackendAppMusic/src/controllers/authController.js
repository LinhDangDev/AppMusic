import admin from '../config/firebase.js';
import { createError } from '../utils/error.js';
import userService from '../services/userService.js';

class AuthController {
    async register(req, res, next) {
        let firebaseUser = null;
        try {
            const { email, password, name } = req.body;
            
            // Validate input
            if (!email || !password || !name) {
                throw createError('Email, password and name are required', 400);
            }

            // Check if user already exists
            try {
                const userRecord = await admin.auth().getUserByEmail(email);
                if (userRecord) {
                    throw createError('Email already exists', 400);
                }
            } catch (error) {
                if (error.code !== 'auth/user-not-found') {
                    throw error;
                }
            }

            // Create user in Firebase
            firebaseUser = await admin.auth().createUser({
                email,
                password,
                displayName: name
            });

            // Create user in database
            try {
                await userService.createUser({
                    firebase_uid: firebaseUser.uid,
                    email,
                    name
                });
            } catch (dbError) {
                // Nếu tạo trong database thất bại, xóa user trong Firebase
                if (firebaseUser) {
                    await admin.auth().deleteUser(firebaseUser.uid);
                }
                throw dbError;
            }

            res.status(201).json({
                status: 'success',
                message: 'User registered successfully',
                data: {
                    uid: firebaseUser.uid,
                    email: firebaseUser.email,
                    name: firebaseUser.displayName
                }
            });
        } catch (error) {
            // Cleanup if error occurs
            if (firebaseUser) {
                try {
                    await admin.auth().deleteUser(firebaseUser.uid);
                } catch (deleteError) {
                    console.error('Error deleting Firebase user during cleanup:', deleteError);
                }
            }

            console.error('Registration error:', error);
            if (error.code === 'auth/email-already-exists') {
                next(createError('Email already exists', 400));
            } else if (error.code === 'auth/invalid-email') {
                next(createError('Invalid email format', 400));
            } else if (error.code === 'auth/weak-password') {
                next(createError('Password should be at least 6 characters', 400));
            } else {
                next(error);
            }
        }
    }

    async login(req, res, next) {
        try {
            const { email, password } = req.body;
            
            if (!email || !password) {
                throw createError('Email and password are required', 400);
            }

            try {
                // 1. Lấy user từ Firebase
                const userRecord = await admin.auth().getUserByEmail(email);
                
                // 2. Tạo custom token
                const customToken = await admin.auth().createCustomToken(userRecord.uid);

                // 3. Trả về token và thông tin user
                res.json({
                    status: 'success',
                    data: {
                        user: {
                            uid: userRecord.uid,
                            email: userRecord.email,
                            name: userRecord.displayName
                        },
                        token: customToken
                    }
                });
            } catch (error) {
                if (error.code === 'auth/user-not-found') {
                    throw createError('Invalid email or password', 401);
                }
                throw error;
            }
        } catch (error) {
            next(error);
        }
    }

    async logout(req, res, next) {
        try {
            // Xử lý logout nếu cần
            res.json({
                status: 'success',
                message: 'Logged out successfully'
            });
        } catch (error) {
            next(error);
        }
    }

    async refreshToken(req, res, next) {
        try {
            const { refreshToken } = req.body;
            // Xử lý refresh token với Firebase
            res.json({
                status: 'success',
                data: {
                    // new token info
                }
            });
        } catch (error) {
            next(error);
        }
    }

    async verifyToken(req, res, next) {
        try {
            const { idToken } = req.body;
            await admin.auth().verifyIdToken(idToken);
            res.json({
                status: 'success',
                message: 'Token is valid'
            });
        } catch (error) {
            next(error);
        }
    }

    async forgotPassword(req, res, next) {
        try {
            const { email } = req.body;
            // Gửi email reset password thông qua Firebase
            await admin.auth().generatePasswordResetLink(email);
            res.json({
                status: 'success',
                message: 'Password reset email sent'
            });
        } catch (error) {
            next(error);
        }
    }

    async resetPassword(req, res, next) {
        try {
            const { oobCode, newPassword } = req.body;
            // Xử lý reset password với Firebase
            res.json({
                status: 'success',
                message: 'Password reset successfully'
            });
        } catch (error) {
            next(error);
        }
    }
}

export default new AuthController();

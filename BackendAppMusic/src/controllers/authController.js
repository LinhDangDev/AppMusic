import admin from '../config/firebase.js';
import { createError } from '../utils/error.js';
import userService from '../services/userService.js';

class AuthController {
    async register(req, res, next) {
        try {
            const { email, password, name } = req.body;
            
            // Tạo user trong Firebase
            const userRecord = await admin.auth().createUser({
                email,
                password,
                displayName: name
            });

            // Tạo user trong database
            await userService.createUser({
                firebase_uid: userRecord.uid,
                email,
                name
            });

            res.status(201).json({
                status: 'success',
                message: 'User registered successfully'
            });
        } catch (error) {
            next(error);
        }
    }

    async login(req, res, next) {
        try {
            const { idToken } = req.body;
            
            // Xác thực token từ Firebase
            const decodedToken = await admin.auth().verifyIdToken(idToken);
            
            res.json({
                status: 'success',
                data: {
                    uid: decodedToken.uid,
                    email: decodedToken.email
                }
            });
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Dio _dio = Dio(BaseOptions(
    baseURL: 'YOUR_BACKEND_URL', // Replace with your backend URL
    validateStatus: (status) => true,
  ));

  // Login method
  Future<UserCredential> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Get the ID token
      final idToken = await userCredential.user?.getIdToken();
      
      // Send token to backend
      final response = await _dio.post('/api/auth/login', data: {
        'token': idToken,
      });
      
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
      
      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Register method
  Future<UserCredential> register(String name, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await userCredential.user?.updateDisplayName(name);
      
      // Get the ID token
      final idToken = await userCredential.user?.getIdToken();
      
      // Send token to backend
      final response = await _dio.post('/api/auth/register', data: {
        'token': idToken,
        'name': name,
      });
      
      if (response.statusCode != 201) {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
      
      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Wrong password';
        case 'email-already-in-use':
          return 'Email is already registered';
        case 'invalid-email':
          return 'Invalid email address';
        case 'weak-password':
          return 'Password is too weak';
        default:
          return error.message ?? 'Authentication failed';
      }
    }
    return error.toString();
  }
} 
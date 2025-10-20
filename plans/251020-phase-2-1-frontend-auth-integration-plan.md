# 🔐 Phase 2.1: Frontend Authentication Integration Plan

**Date**: October 20, 2025
**Phase**: Phase 2 - Enhancement
**Duration**: 2 weeks (Nov 1-15, 2025)
**Status**: ⏳ READY FOR IMPLEMENTATION

---

## 🎯 Objective

Implement complete JWT-based authentication in Flutter mobile app:
1. **Login/Register UI** with backend integration
2. **Secure token storage** (flutter_secure_storage)
3. **HTTP interceptors** for JWT auto-refresh
4. **State management** for auth state persistence
5. **Error handling** for auth failures
6. **Session management** and logout

---

## 📋 Requirements

### Functional Requirements
- ✅ User can register with email/password
- ✅ User can login and receive JWT tokens
- ✅ Tokens auto-refresh before expiration
- ✅ Protected API calls include JWT header
- ✅ User can logout (token revocation)
- ✅ Email verification flow
- ✅ Password reset functionality
- ✅ Session persistence across app restarts

### Non-Functional Requirements
- ✅ Secure token storage (no plaintext)
- ✅ JWT handling: 15-min access, 7-day refresh
- ✅ Auto-logout on token expiration
- ✅ Handle network errors gracefully
- ✅ Support offline mode (cached tokens)
- ✅ Account lockout handling (5 failed attempts)

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│          Flutter Mobile App (Dart)               │
├─────────────────────────────────────────────────┤
│  UI Layer (Screens)                              │
│  ├── LoginScreen                                 │
│  ├── RegisterScreen                              │
│  ├── EmailVerificationScreen                     │
│  └── PasswordResetScreen                         │
├─────────────────────────────────────────────────┤
│  State Management Layer (Provider/GetX)          │
│  ├── AuthController                              │
│  ├── UserProvider                                │
│  └── AuthState                                   │
├─────────────────────────────────────────────────┤
│  API Layer (Dio HTTP Client)                     │
│  ├── DioClient (with interceptors)               │
│  ├── AuthInterceptor (JWT headers)               │
│  ├── TokenRefreshInterceptor                     │
│  └── ErrorInterceptor                            │
├─────────────────────────────────────────────────┤
│  Secure Storage Layer                            │
│  ├── flutter_secure_storage                      │
│  ├── TokenStorage service                        │
│  └── Credential caching                          │
└─────────────────────────────────────────────────┘
       │
       │ HTTP/REST
       ▼
┌─────────────────────────────────────────────────┐
│      Express.js Backend (Port 3000)              │
│  ✅ Already Verified & Production-Ready          │
└─────────────────────────────────────────────────┘
```

---

## 📁 Files to Create/Modify

### New Files to Create

**Services Layer**:
```
AppMusic/melody/lib/services/
├── auth_service.dart              # Auth API calls
├── token_storage_service.dart     # Secure token storage
├── dio_client.dart                # HTTP client with interceptors
└── jwt_service.dart               # JWT parsing & validation
```

**Models**:
```
AppMusic/melody/lib/models/
├── auth_models.dart               # Auth request/response DTOs
├── user_models.dart               # User data models
└── token_models.dart              # Token-related models
```

**State Management**:
```
AppMusic/melody/lib/provider/
├── auth_provider.dart             # Provider-based auth state
└── user_provider.dart             # User info provider
```

**Screens**:
```
AppMusic/melody/lib/screens/
├── login_screen_musium.dart       # Login UI
├── register_screen_musium.dart    # Register UI
├── email_verification_screen.dart # Email verification
└── password_reset_screen.dart     # Password reset
```

**Utils**:
```
AppMusic/melody/lib/utils/
├── api_constants.dart             # Backend URLs
├── auth_interceptors.dart         # JWT interceptors
└── error_handlers.dart            # Error handling
```

### Files to Modify

```
AppMusic/melody/
├── pubspec.yaml                   # Update dependencies
├── lib/main.dart                  # Add auth middleware
├── lib/services/music_service.dart # Update with JWT support
└── analysis_options.yaml          # Config updates
```

---

## 🔄 Implementation Phases

### Week 1: Foundation Setup

#### 1.1 Dependencies & Configuration
- [ ] Add: `dio`, `flutter_secure_storage`, `jwt_decoder`, `provider`
- [ ] Update pubspec.yaml with exact versions
- [ ] Run `flutter pub get`
- [ ] Configure Dio client with base URL
- [ ] Set up flutter_secure_storage

#### 1.2 Models & DTOs
- [ ] Create Auth request/response models
- [ ] Create User profile models
- [ ] Create Token models
- [ ] Add JSON serialization

#### 1.3 Token Storage Service
- [ ] Implement TokenStorageService (read/write/delete)
- [ ] Encrypt tokens using flutter_secure_storage
- [ ] Add token expiration checking
- [ ] Implement token validation

**File**: `lib/services/token_storage_service.dart`
```dart
class TokenStorageService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user_data';

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    // Save encrypted tokens
  }

  Future<String?> getAccessToken() async {
    // Retrieve and validate access token
  }

  Future<String?> getRefreshToken() async {
    // Retrieve refresh token
  }

  Future<void> clearTokens() async {
    // Clear all tokens on logout
  }

  Future<bool> isTokenExpired(String token) async {
    // Check if token expired
  }
}
```

### Week 2: API Integration

#### 2.1 HTTP Client with Interceptors
- [ ] Create DioClient with base configuration
- [ ] Implement AuthInterceptor (add JWT header)
- [ ] Implement TokenRefreshInterceptor (auto-refresh)
- [ ] Implement ErrorInterceptor (error handling)

**File**: `lib/services/dio_client.dart`
```dart
class DioClient {
  late Dio dio;

  DioClient() {
    dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:3000',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ));

    // Add interceptors
    dio.interceptors.add(AuthInterceptor());
    dio.interceptors.add(TokenRefreshInterceptor());
    dio.interceptors.add(ErrorInterceptor());
  }
}
```

#### 2.2 Auth Service (API Calls)
- [ ] POST /auth/register
- [ ] POST /auth/login
- [ ] POST /auth/verify-email
- [ ] POST /auth/refresh-token
- [ ] POST /auth/logout
- [ ] POST /auth/request-password-reset
- [ ] POST /auth/reset-password

**File**: `lib/services/auth_service.dart`
```dart
class AuthService {
  final DioClient dioClient;

  Future<AuthResponse> register(String email, String password, String name) async {
    // Call backend register endpoint
  }

  Future<AuthResponse> login(String email, String password) async {
    // Call backend login endpoint
  }

  Future<void> logout() async {
    // Call backend logout endpoint
  }
}
```

#### 2.3 State Management
- [ ] Create AuthProvider (manage auth state)
- [ ] Track user info
- [ ] Track login status
- [ ] Track loading/error states

**File**: `lib/provider/auth_provider.dart`
```dart
class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;

  Future<void> login(String email, String password) async {
    // Login logic with token storage
  }

  Future<void> logout() async {
    // Logout logic
  }
}
```

### Week 3: UI Screens

#### 3.1 Login Screen
- [ ] Email input field
- [ ] Password input field
- [ ] Remember me checkbox
- [ ] Login button
- [ ] Forgot password link
- [ ] Register link
- [ ] Error message display
- [ ] Loading indicator

#### 3.2 Register Screen
- [ ] Email input
- [ ] Password input (with strength indicator)
- [ ] Confirm password
- [ ] Name input
- [ ] Terms acceptance checkbox
- [ ] Register button
- [ ] Login link
- [ ] Input validation

#### 3.3 Email Verification Screen
- [ ] Email display
- [ ] Verification code input (or link click)
- [ ] Resend code button
- [ ] Error handling
- [ ] Success message

#### 3.4 Password Reset Screen
- [ ] Email input
- [ ] Request reset button
- [ ] Token input
- [ ] New password input
- [ ] Confirm password input
- [ ] Reset button
- [ ] Success message

### Week 4: Testing & Integration

#### 4.1 Unit Tests
- [ ] Token storage tests
- [ ] JWT parsing tests
- [ ] Auth service tests
- [ ] Interceptor tests

#### 4.2 Integration Tests
- [ ] Complete login flow
- [ ] Token refresh flow
- [ ] Logout flow
- [ ] Protected API calls

#### 4.3 Error Scenarios
- [ ] Invalid credentials
- [ ] Network errors
- [ ] Token expiration
- [ ] Account lockout
- [ ] Invalid verification code

---

## 🔐 Security Considerations

✅ **Token Storage**:
- Use flutter_secure_storage (encrypted)
- Never store tokens in SharedPreferences (not encrypted)
- Clear tokens on logout
- Handle token expiration

✅ **HTTP Security**:
- Always use HTTPS in production
- Validate SSL certificates
- Implement certificate pinning

✅ **Password Security**:
- Never log passwords
- Clear password from memory after use
- Use strong password validation
- Salt and hash passwords on backend

✅ **API Security**:
- Always include JWT header
- Validate JWT on every request
- Implement rate limiting
- Log authentication attempts

---

## 📊 Task Breakdown

### Task List
- [ ] 1.1 Install dependencies
- [ ] 1.2 Create models/DTOs
- [ ] 1.3 Implement TokenStorageService
- [ ] 1.4 Create JWT service
- [ ] 2.1 Build DioClient
- [ ] 2.2 Implement interceptors
- [ ] 2.3 Create AuthService
- [ ] 2.4 Build AuthProvider
- [ ] 3.1 Build LoginScreen
- [ ] 3.2 Build RegisterScreen
- [ ] 3.3 Build EmailVerificationScreen
- [ ] 3.4 Build PasswordResetScreen
- [ ] 4.1 Write unit tests
- [ ] 4.2 Write integration tests
- [ ] 4.3 Test error scenarios
- [ ] 4.4 Code review & cleanup
- [ ] 4.5 Documentation update

---

## 🎯 Success Criteria

- ✅ User can register with email/password
- ✅ User can login and receive JWT tokens
- ✅ Tokens stored securely
- ✅ Protected API calls include JWT header
- ✅ Tokens auto-refresh on expiration
- ✅ User can logout (tokens cleared)
- ✅ Session persists after app restart
- ✅ Error messages displayed for failures
- ✅ Account lockout handled gracefully
- ✅ Email verification works
- ✅ Password reset flow works
- ✅ All tests pass (unit + integration)

---

## 📁 Related Documents

- `docs/AUTHENTICATION-IMPLEMENTATION.md` - Backend auth details
- `plans/reports/251019-debugger-to-main-api-testing-report.md` - API endpoints
- `docs/code-standards.md` - Flutter coding standards
- `AppMusic/melody/pubspec.yaml` - Current dependencies

---

## 🚀 Next Steps

1. ✅ Backend verified (Phase 1 complete)
2. ⏳ **Create implementation plan** (this document)
3. ⏳ **Install dependencies**
4. ⏳ **Build token storage service**
5. ⏳ **Create HTTP client with interceptors**
6. ⏳ **Implement auth screens**
7. ⏳ **Write and run tests**
8. ⏳ **Code review and optimization**

---

**Owner**: UI/UX Developer + planner agent
**Timeline**: November 1-15, 2025
**Status**: READY FOR KICKOFF

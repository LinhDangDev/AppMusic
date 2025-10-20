# 🔐 Backend Authentication Implementation Guide

**Status**: Complete | **Last Updated**: October 19, 2025 | **Version**: 1.0

---

## 📋 Overview

AppMusic uses a **JWT-based authentication system** implemented in Express.js (TypeScript) backend. This guide provides complete details about the authentication architecture, implementation, and integration with Flutter frontend.

### Key Features
- ✅ JWT tokens (Access + Refresh)
- ✅ Secure password hashing (bcrypt)
- ✅ Email verification system
- ✅ Password reset functionality
- ✅ Account security (lockout system)
- ✅ Login history tracking
- ✅ Multi-device session management

---

## 🏗️ Architecture

### Authentication Components

```
Flutter Frontend                Express.js Backend           MySQL Database
    │                                   │                           │
    ├─ Login Screen                     ├─ AuthController           ├─ users
    ├─ Register Screen                  ├─ AuthService              ├─ security_settings
    ├─ Secure Token Storage             ├─ JWT Generation           ├─ refresh_tokens
    └─ HTTP Interceptor                 ├─ Password Hashing         ├─ email_verification_tokens
                                        ├─ Account Lockout          ├─ password_reset_tokens
                                        └─ Email Verification       └─ login_history
```

### Authentication Flow

1. **User Registration**
   - Validate input (email format, password strength)
   - Hash password with bcrypt
   - Create user in database
   - Generate email verification token
   - Return user ID and email

2. **User Login**
   - Validate email/password format
   - Query user by email
   - Check account status (active/locked/suspended)
   - Verify password using bcrypt
   - Check failed login attempts
   - Generate access token (JWT, 15 min)
   - Generate refresh token (7 days)
   - Record login attempt
   - Return tokens

3. **Token Refresh**
   - Validate refresh token exists in database
   - Check if token is revoked
   - Check if token is expired
   - Check if user account is active
   - Generate new access token
   - Return new token

4. **Logout**
   - Mark refresh token as revoked
   - Frontend deletes local tokens
   - User is logged out

---

## 🗄️ Database Schema

### users table
- id: INT PRIMARY KEY AUTO_INCREMENT
- email: VARCHAR(255) UNIQUE NOT NULL
- password_hash: VARCHAR(255) NOT NULL
- name: VARCHAR(255) NOT NULL
- is_premium: BOOLEAN DEFAULT FALSE
- is_email_verified: BOOLEAN DEFAULT FALSE
- status: ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED')
- last_login: TIMESTAMP
- created_at, updated_at: TIMESTAMP

### security_settings table
- user_id: INT UNIQUE (FK to users)
- failed_login_attempts: INT DEFAULT 0
- account_locked_until: TIMESTAMP
- last_failed_login: TIMESTAMP

### refresh_tokens table
- user_id: INT (FK to users)
- token: VARCHAR(255) UNIQUE NOT NULL
- expires_at: TIMESTAMP NOT NULL
- ip_address: VARCHAR(45)
- device_info: VARCHAR(500)
- is_revoked: BOOLEAN DEFAULT FALSE

### email_verification_tokens table
- user_id: INT (FK to users)
- token: VARCHAR(255) UNIQUE NOT NULL
- expires_at: TIMESTAMP NOT NULL (24 hours)

### password_reset_tokens table
- user_id: INT (FK to users)
- token: VARCHAR(255) UNIQUE NOT NULL
- expires_at: TIMESTAMP NOT NULL (1 hour)
- is_used: BOOLEAN DEFAULT FALSE

### login_history table
- user_id: INT (FK to users)
- ip_address: VARCHAR(45)
- user_agent: VARCHAR(500)
- login_status: ENUM('SUCCESS', 'FAILED')
- failure_reason: VARCHAR(255)

---

## 📡 API Endpoints

### POST /auth/register
Register new user account

**Request**: { email, password, name }
**Response**: { id, email, name, message }

### POST /auth/login
Authenticate user and get tokens

**Request**: { email, password, ipAddress?, userAgent? }
**Response**: { user, accessToken, refreshToken }

### POST /auth/refresh-token
Get new access token using refresh token

**Request**: { refreshToken }
**Response**: { accessToken }

### POST /auth/logout
Logout user and revoke refresh token

**Request**: { refreshToken }
**Response**: { message }

### POST /auth/verify-email
Verify email with token

**Request**: { token }
**Response**: { message }

### POST /auth/request-password-reset
Request password reset

**Request**: { email }
**Response**: { message }

### POST /auth/reset-password
Reset password with token

**Request**: { token, newPassword }
**Response**: { message }

### POST /auth/change-password
Change password (authenticated)

**Headers**: Authorization: Bearer {accessToken}
**Request**: { currentPassword, newPassword }
**Response**: { message }

---

## 🔑 JWT Token Management

### Access Token
- **Expiration**: 15 minutes
- **Storage**: Frontend secure storage
- **Payload**: { id, email, name, is_premium }
- **Usage**: Include in Authorization header: `Bearer {token}`

### Refresh Token
- **Expiration**: 7 days
- **Storage**: Database (secure)
- **Type**: Random 64-byte hex string
- **Usage**: Use to get new access token

### Token Lifecycle

```
1. Login → Generate both tokens
2. Access token used in requests (15 min)
3. When 401 received → Use refresh token to get new access token
4. Retry request with new access token
5. Logout → Revoke refresh token
6. Automatic cleanup → Delete expired tokens (cron job)
```

---

## 🔒 Security Features

### 1. Password Security
- ✓ bcrypt hashing (10 salt rounds)
- ✓ Minimum 8 characters
- ✓ Timing-attack resistant comparison

### 2. Account Protection
- ✓ Track failed login attempts (max 5)
- ✓ Auto-lockout for 30 minutes
- ✓ Record IP address and device info
- ✓ Automatic unlock after duration

### 3. Email Verification
- ✓ 24-hour expiration
- ✓ Single-use token
- ✓ Verify email ownership

### 4. Password Reset
- ✓ 1-hour expiration
- ✓ Single-use token
- ✓ Email-based reset link

### 5. Session Management
- ✓ Multi-device support (unique token per device)
- ✓ Revoke all tokens (on password change)
- ✓ Audit trail (login history)
- ✓ Automatic token cleanup

---

## 📱 Flutter Integration

### Required Packages
```yaml
dio: ^5.7.0
shared_preferences: ^2.3.5
flutter_secure_storage: ^9.0.0
jwt_decoder: ^2.0.1
```

### Secure Token Storage
```dart
final secureStorage = FlutterSecureStorage();

// Store tokens
await secureStorage.write(key: 'accessToken', value: accessToken);
await secureStorage.write(key: 'refreshToken', value: refreshToken);

// Retrieve tokens
final token = await secureStorage.read(key: 'accessToken');

// Delete tokens on logout
await secureStorage.delete(key: 'accessToken');
await secureStorage.delete(key: 'refreshToken');
```

### HTTP Interceptor Pattern
```dart
// Attach token to every request
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    final token = await getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  },
  onError: (error, handler) async {
    // Handle 401 errors
    if (error.response?.statusCode == 401) {
      if (await refreshAccessToken()) {
        // Retry original request
        return handler.resolve(await _retry(error.requestOptions));
      }
    }
    return handler.next(error);
  },
));
```

---

## 🧪 Testing

### Key Test Cases
- [ ] Register with valid/invalid email
- [ ] Register with password too short
- [ ] Login with correct credentials
- [ ] Login with wrong password
- [ ] Login with non-existent email
- [ ] Account lockout after 5 failures
- [ ] Unlock account after 30 minutes
- [ ] Token refresh with valid token
- [ ] Token refresh with invalid token
- [ ] Verify email with valid token
- [ ] Password reset flow
- [ ] Logout and token revocation

---

## 🚀 Deployment Checklist

- [ ] Set strong JWT_SECRET (min 32 characters)
- [ ] Configure HTTPS/TLS
- [ ] Set up email service
- [ ] Configure database
- [ ] Set up monitoring
- [ ] Configure CORS
- [ ] Test all flows
- [ ] Security audit
- [ ] Load testing
- [ ] Backup strategy

---

## Environment Variables

```bash
JWT_SECRET=your-secret-key-min-32-characters
JWT_EXPIRES_IN=15m
REFRESH_TOKEN_EXPIRES_IN=7d
EMAIL_SERVICE=sendgrid
EMAIL_API_KEY=key
```

---

**Status**: Ready for Implementation
**Last Updated**: October 19, 2025

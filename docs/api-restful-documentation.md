# 📚 AppMusic RESTful API Documentation

**Version**: 1.0
**Base URL**: `http://localhost:3000/api/v1`
**Authentication**: JWT Bearer Token
**Last Updated**: October 20, 2025

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Error Handling](#error-handling)
4. [API Endpoints](#api-endpoints)
5. [Test Cases](#test-cases)

---

## Overview

### API Standards
- **Format**: JSON
- **Pagination**: Limit & Offset
- **Authentication**: JWT Bearer Token
- **Rate Limiting**: 100 requests/minute per IP
- **Response Time Target**: < 500ms (95th percentile)

### HTTP Methods
- `GET` - Retrieve data
- `POST` - Create new resource
- `PUT` - Update existing resource
- `DELETE` - Remove resource

### HTTP Status Codes
```
200 OK              - Request successful
201 Created         - Resource created
204 No Content      - Successful deletion
400 Bad Request     - Invalid request
401 Unauthorized    - Missing/invalid token
403 Forbidden       - Insufficient permissions
404 Not Found       - Resource not found
409 Conflict        - Resource already exists
500 Server Error    - Internal error
```

---

## Authentication

### JWT Token Flow

```
Client                          Server
  │                                │
  ├─ POST /auth/register  ────────>│ Create user
  │                           <────┤ { accessToken, refreshToken }
  │                                │
  ├─ GET /users/profile            │
  │  Header: Authorization: Bearer {accessToken}
  │                           <────┤ User profile
  │                                │
  │ (Token expires in 15 min)      │
  │                                │
  ├─ POST /auth/refresh-token ────>│ New accessToken
  │  Body: { refreshToken }   <────┤ { accessToken, refreshToken }
  │                                │
  └─ GET /users/profile            │
     Header: Authorization: Bearer {new accessToken}
                              <────┤ User profile
```

### Token Structure

**Access Token** (15 minutes expiry)
```json
{
  "id": 1,
  "email": "user@example.com",
  "name": "John Doe",
  "is_premium": false,
  "iat": 1697817600,
  "exp": 1697818500
}
```

**Refresh Token** (7 days expiry)
```
Stored securely in database
- Can be revoked anytime
- One per device/session
- IP address & device info tracked
```

---

## Error Handling

### Error Response Format

```json
{
  "success": false,
  "code": "VALIDATION_ERROR",
  "message": "Invalid email format",
  "statusCode": 400,
  "timestamp": "2025-10-20T10:30:00Z",
  "errors": [
    {
      "field": "email",
      "message": "Email must be valid"
    }
  ]
}
```

### Error Codes

| Code | Status | Description |
|------|--------|-------------|
| `VALIDATION_ERROR` | 400 | Invalid request data |
| `UNAUTHORIZED` | 401 | Missing or invalid token |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `CONFLICT` | 409 | Resource already exists |
| `EMAIL_ALREADY_EXISTS` | 409 | Email is registered |
| `INVALID_CREDENTIALS` | 401 | Wrong email/password |
| `ACCOUNT_LOCKED` | 403 | Account locked (5 failed attempts) |
| `EMAIL_NOT_VERIFIED` | 403 | Email verification required |
| `TOKEN_EXPIRED` | 401 | Token has expired |
| `INTERNAL_ERROR` | 500 | Server error |

---

## API Endpoints

### 🔐 Authentication Endpoints

#### 1. Register User
```http
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "name": "John Doe"
}
```

**Response (201 Created)**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "message": "User registered successfully"
}
```

**Error Cases**
- 400: `VALIDATION_ERROR` - Invalid email/password format
- 409: `EMAIL_ALREADY_EXISTS` - Email already registered

---

#### 2. Login User
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Response (200 OK)**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "is_premium": false,
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "message": "Login successful"
}
```

**Error Cases**
- 401: `INVALID_CREDENTIALS` - Wrong email/password
- 403: `ACCOUNT_LOCKED` - Too many failed attempts
- 403: `EMAIL_NOT_VERIFIED` - Email not verified

---

#### 3. Refresh Token
```http
POST /auth/refresh-token
Content-Type: application/json

{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200 OK)**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "message": "Token refreshed successfully"
}
```

---

#### 4. Verify Email
```http
GET /auth/verify-email/{token}
```

**Response (200 OK)**
```json
{
  "success": true,
  "message": "Email verified successfully"
}
```

---

#### 5. Request Password Reset
```http
POST /auth/request-password-reset
Content-Type: application/json

{
  "email": "user@example.com"
}
```

**Response (200 OK)**
```json
{
  "success": true,
  "message": "Password reset link sent to email"
}
```

---

#### 6. Reset Password
```http
POST /auth/reset-password
Content-Type: application/json

{
  "token": "reset-token-xxx",
  "newPassword": "NewSecurePass123!"
}
```

**Response (200 OK)**
```json
{
  "success": true,
  "message": "Password reset successfully"
}
```

---

### 👤 User Endpoints

#### 7. Get User Profile
```http
GET /users/profile
Authorization: Bearer {accessToken}
```

**Response (200 OK)**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "profile_pic_url": "https://...",
    "is_premium": false,
    "is_email_verified": true,
    "favorite_genres": ["Pop", "Rock"],
    "favorite_artists": [1, 2, 3],
    "created_at": "2025-10-20T10:00:00Z",
    "last_login": "2025-10-20T15:30:00Z"
  }
}
```

---

#### 8. Update User Profile
```http
PUT /users/profile
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "name": "Jane Doe",
  "profile_pic_url": "https://...",
  "favorite_genres": ["Pop", "Jazz"],
  "favorite_artists": [1, 2]
}
```

**Response (200 OK)**
```json
{
  "success": true,
  "data": { /* updated user */ },
  "message": "Profile updated successfully"
}
```

---

#### 9. Get User Stats
```http
GET /users/stats
Authorization: Bearer {accessToken}
```

**Response (200 OK)**
```json
{
  "success": true,
  "data": {
    "songs_played": 150,
    "songs_favorited": 45,
    "playlists_count": 8,
    "total_play_time": 14400,
    "last_played_music_id": 123,
    "favorite_genre": "Pop"
  }
}
```

---

### 🎵 Music Endpoints

#### 10. Get Music List (Paginated)
```http
GET /music?page=1&limit=20&sort=created_at&order=desc
Authorization: Bearer {accessToken}
```

**Query Parameters**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20, max: 100)
- `sort` (optional): Sort field (created_at, play_count, title)
- `order` (optional): asc or desc
- `genre_id` (optional): Filter by genre
- `artist_id` (optional): Filter by artist

**Response (200 OK)**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Song Title",
      "artist_id": 1,
      "artist_name": "Artist Name",
      "album": "Album Name",
      "duration": 180,
      "release_date": "2025-01-15",
      "youtube_id": "xxx",
      "image_url": "https://...",
      "play_count": 1000,
      "created_at": "2025-10-20T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 1000,
    "total_pages": 50
  }
}
```

---

#### 11. Search Music
```http
GET /music/search?q=song+name&limit=20
Authorization: Bearer {accessToken}
```

**Query Parameters**
- `q` (required): Search query
- `limit` (optional): Results limit (default: 20)
- `type` (optional): title, artist, album

**Response (200 OK)**
```json
{
  "success": true,
  "data": [
    { /* music objects */ }
  ],
  "total": 45
}
```

---

### 📁 Playlist Endpoints

#### 12. Get User Playlists
```http
GET /playlists
Authorization: Bearer {accessToken}
```

**Response (200 OK)**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "name": "My Favorites",
      "description": "My favorite songs",
      "is_shared": false,
      "songs_count": 25,
      "created_at": "2025-10-20T10:00:00Z"
    }
  ]
}
```

---

#### 13. Create Playlist
```http
POST /playlists
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "name": "Workout Mix",
  "description": "Songs for workout",
  "is_shared": false
}
```

**Response (201 Created)**
```json
{
  "success": true,
  "data": { /* created playlist */ },
  "message": "Playlist created successfully"
}
```

---

#### 14. Add Song to Playlist
```http
POST /playlists/{playlistId}/songs
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "music_id": 123
}
```

**Response (200 OK)**
```json
{
  "success": true,
  "message": "Song added to playlist"
}
```

---

### ❤️ Favorite Endpoints

#### 15. Get Favorites
```http
GET /favorites?limit=20&page=1
Authorization: Bearer {accessToken}
```

**Response (200 OK)**
```json
{
  "success": true,
  "data": [
    { /* music objects */ }
  ],
  "pagination": { /* pagination info */ }
}
```

---

#### 16. Add Favorite
```http
POST /favorites
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "music_id": 123
}
```

**Response (201 Created)**
```json
{
  "success": true,
  "message": "Added to favorites"
}
```

---

#### 17. Remove Favorite
```http
DELETE /favorites/{musicId}
Authorization: Bearer {accessToken}
```

**Response (204 No Content)**

---

### 🔍 Search & Rankings

#### 18. Get Rankings
```http
GET /rankings?platform=billboard&region=US&limit=50
Authorization: Bearer {accessToken}
```

**Response (200 OK)**
```json
{
  "success": true,
  "data": [
    {
      "rank_position": 1,
      "music_id": 456,
      "title": "Top Song",
      "artist_name": "Top Artist",
      "platform": "billboard",
      "region": "US"
    }
  ]
}
```

---

## Test Cases

### Test Suite 1: Authentication

#### Test 1.1: Register with valid credentials
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "Test@Pass123",
    "name": "Test User"
  }'
```

**Expected**
- Status: 201 Created
- Response contains accessToken and refreshToken
- User created in database

---

#### Test 1.2: Register with existing email
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "existing@example.com",
    "password": "Test@Pass123",
    "name": "Test User"
  }'
```

**Expected**
- Status: 409 Conflict
- Error code: EMAIL_ALREADY_EXISTS

---

#### Test 1.3: Login with correct credentials
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "Test@Pass123"
  }'
```

**Expected**
- Status: 200 OK
- Response contains accessToken
- Login history recorded

---

#### Test 1.4: Login with wrong password
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@example.com",
    "password": "WrongPassword"
  }'
```

**Expected**
- Status: 401 Unauthorized
- Error code: INVALID_CREDENTIALS
- Failed login attempt recorded

---

### Test Suite 2: User Management

#### Test 2.1: Get user profile (authenticated)
```bash
curl -X GET http://localhost:3000/api/v1/users/profile \
  -H "Authorization: Bearer {accessToken}"
```

**Expected**
- Status: 200 OK
- Returns user data
- All fields present

---

#### Test 2.2: Get user profile (no token)
```bash
curl -X GET http://localhost:3000/api/v1/users/profile
```

**Expected**
- Status: 401 Unauthorized
- Error code: UNAUTHORIZED

---

#### Test 2.3: Update user profile
```bash
curl -X PUT http://localhost:3000/api/v1/users/profile \
  -H "Authorization: Bearer {accessToken}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Name",
    "favorite_genres": ["Pop", "Jazz"]
  }'
```

**Expected**
- Status: 200 OK
- Profile updated
- Returns updated data

---

### Test Suite 3: Music Management

#### Test 3.1: Get music list
```bash
curl -X GET 'http://localhost:3000/api/v1/music?page=1&limit=20' \
  -H "Authorization: Bearer {accessToken}"
```

**Expected**
- Status: 200 OK
- Returns paginated music list
- Pagination info present

---

#### Test 3.2: Search music
```bash
curl -X GET 'http://localhost:3000/api/v1/music/search?q=hello' \
  -H "Authorization: Bearer {accessToken}"
```

**Expected**
- Status: 200 OK
- Returns search results
- Only matching songs returned

---

#### Test 3.3: Get specific music
```bash
curl -X GET http://localhost:3000/api/v1/music/123 \
  -H "Authorization: Bearer {accessToken}"
```

**Expected**
- Status: 200 OK
- Returns music details

**If not found**
- Status: 404 Not Found
- Error code: NOT_FOUND

---

### Test Suite 4: Playlist Management

#### Test 4.1: Create playlist
```bash
curl -X POST http://localhost:3000/api/v1/playlists \
  -H "Authorization: Bearer {accessToken}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Playlist",
    "description": "Favorite songs",
    "is_shared": false
  }'
```

**Expected**
- Status: 201 Created
- Playlist created with unique ID
- User ID assigned

---

#### Test 4.2: Add song to playlist
```bash
curl -X POST http://localhost:3000/api/v1/playlists/1/songs \
  -H "Authorization: Bearer {accessToken}" \
  -H "Content-Type: application/json" \
  -d '{
    "music_id": 123
  }'
```

**Expected**
- Status: 200 OK
- Song added to playlist
- Position assigned

---

#### Test 4.3: Remove song from playlist
```bash
curl -X DELETE http://localhost:3000/api/v1/playlists/1/songs/123 \
  -H "Authorization: Bearer {accessToken}"
```

**Expected**
- Status: 204 No Content
- Song removed

---

### Test Suite 5: Favorites

#### Test 5.1: Add favorite
```bash
curl -X POST http://localhost:3000/api/v1/favorites \
  -H "Authorization: Bearer {accessToken}" \
  -H "Content-Type: application/json" \
  -d '{
    "music_id": 123
  }'
```

**Expected**
- Status: 201 Created
- Favorite created

**If already favorited**
- Status: 409 Conflict
- Error: Already favorited

---

#### Test 5.2: Remove favorite
```bash
curl -X DELETE http://localhost:3000/api/v1/favorites/123 \
  -H "Authorization: Bearer {accessToken}"
```

**Expected**
- Status: 204 No Content
- Favorite removed

---

### Test Suite 6: Error Handling

#### Test 6.1: Invalid JSON
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d 'invalid json'
```

**Expected**
- Status: 400 Bad Request
- Clear error message

---

#### Test 6.2: Missing required fields
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com"
  }'
```

**Expected**
- Status: 400 Bad Request
- Error code: VALIDATION_ERROR
- Details about missing fields

---

#### Test 6.3: Invalid email format
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "invalid-email",
    "password": "Test@Pass123",
    "name": "Test"
  }'
```

**Expected**
- Status: 400 Bad Request
- Validation error for email

---

### Performance Tests

#### Test 7.1: Response time < 500ms
- Get music list: Should be < 200ms
- Search: Should be < 300ms
- Playlist operations: Should be < 250ms

#### Test 7.2: Concurrent requests
- Handle 100 concurrent users
- No timeout errors
- All requests succeed

---

## Implementation Checklist

### Before Production
- [ ] All test cases passing
- [ ] 80%+ code coverage
- [ ] Rate limiting implemented
- [ ] CORS properly configured
- [ ] Security headers added
- [ ] Logging working
- [ ] Error handling complete
- [ ] Documentation complete
- [ ] API documented in Swagger
- [ ] Database backups configured

---

**Version**: 1.0
**Last Updated**: October 20, 2025
**Maintainer**: Backend Team

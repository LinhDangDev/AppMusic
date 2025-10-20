# Musium API Documentation

**Version:** 1.0.0
**Base URL:** `http://localhost:3000` (Development) | `https://api.musium.app` (Production)
**Authentication:** Bearer Token (JWT)

---

## Table of Contents
1. [Authentication](#authentication)
2. [Users](#users)
3. [Music](#music)
4. [Artists](#artists)
5. [Genres](#genres)
6. [Playlists](#playlists)
7. [Rankings](#rankings)
8. [Error Handling](#error-handling)

---

## Authentication

### Register User
**POST** `/api/auth/register`

Register a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123",
  "name": "John Doe"
}
```

**Response (201):**
```json
{
  "success": true,
  "status": 201,
  "message": "User registered successfully",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "is_premium": false,
    "is_email_verified": false,
    "created_at": "2024-10-19T10:00:00Z"
  }
}
```

### Login
**POST** `/api/auth/login`

Authenticate user and receive access & refresh tokens.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123"
}
```

**Response (200):**
```json
{
  "success": true,
  "status": 200,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "John Doe",
      "is_premium": false,
      "is_email_verified": true
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Errors:**
- `401 Unauthorized` - Invalid credentials
- `429 Too Many Requests` - Too many failed login attempts

### Refresh Token
**POST** `/api/auth/refresh`

Get a new access token using refresh token.

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200):**
```json
{
  "success": true,
  "status": 200,
  "message": "Token refreshed successfully",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### Logout
**POST** `/api/auth/logout`

Invalidate refresh token and logout user.

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200):**
```json
{
  "success": true,
  "status": 200,
  "message": "Logged out successfully"
}
```

### Change Password
**POST** `/api/auth/change-password`

Change user password.

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "currentPassword": "OldPassword123",
  "newPassword": "NewPassword123"
}
```

**Response (200):**
```json
{
  "success": true,
  "status": 200,
  "message": "Password changed successfully"
}
```

### Forgot Password
**POST** `/api/auth/forgot-password`

Request password reset email.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (200):**
```json
{
  "success": true,
  "status": 200,
  "message": "Password reset link sent to email"
}
```

### Reset Password
**POST** `/api/auth/reset-password`

Reset password using reset token.

**Request Body:**
```json
{
  "token": "reset_token_from_email",
  "newPassword": "NewPassword123"
}
```

**Response (200):**
```json
{
  "success": true,
  "status": 200,
  "message": "Password reset successfully"
}
```

### Verify Email
**POST** `/api/auth/verify-email`

Verify email address.

**Request Body:**
```json
{
  "token": "verification_token_from_email"
}
```

**Response (200):**
```json
{
  "success": true,
  "status": 200,
  "message": "Email verified successfully"
}
```

### Get Current User
**GET** `/api/auth/me`

Get current authenticated user info.

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Response (200):**
```json
{
  "success": true,
  "status": 200,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "is_premium": false,
    "is_email_verified": true,
    "created_at": "2024-10-19T10:00:00Z"
  }
}
```

### Get Active Sessions
**GET** `/api/auth/sessions`

Get all active user sessions.

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Response (200):**
```json
{
  "success": true,
  "status": 200,
  "data": [
    {
      "id": 1,
      "device_info": "iPhone 15",
      "ip_address": "192.168.1.1",
      "created_at": "2024-10-19T10:00:00Z",
      "expires_at": "2024-10-26T10:00:00Z"
    }
  ]
}
```

### Revoke Session
**POST** `/api/auth/sessions/{sessionId}/revoke`

Revoke a specific session.

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Response (200):**
```json
{
  "success": true,
  "status": 200,
  "message": "Session revoked successfully"
}
```

### Revoke All Sessions
**POST** `/api/auth/sessions/revoke-all`

Revoke all user sessions.

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Response (200):**
```json
{
  "success": true,
  "status": 200,
  "message": "All sessions revoked successfully"
}
```

---

## Users

### Get User Profile
**GET** `/api/users/{userId}`

Get user profile information.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "profile_pic_url": "https://...",
    "is_premium": false,
    "favorite_genres": ["rock", "pop"],
    "favorite_artists": [1, 2, 3],
    "created_at": "2024-10-19T10:00:00Z"
  }
}
```

### Update User Profile
**PUT** `/api/users/{userId}`

Update user profile.

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "name": "John Updated",
  "avatar": "https://...",
  "favorite_genres": ["rock", "pop", "jazz"],
  "favorite_artists": [1, 2, 3, 4]
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "id": 1,
    "name": "John Updated",
    "avatar": "https://...",
    "favorite_genres": ["rock", "pop", "jazz"]
  }
}
```

### Get Play History
**GET** `/api/users/{userId}/history?limit=50&offset=0`

Get user play history.

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "music_id": 123,
      "title": "Song Title",
      "artist": "Artist Name",
      "play_duration": 240,
      "played_at": "2024-10-19T10:00:00Z"
    }
  ]
}
```

### Get Favorites
**GET** `/api/users/{userId}/favorites?limit=50&offset=0`

Get user's favorite songs.

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Favorite Song",
      "artist_id": 1,
      "artist_name": "Artist Name",
      "play_count": 150,
      "youtube_url": "https://...",
      "created_at": "2024-10-19T10:00:00Z"
    }
  ]
}
```

### Add to Favorites
**POST** `/api/users/{userId}/favorites`

Add song to favorites.

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "musicId": 123
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Added to favorites successfully"
}
```

### Remove from Favorites
**DELETE** `/api/users/{userId}/favorites/{musicId}`

Remove song from favorites.

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Removed from favorites successfully"
}
```

---

## Music

### Get All Music
**GET** `/api/music?limit=20&offset=0&sort=newest`

Get all music with pagination.

**Query Parameters:**
- `limit` (default: 20) - Number of results
- `offset` (default: 0) - Pagination offset
- `sort` (default: newest) - Sort by: newest, popular, trending

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "title": "Song Title",
        "artist_id": 1,
        "artist_name": "Artist Name",
        "duration": 240,
        "youtube_url": "https://...",
        "youtube_thumbnail": "https://...",
        "play_count": 1500,
        "created_at": "2024-10-19T10:00:00Z"
      }
    ],
    "total": 5000,
    "limit": 20,
    "offset": 0
  }
}
```

### Get Music by ID
**GET** `/api/music/{musicId}`

Get detailed music information.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "Song Title",
    "artist_id": 1,
    "artist_name": "Artist Name",
    "album": "Album Name",
    "duration": 240,
    "release_date": "2024-01-15",
    "youtube_url": "https://...",
    "youtube_thumbnail": "https://...",
    "play_count": 1500,
    "lyrics": "...",
    "genres": ["rock", "pop"],
    "created_at": "2024-10-19T10:00:00Z"
  }
}
```

### Search Music
**GET** `/api/music/search?q=query&limit=20`

Search music by title or artist.

**Query Parameters:**
- `q` - Search query (required)
- `limit` (default: 20) - Number of results

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Song Title",
      "artist_name": "Artist Name",
      "play_count": 1500
    }
  ]
}
```

### Get Music by Artist
**GET** `/api/music/artist/{artistId}?limit=20`

Get all music from an artist.

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Song Title",
      "artist_id": 1,
      "duration": 240,
      "play_count": 1500
    }
  ]
}
```

### Get Music by Genre
**GET** `/api/music/genre?genres=1,2,3&limit=20`

Get music by genres.

**Query Parameters:**
- `genres` - Comma-separated genre IDs
- `limit` (default: 20)

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Song Title",
      "genres": ["rock", "pop"]
    }
  ]
}
```

### Get Top Music
**GET** `/api/music/top?limit=10`

Get top trending music.

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Top Song",
      "play_count": 50000,
      "rank": 1
    }
  ]
}
```

### Get Random Music
**GET** `/api/music/random?limit=10`

Get random music suggestions.

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Random Song",
      "artist_name": "Artist Name"
    }
  ]
}
```

### Update Play Count
**POST** `/api/music/{musicId}/play`

Increment music play count.

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "duration": 240
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Play count updated",
  "data": {
    "id": 1,
    "play_count": 1501
  }
}
```

---

## Artists

### Get Artist by ID
**GET** `/api/artists/{artistId}`

Get artist information.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Artist Name",
    "bio": "Artist biography...",
    "image_url": "https://...",
    "created_at": "2024-10-19T10:00:00Z"
  }
}
```

### Search Artists
**GET** `/api/artists/search?q=query&limit=20`

Search artists.

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Artist Name",
      "image_url": "https://...",
      "bio": "Short bio..."
    }
  ]
}
```

### Get Top Artists
**GET** `/api/artists/top?limit=10`

Get top artists.

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Top Artist",
      "songs_count": 45,
      "total_plays": 50000
    }
  ]
}
```

### Get Artist with Stats
**GET** `/api/artists/{artistId}/stats`

Get artist with statistics.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Artist Name",
    "songs_count": 45,
    "total_plays": 50000,
    "genres": ["rock", "pop"],
    "followers": 10000
  }
}
```

---

## Genres

### Get All Genres
**GET** `/api/genres?limit=100`

Get all available genres.

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Rock",
      "description": "Rock music genre",
      "image_url": "https://..."
    }
  ]
}
```

### Get Genre by ID
**GET** `/api/genres/{genreId}`

Get genre details.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Rock",
    "description": "Rock music genre",
    "image_url": "https://...",
    "songs_count": 5000
  }
}
```

### Search Genres
**GET** `/api/genres/search?q=query`

Search genres.

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Rock",
      "image_url": "https://..."
    }
  ]
}
```

---

## Playlists

### Get User Playlists
**GET** `/api/playlists?limit=20&offset=0`

Get all user's playlists.

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "name": "My Favorite Songs",
      "description": "Collection of favorite songs",
      "is_shared": false,
      "songs_count": 25,
      "created_at": "2024-10-19T10:00:00Z"
    }
  ]
}
```

### Create Playlist
**POST** `/api/playlists`

Create new playlist.

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "name": "My Playlist",
  "description": "Playlist description",
  "is_shared": false
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Playlist created successfully",
  "data": {
    "id": 1,
    "name": "My Playlist",
    "user_id": 1,
    "is_shared": false
  }
}
```

### Get Playlist by ID
**GET** `/api/playlists/{playlistId}`

Get playlist details.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "My Playlist",
    "user_id": 1,
    "description": "Playlist description",
    "is_shared": false,
    "created_at": "2024-10-19T10:00:00Z"
  }
}
```

### Update Playlist
**PUT** `/api/playlists/{playlistId}`

Update playlist details.

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "name": "Updated Playlist Name",
  "description": "Updated description",
  "is_shared": true
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Playlist updated successfully"
}
```

### Delete Playlist
**DELETE** `/api/playlists/{playlistId}`

Delete playlist.

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Playlist deleted successfully"
}
```

### Get Playlist Songs
**GET** `/api/playlists/{playlistId}/songs?limit=50&offset=0`

Get songs in playlist.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "playlist": {
      "id": 1,
      "name": "My Playlist"
    },
    "songs": [
      {
        "id": 1,
        "title": "Song Title",
        "artist_name": "Artist Name",
        "duration": 240,
        "added_at": "2024-10-19T10:00:00Z"
      }
    ],
    "total": 25
  }
}
```

### Add Song to Playlist
**POST** `/api/playlists/{playlistId}/songs`

Add song to playlist.

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Request Body:**
```json
{
  "musicId": 123
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Song added to playlist"
}
```

### Remove Song from Playlist
**DELETE** `/api/playlists/{playlistId}/songs/{musicId}`

Remove song from playlist.

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Song removed from playlist"
}
```

---

## Rankings

### Get Rankings by Platform
**GET** `/api/rankings?platform=itunes&limit=50`

Get music rankings by platform.

**Query Parameters:**
- `platform` - Platform name (itunes, spotify, etc.)
- `limit` (default: 50)

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "music_id": 123,
      "platform": "itunes",
      "rank_position": 1,
      "ranking_date": "2024-10-19"
    }
  ]
}
```

### Get Rankings by Region
**GET** `/api/rankings/region?region=us&limit=50`

Get music rankings by region.

**Query Parameters:**
- `region` - Region code (us, vn, etc.)
- `limit` (default: 50)

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Ranked Song",
      "artist": "Artist Name",
      "platform": "itunes",
      "region": "US",
      "rank": 1
    }
  ]
}
```

### Update Ranking
**POST** `/api/rankings`

Update music ranking (Admin only).

**Headers:**
```
Authorization: Bearer {adminToken}
```

**Request Body:**
```json
{
  "musicId": 123,
  "platform": "itunes",
  "position": 5
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Ranking updated successfully"
}
```

---

## Error Handling

### Standard Error Response

All error responses follow this format:

```json
{
  "success": false,
  "status": 400,
  "message": "Error message",
  "error": {
    "code": "ERROR_CODE",
    "details": "Detailed error information"
  },
  "timestamp": "2024-10-19T10:00:00Z"
}
```

### Common Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Request successful |
| 201 | Created - Resource created successfully |
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Authentication required |
| 403 | Forbidden - Access denied |
| 404 | Not Found - Resource not found |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error - Server error |

---

## Interactive API Testing

**Swagger UI:** `http://localhost:3000/api-docs`

Use the Swagger UI to:
- Browse all endpoints
- Test API calls directly
- View request/response schemas
- Authorize with Bearer token

---

**Last Updated:** October 19, 2024
**API Version:** 1.0.0

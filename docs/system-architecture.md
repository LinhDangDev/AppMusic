# 🏗️ AppMusic - System Architecture

**Version**: 2.0 | **Last Updated**: October 19, 2025 | **Status**: Phase 2

---

## 🎯 Architecture Overview

AppMusic follows a **layered microservices architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                              │
│  ┌──────────────────────┐  ┌──────────────────────┐         │
│  │   iOS (Native)       │  │  Android (Native)    │         │
│  └──────────────────────┘  └──────────────────────┘         │
│         ↓                          ↓                         │
│  ┌──────────────────────────────────────────────────┐       │
│  │      Flutter Mobile App (Dart)                   │       │
│  │  (UI, State Management, Local Storage)          │       │
│  └──────────────────────────────────────────────────┘       │
└──────────────────────┬────────────────────────────────────┬──┘
                       │ HTTP/REST                          │
                       ▼                                    ▼
        ┌─────────────────────────┐      ┌──────────────────────┐
        │   API Gateway/Router    │      │   Cache Layer        │
        │   (Express.js, CORS)    │      │   (Redis)            │
        └──────────┬──────────────┘      └──────────────────────┘
                   │
    ┌──────────────┼──────────────┐
    │              │              │
    ▼              ▼              ▼
┌─────────────┐ ┌──────────────┐ ┌────────────────┐
│  Auth       │ │ Music        │ │ Playlist       │
│  Controller │ │ Controller   │ │ Controller     │
└─────────────┘ └──────────────┘ └────────────────┘
    │              │                  │
    ▼              ▼                  ▼
┌──────────────────────────────────────────────┐
│        Service Layer (Business Logic)         │
│  ┌─────────────┐  ┌──────────────┐          │
│  │ AuthService │  │ MusicService │  ...     │
│  └─────────────┘  └──────────────┘          │
└──────────────┬───────────────────────────────┘
               │
    ┌──────────┼──────────┬─────────────┐
    │          │          │             │
    ▼          ▼          ▼             ▼
┌────────────┐ ┌────────────────┐  ┌──────────────┐
│  Database  │ │ Cache          │  │ Search       │
│ (MySQL)    │ │ (Redis)        │  │ (ES)         │
└────────────┘ └────────────────┘  └──────────────┘
    │
    ▼
┌──────────────────────────────────┐
│    Data Layer (Python)            │
│  ┌──────────┐  ┌──────────────┐  │
│  │ Spotify  │  │ Billboard    │  │
│  │ Crawler  │  │ Crawler      │  │
│  └──────────┘  └──────────────┘  │
│  ┌──────────┐  ┌──────────────┐  │
│  │ iTunes   │  │ YouTube      │  │
│  │ Crawler  │  │ Integration  │  │
│  └──────────┘  └──────────────┘  │
└──────────────────────────────────┘
```

---

## 📱 Client Layer Architecture

### Frontend (Flutter)
```
MVC Pattern:
├── Models
│   ├── Music (title, artist, duration, url)
│   ├── Playlist (name, songs, created_at)
│   ├── User (id, username, email)
│   └── ... (30+ models)
│
├── Views (Screens)
│   ├── Home Screen
│   ├── Player Screen
│   ├── Search Screen
│   ├── Library Screen
│   └── ... (20+ screens)
│
└── Controllers (Providers)
    ├── MusicController (GetX)
    │   ├── currentMusic
    │   ├── playlist
    │   ├── playbackState
    │   └── actions: play(), pause(), skip()
    │
    └── PlaylistController
        ├── userPlaylists
        ├── actions: create(), addSong(), removeSong()
        └── ...

Dependency Injection:
├── GetX for state management
├── Dio for HTTP requests
├── just_audio for playback
└── shared_preferences for local storage
```

---

## 🔌 API Layer Architecture

### Express.js Server
```typescript
// Middleware Stack
├── CORS Middleware
├── Body Parser
├── Authentication Middleware
│   └── JWT Verification
├── Rate Limiting (Planned)
└── Error Handler

// Route Handlers
├── /api/auth/*
│   ├── POST /register
│   ├── POST /login
│   └── POST /refresh
│
├── /api/music/*
│   ├── GET /  (List with pagination)
│   ├── GET /:id
│   ├── GET /search?q=
│   ├── GET /random
│   └── POST /:id/play
│
├── /api/playlists/*
│   ├── GET / (User's playlists)
│   ├── POST / (Create)
│   ├── GET /:id
│   ├── PUT /:id
│   ├── DELETE /:id
│   └── ...
│
└── /api/rankings/*
    ├── GET /:region
    ├── GET /:region/:source
    └── GET /:region/:source/:date
```

---

## 🧠 Service Layer Architecture

### Business Logic Services

#### Authentication Service
```
├── registerUser(email, password)
│   ├── Validate input
│   ├── Check existing user
│   ├── Hash password (bcrypt)
│   ├── Create user record
│   └── Generate JWT token
│
├── loginUser(email, password)
│   ├── Find user
│   ├── Verify password
│   ├── Generate JWT token
│   └── Cache session
│
└── verifyToken(token)
    ├── Decode JWT
    ├── Validate signature
    └── Check expiration
```

#### Music Service
```
├── getAllMusic(page, limit)
│   ├── Query database
│   ├── Apply cache
│   ├── Paginate results
│   └── Return with metadata
│
├── searchMusic(query)
│   ├── Parse search query
│   ├── Query database/ES
│   ├── Rank results
│   └── Cache results
│
├── getRandomMusic(count)
│   ├── Generate random IDs
│   ├── Fetch from DB
│   └── Return array
│
└── updatePlayCount(musicId)
    ├── Increment counter
    ├── Update database
    └── Invalidate cache
```

#### Playlist Service
```
├── createPlaylist(userId, name)
├── addSongToPlaylist(playlistId, musicId)
├── removeSongFromPlaylist(playlistId, musicId)
├── getPlaylistSongs(playlistId)
└── deletePlaylist(playlistId)
```

#### Ranking Service
```
├── getRankingsByRegion(region)
├── getRankingsBySource(region, source)
├── getHistoricalRankings(region, date)
└── updateRankings(crawlerData)
```

### Authentication Service (AuthService)
```
Responsibilities:
├── User Registration
│   ├── Email validation
│   ├── Password hashing (bcrypt)
│   ├── User creation in database
│   └── Email verification token generation
│
├── User Login
│   ├── Email/password verification
│   ├── Account status check
│   ├── Failed login attempts tracking
│   ├── Account lockout after 5 failed attempts
│   └── JWT token generation
│
├── Token Management
│   ├── Access Token (JWT, 15-minute expiration)
│   ├── Refresh Token (7-day expiration)
│   └── Token refresh mechanism
│
├── Password Management
│   ├── Password reset request
│   ├── Reset token generation
│   ├── Password change
│   └── Password hash update
│
├── Email Verification
│   ├── Verification token generation
│   ├── Email verification validation
│   └── User status update
│
└── Security Features
    ├── Account lockout system
    ├── Login attempt tracking
    ├── Session management
    └── Audit logging

Database Integration:
├── users table
│   ├── id, email, password_hash, name
│   ├── is_premium, is_email_verified
│   ├── last_login, created_at, updated_at
│   └── status (ACTIVE, INACTIVE, SUSPENDED)
│
├── security_settings table
│   ├── user_id, failed_login_attempts
│   ├── account_locked_until
│   └── last_failed_login
│
├── refresh_tokens table
│   ├── user_id, token, expires_at
│   ├── ip_address, device_info
│   └── is_revoked
│
├── email_verification_tokens table
│   ├── user_id, token, expires_at
│   └── created_at
│
├── password_reset_tokens table
│   ├── user_id, token, expires_at
│   ├── is_used
│   └── created_at
│
└── login_history table
    ├── user_id, ip_address, user_agent
    ├── login_status (SUCCESS, FAILED)
    ├── failure_reason
    └── created_at
```

Flow Diagrams:
```
LOGIN FLOW:
┌─────────┐          ┌─────────────┐          ┌──────────────┐
│ Mobile  │          │  Express    │          │  MySQL DB    │
│ App     │          │  Backend    │          │              │
└────┬────┘          └──────┬──────┘          └──────┬───────┘
     │ POST /auth/login     │                        │
     │─────────────────────>│                        │
     │                      │ SELECT user by email   │
     │                      │───────────────────────>│
     │                      │ Return user record     │
     │                      │<───────────────────────│
     │                      │ Verify password        │
     │                      │ Check failed attempts  │
     │                      │ Generate JWT + Refresh │
     │                      │ Record login attempt   │
     │ {accessToken,        │                        │
     │  refreshToken}       │                        │
     │<─────────────────────│                        │
     │ Store tokens         │                        │
     │ (flutter_secure_storage)                      │
```

LOGOUT FLOW:
```
┌─────────┐          ┌─────────────┐          ┌──────────────┐
│ Mobile  │          │  Express    │          │  MySQL DB    │
│ App     │          │  Backend    │          │              │
└────┬────┘          └──────┬──────┘          └──────┬───────┘
     │ POST /auth/logout    │                        │
     │─────────────────────>│                        │
     │                      │ Revoke refresh token   │
     │                      │───────────────────────>│
     │                      │ Update is_revoked=true │
     │                      │<───────────────────────│
     │ {message: OK}        │                        │
     │<─────────────────────│                        │
     │ Delete tokens        │                        │
     │ (local storage)      │                        │
```

TOKEN REFRESH FLOW:
```
Mobile App: Stores
├── accessToken (JWT) in flutter_secure_storage
├── refreshToken in flutter_secure_storage
└── Intercepts 401 errors to refresh token

When accessToken expires:
┌─────────┐          ┌─────────────┐          ┌──────────────┐
│ Mobile  │          │  Express    │          │  MySQL DB    │
│ App     │          │  Backend    │          │              │
└────┬────┘          └──────┬──────┘          └──────┬───────┘
     │ POST /auth/refresh-token       │
     │ + refreshToken                 │
     │─────────────────────>│                        │
     │                      │ Verify refresh token   │
     │                      │───────────────────────>│
     │                      │ Check is_revoked       │
     │                      │<───────────────────────│
     │                      │ Generate new JWT       │
     │ {accessToken}        │                        │
     │<─────────────────────│                        │
     │ Store new token      │                        │
```
```

---

## 💾 Data Layer Architecture

### Database Schema

#### Core Tables
```sql
-- Users
users (
  id INT PRIMARY KEY,
  username VARCHAR UNIQUE,
  email VARCHAR UNIQUE,
  password_hash VARCHAR,
  created_at TIMESTAMP
)

-- Music
music (
  id INT PRIMARY KEY,
  title VARCHAR,
  artist_id INT FK,
  genre_id INT FK,
  youtube_url VARCHAR,
  duration INT,
  play_count INT,
  created_at TIMESTAMP
)

-- Relationships
artists (id, name, bio, image_url)
genres (id, name, description)
playlists (id, user_id FK, name, created_at)
playlist_songs (playlist_id FK, music_id FK, position)

-- Rankings
rankings (
  id INT,
  music_id INT FK,
  region VARCHAR,
  position INT,
  source VARCHAR,
  chart_date DATE
)

-- Activity
plays (user_id FK, music_id FK, played_at TIMESTAMP)
```

### Caching Strategy

#### Redis Cache Layers
```
L1: Hot Data (< 5 min TTL)
├── music:{id} → Music details
├── rankings:{region}:{date} → Rankings
└── user:{id}:playlists → User's playlists

L2: Warm Data (< 1 hour TTL)
├── music:top100 → Top music
├── search:{query} → Search results
└── genres:{genre} → Genre music

L3: Application Cache
├── config:* → Configuration
└── artists:* → Artist info
```

---

## 🔐 Security Architecture

### Authentication Flow
```
1. User Registration
   ├── POST /api/auth/register
   ├── Email validation
   ├── Password hashing
   └── JWT token issued

2. User Login
   ├── POST /api/auth/login
   ├── Credentials verified
   ├── Session created
   └── JWT token issued

3. Protected Requests
   ├── Client sends: Authorization: Bearer {token}
   ├── Middleware verifies token
   ├── User context extracted
   └── Request processed

4. Token Refresh
   ├── POST /api/auth/refresh
   ├── Verify refresh token
   ├── Issue new access token
   └── Update Redis cache
```

### Data Protection
```
In Transit:
├── HTTPS/TLS encryption
├── Secure headers (HSTS, CSP)
└── CORS restrictions

At Rest:
├── Database encryption
├── Password hashing (bcrypt)
├── Sensitive data masked
└── Audit logging
```

---

## 📊 External Integrations

### Music Sources
```
YouTube Integration:
├── API: youtube-explode-dart
├── Purpose: Extract audio streams
├── Fallback: Direct URL streaming
└── Quality: Highest available bitrate

Spotify Integration:
├── API: Spotify Web API
├── Purpose: Chart rankings
├── Update: Every 6 hours
└── Data: Top 50 per region

Billboard Integration:
├── Method: Web scraping (Puppeteer)
├── Purpose: Hot 100 rankings
├── Update: Weekly (Friday)
└── Data: Position history

iTunes Integration:
├── API: iTunes Search API
├── Purpose: Metadata enrichment
├── Update: On demand
└── Data: Genre, artwork, reviews
```

---

## 🚀 Deployment Architecture

### Development Environment
```
Local:
├── Flutter emulator/device
├── Node.js dev server (port 3000)
├── MySQL container
├── Redis container
└── Python crawler (manual run)
```

### Staging Environment
```
Docker:
├── Frontend: Flutter web
├── Backend: Node.js container
├── Database: MySQL container
├── Cache: Redis container
├── Monitoring: Docker stats
```

### Production Environment
```
Cloud Infrastructure:
├── Load Balancer
│   ├── Distribution: Round-robin
│   └── Health check: /api/health
│
├── API Servers (3x instances)
│   ├── Image: Docker container
│   ├── Auto-scaling: CPU > 70%
│   └── Orchestration: Kubernetes
│
├── Database (Primary + Replica)
│   ├── Primary: Read/Write
│   ├── Replica: Read-only
│   └── Backup: Daily snapshots
│
├── Cache Layer (Redis Cluster)
│   ├── Replication: 3 nodes
│   ├── Failover: Automatic
│   └── Persistence: RDB + AOF
│
└── CDN
    ├── Static assets
    ├── Geographic distribution
    └── Cache: 24 hours TTL
```

---

## 📈 Scalability Patterns

### Horizontal Scaling
```
Load Distribution:
├── API Servers: Auto-scale 1-10
├── Database: Read replicas
├── Cache: Sharded Redis
└── CDN: Global distribution

Scaling Trigger:
├── CPU Usage > 70%
├── Memory Usage > 80%
├── Requests/sec > threshold
└── Response time > SLA
```

### Vertical Scaling
```
Resource Limits:
├── API: 2CPU, 4GB RAM per instance
├── Database: 16CPU, 64GB RAM
├── Redis: 8CPU, 32GB RAM
└── Storage: Auto-expanding
```

---

## 🔄 Integration Points

### Frontend ↔ Backend
```
HTTP/REST API:
├── Base URL: https://api.appmusic.local
├── Auth Header: Bearer {JWT token}
├── Response Format: JSON
└── Error Codes: Standard HTTP + Custom codes

Endpoints Used:
├── Music: GET /api/music, GET /api/music/search
├── Playlists: GET /api/playlists, POST /api/playlists
├── Auth: POST /api/auth/login, POST /api/auth/register
└── Rankings: GET /api/rankings/{region}
```

### Backend ↔ Database
```
Connection:
├── MySQL 8.0
├── Connection pooling (10-20 connections)
├── Query timeout: 30s
└── Automatic retry: 3 attempts

Optimization:
├── Indexes on frequently queried columns
├── Query caching via Redis
├── Batch operations for bulk insert
└── Regular ANALYZE for statistics
```

### Backend ↔ Cache
```
Redis Integration:
├── Connection: TCP, Port 6379
├── Auth: Password required
├── TTL: Configurable per key
└── Invalidation: Event-driven

Usage:
├── Session storage
├── Query result caching
├── Rate limiting counters
└── Real-time data (rankings)
```

---

## 🧪 Testing Architecture

### Test Pyramid
```
Unit Tests (70%):
├── Service layer
├── Model validation
└── Utility functions

Integration Tests (20%):
├── API endpoints
├── Database operations
└── Cache interactions

E2E Tests (10%):
├── User flows
├── Complete workflows
└── Cross-component interaction
```

---

## 📚 Technology Stack Summary

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| **Frontend** | Flutter | 3.6+ | Mobile UI |
| | Dart | 3.0+ | Language |
| | Provider/GetX | Latest | State mgmt |
| **Backend** | Node.js | 18+ | Runtime |
| | Express.js | 4.x | Web framework |
| | TypeScript | 5.0+ | Type safety |
| **Database** | MySQL | 8.0 | Primary DB |
| | Redis | 7.0+ | Cache layer |
| **DevOps** | Docker | Latest | Containerization |
| | Docker Compose | Latest | Orchestration |
| **Data** | Python | 3.x | Crawlers |
| | Puppeteer | Latest | Web scraping |

---

**Status**: Active
**Last Updated**: October 19, 2025
**Next Review**: January 31, 2026

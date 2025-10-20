# 🔍 Backend Verification Plan - Phase 2

**Date**: October 19, 2025
**Status**: In Progress
**Objective**: Verify Database Structure + Test API Endpoints

---

## 📋 Verification Checklist

### ✅ STEP 1: Database Verification (5-10 minutes)

#### 1.1 Check Database Connection
```bash
# Verify PostgreSQL is running
psql -U appmusic -d app_music -c "SELECT version();"

# Check if .env file has correct credentials
cat BackendAppMusic/.env | grep DATABASE_URL
```

#### 1.2 Verify Database Tables
```sql
-- List all tables
\dt

-- Check authentication tables
SELECT * FROM users LIMIT 5;
SELECT * FROM security_settings LIMIT 5;
SELECT * FROM refresh_tokens LIMIT 5;
SELECT * FROM email_verification_tokens LIMIT 5;
SELECT * FROM password_reset_tokens LIMIT 5;
SELECT * FROM login_history LIMIT 5;

-- Check music tables
SELECT * FROM artists LIMIT 5;
SELECT * FROM music LIMIT 5;
SELECT * FROM genres LIMIT 5;
SELECT * FROM music_genres LIMIT 5;
SELECT * FROM playlists LIMIT 5;

-- Check user interaction tables
SELECT * FROM favorites LIMIT 5;
SELECT * FROM play_history LIMIT 5;
SELECT * FROM search_history LIMIT 5;
SELECT * FROM queue LIMIT 5;
```

#### 1.3 Verify Database Schemas
```sql
-- Check user table structure
\d users

-- Check auth tables structure
\d security_settings
\d refresh_tokens
\d email_verification_tokens
\d password_reset_tokens
```

#### 1.4 Check Indexes
```sql
-- List all indexes
SELECT * FROM pg_stat_user_indexes;

-- Verify critical indexes exist
SELECT indexname FROM pg_stat_user_indexes
WHERE tablename IN ('users', 'music', 'artists', 'playlists');
```

---

### ✅ STEP 2: Backend Server Startup (5 minutes)

#### 2.1 Check Node Dependencies
```bash
cd BackendAppMusic
npm install  # Install dependencies if needed
npm run build  # Build TypeScript
```

#### 2.2 Start Development Server
```bash
cd BackendAppMusic
npm run dev
# Expected output: 🚀 Server is running on port 3000
```

#### 2.3 Monitor Server Logs
- Watch for initialization messages
- Check for database connection success
- Verify iTunes sync, genre updates, artist enrichment startup tasks
- Confirm cron jobs are scheduled

---

### ✅ STEP 3: API Endpoint Testing (15-20 minutes)

#### 3.1 Authentication Endpoints

**Test 1: User Registration**
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@test.com",
    "password": "TestPassword123!",
    "name": "Test User"
  }'

# Expected: 201 Created
# Response: { id, email, name, message }
```

**Test 2: User Login**
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "testuser@test.com",
    "password": "TestPassword123!"
  }'

# Expected: 200 OK
# Response: { accessToken, refreshToken, user }
```

**Test 3: Verify Email**
```bash
# Get email verification token from database
psql -U appmusic -d app_music -c "SELECT token FROM email_verification_tokens LIMIT 1;"

# Use the token
curl -X POST http://localhost:3000/auth/verify-email \
  -H "Content-Type: application/json" \
  -d '{
    "token": "VERIFICATION_TOKEN_HERE"
  }'

# Expected: 200 OK
```

**Test 4: Refresh Access Token**
```bash
curl -X POST http://localhost:3000/auth/refresh-token \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "REFRESH_TOKEN_FROM_LOGIN"
  }'

# Expected: 200 OK
# Response: { accessToken }
```

**Test 5: Logout**
```bash
curl -X POST http://localhost:3000/auth/logout \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE"

# Expected: 200 OK
```

#### 3.2 Music Endpoints

**Test 6: Get All Music**
```bash
curl -X GET "http://localhost:3000/api/music?limit=10&offset=0" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE"

# Expected: 200 OK
# Response: { data: [...], total, limit, offset }
```

**Test 7: Search Music**
```bash
curl -X GET "http://localhost:3000/api/music/search?query=song&limit=10" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE"

# Expected: 200 OK
```

**Test 8: Get Music By ID**
```bash
curl -X GET "http://localhost:3000/api/music/1" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE"

# Expected: 200 OK
```

#### 3.3 Playlist Endpoints

**Test 9: Create Playlist**
```bash
curl -X POST http://localhost:3000/api/playlists \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Test Playlist",
    "description": "Test description"
  }'

# Expected: 201 Created
```

**Test 10: Get User Playlists**
```bash
curl -X GET http://localhost:3000/api/playlists \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE"

# Expected: 200 OK
```

#### 3.4 Favorites Endpoint

**Test 11: Add to Favorites**
```bash
curl -X POST http://localhost:3000/api/favorites \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "music_id": 1
  }'

# Expected: 201 Created
```

**Test 12: Get Favorites**
```bash
curl -X GET http://localhost:3000/api/favorites \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE"

# Expected: 200 OK
```

#### 3.5 Genre Endpoints

**Test 13: Get All Genres**
```bash
curl -X GET "http://localhost:3000/api/genres?limit=20" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE"

# Expected: 200 OK
```

#### 3.6 Artist Endpoints

**Test 14: Get All Artists**
```bash
curl -X GET "http://localhost:3000/api/artists?limit=20" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE"

# Expected: 200 OK
```

#### 3.7 Rankings Endpoints

**Test 15: Get Rankings**
```bash
curl -X GET "http://localhost:3000/api/rankings?platform=itunes&region=us&limit=20" \
  -H "Authorization: Bearer ACCESS_TOKEN_HERE"

# Expected: 200 OK
```

---

### ✅ STEP 4: Health Check Endpoints (Optional)

#### 4.1 API Documentation
```bash
curl http://localhost:3000/api-docs
# Should return Swagger UI
```

#### 4.2 Server Status
```bash
curl http://localhost:3000/
# Check if server is responding
```

---

## 📊 Expected Results Summary

| Component | Status | Details |
|-----------|--------|---------|
| PostgreSQL Connection | ✅ | Database connected successfully |
| Authentication Tables | ✅ | All 6 tables created with indexes |
| Music Tables | ✅ | All music catalog tables present |
| User Interaction Tables | ✅ | Playlists, favorites, history tables exist |
| Server Startup | ✅ | Port 3000 listening |
| Auth API | ✅ | Register, login, verify, refresh working |
| Music API | ✅ | CRUD operations functional |
| Playlists API | ✅ | Create, read, update, delete working |
| Search API | ✅ | Search functionality operational |
| Rankings API | ✅ | Rankings sync working |

---

## ⚠️ Common Issues & Solutions

### Issue 1: Database Connection Failed
```
Error: ECONNREFUSED 127.0.0.1:5432
```
**Solution**:
- Check if PostgreSQL is running: `systemctl status postgresql`
- Verify credentials in `.env`
- Check database exists: `psql -l`

### Issue 2: Port 3000 Already in Use
```
Error: EADDRINUSE: address already in use :::3000
```
**Solution**:
- Kill existing process: `lsof -i :3000 | kill -9`
- Or use different port: `PORT=3001 npm run dev`

### Issue 3: Authentication Token Expired
```
Error: 401 Unauthorized
```
**Solution**:
- Get new token from login endpoint
- Use refresh token endpoint to get new access token

### Issue 4: CORS Issues
```
Error: CORS policy blocked
```
**Solution**:
- Check CORS_ORIGIN in `.env`
- Verify origin matches allowed origins

---

## 🎯 Success Criteria

✅ **Database**: All tables exist with correct structure and indexes
✅ **Server**: Starts without errors and listens on port 3000
✅ **Authentication**: Register, login, token refresh all working
✅ **Music API**: Can retrieve music, search, and browse
✅ **User Features**: Playlists, favorites, history functional
✅ **Performance**: API responds within reasonable time (<1s)
✅ **Security**: JWT authentication required for protected endpoints
✅ **Error Handling**: Proper error messages for invalid requests

---

## 📝 Notes

- Use Postman or Insomnia for easier API testing
- Save tokens for reuse across multiple requests
- Check server logs for any warnings or errors
- Monitor database query performance in production

**Next Steps After Verification**:
1. Fix any issues found
2. Run comprehensive test suite
3. Deploy to staging environment
4. Prepare for Phase 2 frontend integration testing

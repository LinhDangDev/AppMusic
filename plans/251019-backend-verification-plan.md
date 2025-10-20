# 🔍 Backend Verification Plan - Phase 2

**Date**: October 19, 2025
**Status**: Ready for Execution
**Objective**: Verify Database Structure + Test API Endpoints
**Owner**: database-admin agent + debugger agent

---

## 📋 Task Summary

### Objective
Perform comprehensive backend verification including:
1. PostgreSQL database connection and table validation
2. Backend Express.js server startup and health check
3. Complete API endpoint testing (15+ endpoints)
4. Performance and security validation

### Success Criteria
- ✅ PostgreSQL connected with all 20+ tables verified
- ✅ Backend server running on port 3000 without errors
- ✅ All authentication endpoints functional
- ✅ Music, playlist, favorites APIs working
- ✅ API responses < 1 second
- ✅ JWT authentication working properly
- ✅ Database indexes optimized
- ✅ Error handling working correctly

---

## 🎯 Agent Delegation Plan

### Phase 1: Database Verification (database-admin agent)
**Tasks**:
1. Test PostgreSQL connection
2. Verify all 20+ tables exist with correct structure
3. Check indexes and relationships
4. Validate schema integrity
5. Create report: `251019-database-admin-to-main-db-verification-report.md`

**Expected Output**:
- Connection status ✅
- Table inventory (users, music, playlists, rankings, etc.)
- Index status
- Relationship validation
- Performance metrics

### Phase 2: Backend Server Startup (debugger agent)
**Tasks**:
1. Install dependencies (npm install)
2. Build TypeScript (npm run build)
3. Start development server (npm run dev)
4. Monitor startup logs
5. Verify cron jobs scheduled
6. Create report: `251019-debugger-to-main-backend-startup-report.md`

**Expected Output**:
- Server listening on port 3000 ✅
- Database connection successful ✅
- All initialization tasks completed
- Cron jobs active (iTunes sync, genre updates, artist enrichment)
- No critical errors in logs

### Phase 3: API Testing (debugger agent)
**Tasks**:
1. Test 15+ API endpoints (auth, music, playlists, etc.)
2. Validate request/response formats
3. Test JWT token flow
4. Verify error handling
5. Check performance metrics
6. Create report: `251019-debugger-to-main-api-testing-report.md`

**Expected Output**:
- Authentication flow: register → login → verify → refresh → logout
- Music API: GET all, search, get by ID
- Playlists: create, read, update, delete
- Favorites: add, remove, view
- Rankings, genres, artists endpoints
- All responses with proper status codes
- Performance metrics

---

## 📊 Detailed Verification Steps

### Database Verification Checklist

```sql
-- 1. Check PostgreSQL connection
SELECT version();

-- 2. List all tables
\dt

-- 3. Authentication tables (6 tables)
✓ users
✓ security_settings
✓ refresh_tokens
✓ email_verification_tokens
✓ password_reset_tokens
✓ login_history

-- 4. Music catalog tables (5 tables)
✓ artists
✓ music
✓ genres
✓ music_genres
✓ music_updates

-- 5. User interaction tables (7 tables)
✓ playlists
✓ playlist_songs
✓ favorites
✓ play_history
✓ search_history
✓ queue
✓ playback_state

-- 6. Rankings tables
✓ rankings

-- 7. Subscription tables
✓ subscription_plans
✓ user_subscriptions
✓ payment_history
✓ promo_codes
✓ promo_usage
```

### API Endpoint Testing Checklist

#### Authentication (5 tests)
- [ ] POST /auth/register - User registration
- [ ] POST /auth/login - User login with JWT tokens
- [ ] POST /auth/verify-email - Email verification
- [ ] POST /auth/refresh-token - Token refresh
- [ ] POST /auth/logout - Logout and token revocation

#### Music Management (3 tests)
- [ ] GET /api/music - List all music
- [ ] GET /api/music/search - Search functionality
- [ ] GET /api/music/:id - Get music details

#### Playlists (3 tests)
- [ ] POST /api/playlists - Create playlist
- [ ] GET /api/playlists - Get user playlists
- [ ] PUT /api/playlists/:id - Update playlist
- [ ] DELETE /api/playlists/:id - Delete playlist

#### User Features (4 tests)
- [ ] POST /api/favorites - Add favorite
- [ ] GET /api/favorites - View favorites
- [ ] GET /api/rankings - Get rankings
- [ ] GET /api/genres - Get genres
- [ ] GET /api/artists - Get artists

---

## 📁 Related Documents

- `docs/AUTHENTICATION-IMPLEMENTATION.md` - Auth system details
- `docs/system-architecture.md` - Backend architecture
- `docs/project-roadmap.md` - Phase 2 timeline
- `BackendAppMusic/init/01-init.sql` - Database schema
- `BackendAppMusic/src/app.ts` - Server configuration

---

## 🔄 Workflow Process

1. **Database-Admin Agent**: Run database verification
   - Report: `251019-database-admin-to-main-db-verification-report.md`
   - If issues found → fix immediately
   - If OK → proceed to next phase

2. **Debugger Agent**: Start backend and test APIs
   - Report: `251019-debugger-to-main-backend-startup-report.md`
   - Report: `251019-debugger-to-main-api-testing-report.md`
   - If issues found → create journal entry in `docs/journals/`
   - If OK → mark Phase 2 ready

3. **Main Agent**: Consolidate findings
   - Review all agent reports
   - Update project status
   - Commit to git if all pass
   - Delegate to code-reviewer if needed

---

## 🚀 Next Steps After Verification

### If All Checks Pass ✅
1. Commit changes: `git add . && git commit -m "chore: backend verification complete"`
2. Delegate to project-manager for status update
3. Begin Phase 2.1: Frontend Authentication Integration

### If Issues Found ❌
1. Create debugging journal entry
2. Delegate to debugger for root cause analysis
3. Fix identified issues
4. Re-run verification
5. Only proceed when all checks pass

---

## 📝 Notes

- Use agent reports to track all findings
- Store reports in `plans/reports/` directory
- Follow naming format: `YYMMDD-from-agent-to-agent-task-report.md`
- All issues must be documented before proceeding
- Performance metrics must be baseline for future comparison

---

## ✨ Success Indicators

- **Database**: All 20+ tables present with proper structure
- **Server**: Runs without errors, listens on port 3000
- **Authentication**: Full JWT flow working (register → login → token → refresh → logout)
- **APIs**: All endpoints responding correctly
- **Performance**: All responses < 1 second
- **Security**: JWT authentication enforced
- **Logging**: Proper error logging and audit trails

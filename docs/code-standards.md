# 📝 AppMusic - Code Standards & Development Conventions

**Version**: 1.0 | **Last Updated**: October 19, 2025 | **Scope**: All repositories

---

## 🎯 Overview

This document defines coding standards, conventions, and best practices for the AppMusic project across all platforms (Flutter, Node.js/TypeScript, Python).

**Principles**: KISS, DRY, YANGI, Clean Code, Readability

---

## 📱 Flutter/Dart Standards

### File Organization
```
lib/
├── models/          # Data classes
├── services/        # API & business logic
├── providers/       # State management
├── screens/         # Full pages
├── widgets/         # Reusable components
├── constants/       # Constants & configs
└── utils/          # Helper functions
```

### Naming Conventions
```dart
// Classes: PascalCase
class MusicPlayer {}

// Variables/Functions: camelCase
int playCount = 0;
void playMusic() {}

// Constants: UPPER_SNAKE_CASE
const String API_BASE_URL = 'https://...';

// Private members: _leadingUnderscore
class _PrivateHelper {}

// File names: snake_case
music_controller.dart
```

### Code Style
```dart
// Maximum line length: 100 characters
// Indentation: 2 spaces
// Always use const where possible
final music = const Music(title: 'Song');

// Use null safety
String? optionalString;
String requiredString = '';

// Error handling
try {
  await musicService.playMusic(id);
} catch (e) {
  logger.error('Play failed: $e');
  showError('Playback failed');
}
```

### Widget Guidelines
```dart
// Stateless for static widgets
class MusicCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ...
}

// Stateful when state needed
class Player extends StatefulWidget {
  @override
  _PlayerState createState() => _PlayerState();
}

// Use Consumer for provider access
Consumer<MusicController>(
  builder: (context, music, child) => ...
)
```

---

## 🔌 TypeScript/Node.js Standards

### File Organization
```
src/
├── controllers/    # Request handlers
├── services/       # Business logic
├── routes/         # API endpoints
├── middleware/     # Middleware functions
├── models/         # Database models
├── types/          # TypeScript interfaces
└── utils/          # Helpers
```

### Naming Conventions
```typescript
// Classes: PascalCase
class MusicService {}

// Variables/Functions: camelCase
const playCount: number = 0;
function playMusic(): void {}

// Constants: UPPER_SNAKE_CASE
const API_TIMEOUT = 30000;

// Types/Interfaces: PascalCase
interface IMusic {
  title: string;
}

// File names: camelCase.ts
musicService.ts
```

### TypeScript Best Practices
```typescript
// Always use types
const music: Music = { /* ... */ };

// Use interfaces for contracts
interface IPlaylist {
  id: number;
  name: string;
  songs: ISong[];
}

// Avoid 'any' type
// ❌ const music: any = {};
// ✅ const music: Music = {};

// Use enums for constants
enum PlayState {
  PLAYING = 'PLAYING',
  PAUSED = 'PAUSED',
  STOPPED = 'STOPPED'
}
```

### Async/Await Patterns
```typescript
// Always use try-catch
async function getMusic(id: number): Promise<Music> {
  try {
    const response = await db.query('SELECT * FROM music WHERE id = ?', [id]);
    return response[0];
  } catch (error) {
    logger.error(`Get music failed: ${error}`);
    throw new APIError('Failed to get music');
  }
}

// Avoid callback hell
// ✅ Use async/await
// ❌ Avoid nested callbacks
```

### Express.js Controllers
```typescript
// Controllers receive (req, res, next)
async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const music = await musicService.getMusic(id);
    res.json({ success: true, data: music });
  } catch (error) {
    next(error);  // Pass to error handler
  }
}
```

### Backend Authentication & Authorization Standards

#### JWT Token Management
```typescript
// Access Token (15-minute expiration)
interface JWTPayload {
  id: number;
  email: string;
  name: string;
  is_premium: boolean;
  iat?: number;
  exp?: number;
}

// Always include in Authorization header
// Authorization: Bearer <accessToken>

// Handle token expiration:
// 1. Check response status for 401
// 2. Use refreshToken to get new accessToken
// 3. Retry original request

// Refresh Token (7-day expiration)
// Stored securely in database
// Can be revoked (is_revoked flag)
```

#### Authentication Endpoints
```typescript
// POST /auth/register
Request: { email, password, name }
Response: { id, email, name, message }

// POST /auth/login
Request: { email, password, ipAddress?, userAgent? }
Response: { user, accessToken, refreshToken }

// POST /auth/refresh-token
Request: { refreshToken }
Response: { accessToken }

// POST /auth/logout
Request: { refreshToken }
Response: { message }

// POST /auth/change-password
Authorization: Bearer <accessToken>
Request: { currentPassword, newPassword }
Response: { message }

// POST /auth/request-password-reset
Request: { email }
Response: { message }

// POST /auth/reset-password
Request: { token, newPassword }
Response: { message }

// POST /auth/verify-email
Request: { token }
Response: { message }
```

#### Security Best Practices
```
 ✓ Use bcrypt (salt rounds: 10) for password hashing
 ✓ Never store plain text passwords
 ✓ Hash passwords before saving to database
 ✓ Compare hashed passwords using bcrypt.compare()

 ✓ JWT Security
   - Use strong JWT_SECRET (min 32 characters)
   - Short expiration for access tokens (15 minutes)
   - Longer expiration for refresh tokens (7 days)
   - Always verify token signature before use
   - Handle TokenExpiredError separately

 ✓ Account Security
   - Track failed login attempts (max 5)
   - Lock account for 30 minutes after failed attempts
   - Record login attempt with IP & user agent
   - Update last_login timestamp
   - Require email verification before full access

 ✓ Password Management
   - Minimum 8 characters
   - Validate before hashing
   - Revoke all tokens when password changes
   - Send password reset links (never in email)

 ✓ Error Handling
   - Don't expose user existence (email enumeration)
   - Return generic "Invalid email or password" for auth failures
   - Log security events for monitoring
   - Return appropriate HTTP status codes (401, 403, 423)
```

#### TypeScript Patterns
```typescript
// Service class pattern
class AuthService {
  private db: PoolWithExecute = db;
  private readonly JWT_SECRET: string;
  private readonly JWT_EXPIRES_IN: string = '15m';

  async login(payload: LoginPayload): Promise<LoginResponse> {
    try {
      // Implementation
    } catch (error) {
      throw error;
    }
  }

  private generateAccessToken(user: User): string {
    return jwt.sign(
      { id: user.id, email: user.email, ... },
      this.JWT_SECRET,
      { expiresIn: this.JWT_EXPIRES_IN }
    );
  }
}
```

---

### Error Handling

```typescript
// Define error types
class APIError extends Error {
  constructor(
    message: string,
    public statusCode: number = 500,
    public code?: string
  ) {
    super(message);
  }
}

// Use meaningful messages
throw new APIError('Music not found', 404, 'MUSIC_NOT_FOUND');

// Log errors appropriately
logger.error('Database query failed', {
  query: 'SELECT * FROM music',
  error: error.message,
  timestamp: new Date()
});
```

### Testing

#### Frontend (Flutter)
```dart
// Widget test example
testWidgets('MusicPlayer plays music', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());

  expect(find.byType(MusicPlayer), findsOneWidget);

  await tester.tap(find.byIcon(Icons.play_arrow));
  await tester.pumpAndSettle();

  expect(find.text('Playing'), findsOneWidget);
});
```

#### Backend (Jest)
```typescript
describe('MusicService', () => {
  it('should get music by ID', async () => {
    const music = await musicService.getMusic(1);

    expect(music).toBeDefined();
    expect(music.id).toBe(1);
    expect(music.title).toBeTruthy();
  });
});
```

---

## 🔐 Security Standards

### Authentication
```typescript
// Always verify JWT tokens
if (!req.headers.authorization) {
  throw new APIError('Unauthorized', 401);
}

const token = req.headers.authorization.split(' ')[1];
const decoded = verifyJWT(token);
```

### Input Validation
```typescript
// Validate all inputs
const schema = {
  title: { type: 'string', required: true, maxLength: 255 },
  artist: { type: 'string', required: true },
  year: { type: 'number', min: 1900, max: 2100 }
};

validateInput(req.body, schema);
```

### SQL Injection Prevention
```typescript
// ✅ Use parameterized queries
db.query('SELECT * FROM music WHERE id = ?', [id]);

// ❌ Never concatenate
// db.query(`SELECT * FROM music WHERE id = ${id}`);
```

### XSS Prevention
```typescript
// Sanitize output
const sanitized = escapeHtml(userInput);

// Use parameterized templates
const response = { message: sanitized };
```

---

## 🚀 Performance Guidelines

### Optimization

```typescript
// Use pagination
const limit = 20;
const offset = (page - 1) * limit;
const music = await db.query('SELECT * FROM music LIMIT ? OFFSET ?', [limit, offset]);

// Cache frequently accessed data
const cachedMusic = await redis.get(`music:${id}`);
if (cachedMusic) return JSON.parse(cachedMusic);

// Use database indexes
CREATE INDEX idx_music_artist ON music(artist_id);
```

### Memory Management
```dart
// Dispose resources properly
@override
void dispose() {
  _controller.dispose();
  _streamSubscription?.cancel();
  super.dispose();
}
```

---

## 📚 Dependencies

### Manage versions
```json
// pin critical dependencies
"express": "4.18.2",
"mysql2": "3.0.0"

// use flexible versions for development
"jest": "^29.0.0"
```

### Regular updates
```bash
# Check for updates
npm outdated

# Update safely
npm update
npm audit fix
```

---

## 🎨 Code Review Checklist

- [ ] Follows naming conventions
- [ ] Properly documented
- [ ] Error handling included
- [ ] No security issues
- [ ] Tests included/updated
- [ ] Performance optimized
- [ ] No duplicated code
- [ ] Backward compatible
- [ ] Environment variables used
- [ ] Linting passes

---

## 📊 Metrics & Goals

| Metric | Target | Current |
|--------|--------|---------|
| Test Coverage | > 80% | ~30% |
| Code Duplication | < 5% | TBD |
| Cyclomatic Complexity | < 10 | TBD |
| Documentation Coverage | 100% | 60% |
| Security Issues | 0 | 0 |

---

**Status**: Active
**Review Frequency**: Quarterly
**Last Review**: October 19, 2025

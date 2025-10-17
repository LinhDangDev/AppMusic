# 🔐 Custom Authentication Quick Start

**Chuyển từ Firebase sang Custom Auth (tự code) - 5 bước đơn giản**

---

## 📋 Tổng Quan

Bạn đã bỏ Firebase và sử dụng custom authentication với:
- ✅ JWT Access Tokens (15 phút)
- ✅ Refresh Tokens (7 ngày)
- ✅ Bcrypt password hashing
- ✅ Email verification
- ✅ Password reset
- ✅ Session management
- ✅ Login history & security

---

## 🚀 Quick Start (5 Bước)

### 1️⃣ Install Dependencies

```bash
cd BackendAppMusic
npm install
```

Đã thêm vào `package.json`:
- `bcrypt` - Password hashing
- `jsonwebtoken` - JWT tokens
- `cookie-parser` - Cookie handling

### 2️⃣ Create .env File

```bash
# Tạo file .env trong BackendAppMusic/
cat > .env << 'EOF'
# Server
PORT=3000
NODE_ENV=development

# Database
DB_HOST=localhost
DB_PORT=3307
DB_USER=appmusic
DB_PASSWORD=appmusic123
DB_NAME=app_music

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# JWT - IMPORTANT: Đổi secret này!
JWT_SECRET=CHANGE_THIS_TO_RANDOM_STRING_MIN_32_CHARS
JWT_EXPIRES_IN=15m
REFRESH_TOKEN_EXPIRES_IN=7d

# CORS
CORS_ORIGIN=http://localhost:3000,http://localhost:8080

# iTunes
ITUNES_API=https://itunes.apple.com/vn/rss/topsongs/limit=100/json
ENABLE_CRON_SYNC=true
EOF
```

**⚠️ Generate secure JWT secret:**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### 3️⃣ Setup Database

```bash
# Option A: Fresh start (Recommended cho development)
mysql -u root -p < DatabaseAppMusic/custom_auth_schema.sql

# Option B: Sử dụng Docker
docker-compose down -v
docker-compose up -d
```

### 4️⃣ Start Backend

```bash
cd BackendAppMusic

# Development mode
npm run dev

# Production mode
npm start
```

Server sẽ chạy tại: `http://localhost:3000`

### 5️⃣ Test API

```bash
# Test registration
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","name":"Test User"}'

# Test login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

---

## 🔌 API Endpoints

### Authentication (Public)
```
POST   /api/auth/register         # Đăng ký
POST   /api/auth/login            # Đăng nhập
POST   /api/auth/refresh          # Refresh token
POST   /api/auth/forgot-password  # Quên mật khẩu
POST   /api/auth/reset-password   # Reset mật khẩu
GET    /api/auth/verify-email/:token  # Verify email
```

### User Management (Protected - Cần Access Token)
```
GET    /api/auth/me               # Thông tin user
POST   /api/auth/logout           # Đăng xuất
POST   /api/auth/change-password  # Đổi password
GET    /api/auth/sessions         # Xem sessions
DELETE /api/auth/sessions/:id     # Xóa session
```

---

## 📝 Usage Example

### Register & Login

```javascript
// 1. Register
const registerResponse = await fetch('http://localhost:3000/api/auth/register', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'SecurePassword123!',
    name: 'John Doe'
  })
});

// 2. Login
const loginResponse = await fetch('http://localhost:3000/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  credentials: 'include', // Important for cookies
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'SecurePassword123!'
  })
});

const { data } = await loginResponse.json();
const accessToken = data.accessToken;

// 3. Access protected route
const userResponse = await fetch('http://localhost:3000/api/auth/me', {
  headers: {
    'Authorization': `Bearer ${accessToken}`
  }
});
```

---

## 🗄️ Database Schema Changes

### Users Table (Updated)
```sql
-- BỎ: firebase_uid
-- THÊM: password_hash, is_email_verified

CREATE TABLE Users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,  -- ✅ Bcrypt hashed
    name VARCHAR(255) NOT NULL,
    is_email_verified TINYINT(1) DEFAULT 0,  -- ✅ Email verification
    is_premium TINYINT(1) DEFAULT 0,
    ...
);
```

### New Tables (5 bảng mới)
- `Email_Verification_Tokens` - Email verification
- `Password_Reset_Tokens` - Password reset
- `Refresh_Tokens` - JWT refresh tokens
- `Login_History` - Audit trail
- `Security_Settings` - 2FA, account lockout

---

## 🔐 Security Features

✅ **Password Hashing**: Bcrypt với 10 salt rounds
✅ **JWT Tokens**: Access (15m) + Refresh (7d)
✅ **Account Lockout**: 5 failed attempts → Lock 30 mins
✅ **Session Management**: Multi-device support
✅ **Login History**: Full audit trail
✅ **Email Verification**: Optional
✅ **Password Reset**: Secure token-based

---

## 📂 Files Created

### Database
- `DatabaseAppMusic/custom_auth_schema.sql` - Full MySQL schema

### Backend
- `src/services/authService.js` - Authentication logic
- `src/middleware/authMiddleware.js` - JWT verification
- `src/controllers/authController.js` - Auth controllers
- `src/routes/authRoutes.js` - Auth routes

### Documentation
- `docs/custom-auth-migration-guide.md` - Chi tiết đầy đủ (1000+ dòng)
- `CUSTOM_AUTH_QUICKSTART.md` - This file

---

## ⚠️ Important Notes

### 1. JWT Secret
**CRITICAL**: Đổi `JWT_SECRET` trong `.env` thành random string dài!

```bash
# Generate secure secret
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### 2. CORS Configuration
Nếu frontend chạy khác port, update `CORS_ORIGIN`:

```env
CORS_ORIGIN=http://localhost:8080,http://localhost:3000
```

### 3. Production Deployment
- ✅ Use HTTPS (secure cookies)
- ✅ Use strong JWT secret
- ✅ Enable rate limiting
- ✅ Setup email service (SendGrid/Mailgun)
- ✅ Monitor login attempts

---

## 🐛 Troubleshooting

### Error: "Invalid JWT secret"
→ Check `.env` file có `JWT_SECRET`

### Error: "CORS policy"
→ Update `CORS_ORIGIN` trong `.env`

### Error: "Table doesn't exist"
→ Run database schema: `mysql -u root -p < DatabaseAppMusic/custom_auth_schema.sql`

### Error: "bcrypt Error"
→ Reinstall bcrypt: `npm rebuild bcrypt`

---

## 📚 Full Documentation

Xem chi tiết đầy đủ tại:
- **[Custom Auth Migration Guide](docs/custom-auth-migration-guide.md)** - 1000+ lines
- **[Database Comparison](docs/database-comparison.md)** - Schema differences

---

## ✅ Checklist

Before going to production:

- [ ] Changed JWT_SECRET to secure random string
- [ ] Updated CORS_ORIGIN
- [ ] Tested registration flow
- [ ] Tested login flow
- [ ] Tested password reset
- [ ] Setup email service
- [ ] Configured HTTPS
- [ ] Added rate limiting
- [ ] Reviewed security settings
- [ ] Backup database

---

## 🎯 Next Steps

### Optional Enhancements

1. **Email Service** - SendGrid/Mailgun integration
2. **2FA** - Two-factor authentication
3. **OAuth** - Google/Facebook login
4. **Rate Limiting** - Prevent brute force
5. **Password Policies** - Complexity requirements

---

**Need help?** Check `docs/custom-auth-migration-guide.md` for detailed documentation.

**Generated**: 2025-01-16
**Status**: ✅ Ready to use


# 🐘 PostgreSQL Migration Guide

## 📋 Tổng quan

Hướng dẫn này giúp bạn migrate từ **MySQL** sang **PostgreSQL** với custom authentication.

## ✅ Những gì đã thay đổi

### 1. **Database**
- ❌ MySQL 8.0 → ✅ PostgreSQL 15
- ❌ `mysql2` package → ✅ `pg` package
- ❌ Port 3306 → ✅ Port 5432

### 2. **Schema Changes**
- ✅ `custom_auth_schema.sql` (MySQL) → `postgres_custom_auth.sql` (PostgreSQL)
- ✅ TINYINT(1) → BOOLEAN
- ✅ AUTO_INCREMENT → SERIAL
- ✅ JSON → JSONB (better performance)
- ✅ CREATE ENUM types cho status fields

### 3. **Files Modified**
```
✅ docker-compose.yml          - PostgreSQL service
✅ package.json                 - pg package
✅ src/config/database.js       - PostgreSQL Pool
✅ src/model/db.js              - PostgreSQL Pool
✅ init/01-init.sql             - PostgreSQL init script
```

## 🚀 Hướng dẫn Migration

### Bước 1: Dọn dẹp MySQL (nếu cần)

```bash
# Dừng và xóa containers cũ
docker-compose down -v

# Xóa volumes cũ (CẨN THẬN: Sẽ xóa dữ liệu)
docker volume prune
```

### Bước 2: Cài đặt dependencies mới

```bash
cd BackendAppMusic

# Xóa node_modules cũ
rm -rf node_modules package-lock.json

# Cài đặt lại
npm install
```

### Bước 3: Tạo file .env (nếu chưa có)

Tạo file `BackendAppMusic/.env`:

```env
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USER=appmusic
DB_PASSWORD=appmusic123
DB_NAME=app_music
DB_TYPE=postgres

# Server Configuration
PORT=3000
NODE_ENV=development

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-in-production-CHANGE-THIS

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379

# iTunes API
ITUNES_API=https://itunes.apple.com/vn/rss/topsongs/limit=100/json

# Cron Jobs
ENABLE_CRON_SYNC=true

# CORS
CORS_ORIGIN=*
```

### Bước 4: Build và chạy Docker

```bash
cd BackendAppMusic

# Build lại images
docker-compose build --no-cache

# Khởi động services
docker-compose up -d

# Xem logs
docker-compose logs -f app
```

### Bước 5: Kiểm tra kết nối

```bash
# Kiểm tra PostgreSQL
docker exec -it app_music_db psql -U appmusic -d app_music -c "\dt"

# Kiểm tra tables
docker exec -it app_music_db psql -U appmusic -d app_music -c "SELECT table_name FROM information_schema.tables WHERE table_schema='public';"

# Kiểm tra users
docker exec -it app_music_db psql -U appmusic -d app_music -c "SELECT * FROM users;"
```

## 🧪 Test API

### Health Check
```bash
curl http://localhost:3000/api/health
```

### Register User
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }'
```

### Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Get Music
```bash
curl http://localhost:3000/api/music
```

### Search Music
```bash
curl "http://localhost:3000/api/music/search?q=love"
```

## 🔧 Troubleshooting

### Problem: Connection timeout

```bash
# Check PostgreSQL is running
docker ps

# Check logs
docker-compose logs postgres

# Restart
docker-compose restart postgres
```

### Problem: Permission denied

```bash
# Fix volume permissions
docker-compose down -v
docker volume rm backendappmusic_postgres_data
docker-compose up -d
```

### Problem: Table not found

```bash
# Re-initialize database
docker-compose down -v
docker-compose up -d
```

### Problem: SQL syntax error

PostgreSQL có syntax khác MySQL:
- ❌ MySQL: `LIMIT 10 OFFSET 20`
- ✅ PostgreSQL: Giống nhau (OK)

- ❌ MySQL: `TINYINT(1)`
- ✅ PostgreSQL: `BOOLEAN`

- ❌ MySQL: `AUTO_INCREMENT`
- ✅ PostgreSQL: `SERIAL` hoặc `GENERATED ALWAYS AS IDENTITY`

## 📊 PostgreSQL Features

### 1. **JSONB** (Better than JSON)
```sql
-- Query JSONB fields
SELECT * FROM users WHERE favorite_genres @> '["Pop"]';

-- Update JSONB
UPDATE users SET favorite_genres = favorite_genres || '["Rock"]' WHERE id = 1;
```

### 2. **Full-Text Search**
```sql
-- Already enabled with pg_trgm
SELECT * FROM music
WHERE title ILIKE '%love%'
ORDER BY similarity(title, 'love') DESC;
```

### 3. **ENUMs**
```sql
-- Typed enums for better data integrity
ALTER TYPE user_status ADD VALUE 'BANNED';
```

### 4. **Advanced Indexing**
```sql
-- GIN index for full-text search
CREATE INDEX idx_music_title_gin ON music USING gin(to_tsvector('english', title));
```

## 📝 SQL Query Differences

### MySQL → PostgreSQL

#### 1. **Insert and Return ID**
```sql
-- MySQL
INSERT INTO users (...) VALUES (...);
SELECT LAST_INSERT_ID();

-- PostgreSQL
INSERT INTO users (...) VALUES (...) RETURNING id;
```

#### 2. **Date Functions**
```sql
-- MySQL
SELECT NOW(), CURDATE(), DATE_ADD(NOW(), INTERVAL 7 DAY);

-- PostgreSQL
SELECT NOW(), CURRENT_DATE, NOW() + INTERVAL '7 days';
```

#### 3. **String Concatenation**
```sql
-- MySQL
SELECT CONCAT(name, ' - ', email) FROM users;

-- PostgreSQL
SELECT name || ' - ' || email FROM users;
-- hoặc
SELECT CONCAT(name, ' - ', email) FROM users;
```

#### 4. **Limit & Offset**
```sql
-- Giống nhau
SELECT * FROM music LIMIT 10 OFFSET 20;
```

## 🔐 Security Notes

### Change JWT_SECRET
```bash
# Generate secure secret
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

### PostgreSQL User Permissions
```sql
-- Connect to database
\c app_music

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO appmusic;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO appmusic;
```

## 📚 References

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [node-postgres (pg)](https://node-postgres.com/)
- [PostgreSQL vs MySQL](https://www.postgresql.org/about/)

## ⚡ Performance Tips

1. **Use JSONB** instead of JSON
2. **Create indexes** for frequently queried columns
3. **Use prepared statements** (already in code)
4. **Enable connection pooling** (already configured)
5. **Use EXPLAIN ANALYZE** to optimize queries

```sql
EXPLAIN ANALYZE SELECT * FROM music WHERE artist_id = 1;
```

## 🎯 Next Steps

1. ✅ Test all API endpoints
2. ✅ Run integration tests
3. ✅ Monitor performance
4. ✅ Set up backups
5. ✅ Configure production settings

## 💾 Backup & Restore

### Backup
```bash
docker exec app_music_db pg_dump -U appmusic app_music > backup.sql
```

### Restore
```bash
cat backup.sql | docker exec -i app_music_db psql -U appmusic -d app_music
```

## ✨ Done!

Bạn đã migrate thành công sang PostgreSQL! 🎉

Nếu có vấn đề gì, check logs:
```bash
docker-compose logs -f app
docker-compose logs -f postgres
```

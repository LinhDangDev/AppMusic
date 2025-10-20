# 🎵 AppMusic - Music Streaming Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.6+-02569B?logo=flutter)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=node.js)](https://nodejs.org)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql)](https://www.mysql.com)
[![Redis](https://img.shields.io/badge/Redis-7.0-DC382D?logo=redis)](https://redis.io)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> Một nền tảng streaming nhạc miễn phí, kết hợp mobile app (Flutter) với backend API (Node.js), cung cấp charts/rankings từ Spotify, Billboard, iTunes, và streaming trực tiếp từ YouTube.

---

## ✨ Features

### 🎧 Music Streaming
- **Free unlimited streaming** từ YouTube
- **High-quality audio** (highest bitrate available)
- **Background playback** với media controls
- **Lock screen controls** và notifications
- **Queue management** với drag & drop

### 📊 Music Rankings & Charts
- **Multi-source charts**: Spotify, Billboard, iTunes
- **Regional rankings**: US, Vietnam, và nhiều quốc gia khác
- **Auto-sync**: Cập nhật mỗi 6 giờ
- **Historical data**: Xem chart theo thời gian

### 🔍 Search & Discovery
- **Smart search**: Tìm kiếm nhanh bài hát, nghệ sĩ
- **Genre browsing**: Khám phá theo thể loại
- **Random shuffle**: Nghe nhạc ngẫu nhiên
- **Smart shuffle**: Shuffle theo genre

### 📱 Playlist Management
- **Create & edit** playlists cá nhân
- **Add/remove** songs dễ dàng
- **Share playlists** với bạn bè
- **Playlist recommendations**

### 💎 Premium Features (Planned)
- Offline downloads
- Ad-free experience
- Higher audio quality
- Lyrics integration

---

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK** 3.6+ ([Install](https://flutter.dev/docs/get-started/install))
- **Node.js** 18+ ([Install](https://nodejs.org))
- **Docker** & Docker Compose ([Install](https://docs.docker.com/get-docker/))
- **Git** ([Install](https://git-scm.com/downloads))

### 1. Clone Repository

```bash
git clone https://github.com/your-username/AppMusic.git
cd AppMusic
```

### 2. Setup Backend

```bash
cd BackendAppMusic

# Install dependencies
npm install

# Start Docker services (MySQL + Redis)
docker-compose up -d

# Run backend in development mode
npm run dev
```

Backend sẽ chạy tại: `http://localhost:3000`

### 3. Setup Mobile App

```bash
cd AppMusic/melody

# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run
```

**Chú ý**: Cần update `lib/constants/api_constants.dart` để trỏ đến backend API:

```dart
static const baseUrl = 'http://YOUR_IP_ADDRESS:3000'; // Thay YOUR_IP_ADDRESS
```

---

## 📁 Project Structure

```
AppMusic/
├── AppMusic/melody/          # Flutter Mobile Application
│   ├── lib/
│   │   ├── constants/        # API URLs, colors, configs
│   │   ├── models/           # Data models (Music, Playlist, Genre)
│   │   ├── services/         # API services & business logic
│   │   ├── providers/        # State management (Provider)
│   │   ├── screens/          # UI screens
│   │   └── widgets/          # Reusable widgets
│   ├── android/              # Android native code
│   ├── ios/                  # iOS native code
│   └── assets/               # Images, icons, fonts
│
├── BackendAppMusic/          # Node.js REST API
│   ├── src/
│   │   ├── controllers/      # Request handlers
│   │   ├── services/         # Business logic
│   │   ├── routes/           # API endpoints
│   │   ├── middleware/       # Express middleware
│   │   ├── model/            # Database models
│   │   └── config/           # Database, Redis config
│   ├── init/                 # Database initialization
│   └── docker-compose.yml    # Docker services
│
└── DatabaseAppMusic/         # Python Data Crawlers
    ├── spotifychartcrawl.py  # Spotify charts
    ├── billboardcrawl.py     # Billboard Hot 100
    ├── itunes.py             # iTunes charts
    └── config.py             # Database config
```

---

## 🛠️ Technology Stack

### Mobile App (Flutter)
- **Framework**: Flutter 3.6+ / Dart 3.0+
- **State Management**: Provider + GetX
- **Audio**: just_audio, audio_service, audio_session
- **YouTube Integration**: youtube_explode_dart
- **HTTP Client**: Dio
- **Local Storage**: shared_preferences

### Backend API (Node.js)
- **Runtime**: Node.js 18+ (ES Modules)
- **Framework**: Express.js 4.x
- **Database**: MySQL 8.0
- **Cache**: Redis 7.x
- **Scheduler**: node-cron
- **Web Scraping**: Puppeteer

### Data Crawlers (Python)
- **Language**: Python 3.x
- **Libraries**: requests, beautifulsoup4, pymysql
- **Cloud Storage**: AWS S3 (boto3)

### DevOps
- **Containerization**: Docker + Docker Compose
- **Version Control**: Git
- **CI/CD**: GitHub Actions (planned)

---

## 📖 Documentation

Xem thêm documentation chi tiết tại thư mục `/docs`:

- **[Project Overview & PDR](docs/project-overview-pdr.md)** - Product requirements & roadmap
- **[System Architecture](docs/system-architecture.md)** - Kiến trúc hệ thống
- **[Code Standards](docs/code-standards.md)** - Coding conventions & best practices
- **[Codebase Summary](docs/codebase-summary.md)** - Tổng quan codebase

---

## 🔧 Development

### Backend Development

```bash
cd BackendAppMusic

# Development mode with auto-reload
npm run dev

# Production mode
npm start

# Run in Docker
docker-compose up --build
```

**Environment Variables (.env):**
```env
PORT=
DB_HOST=
DB_PORT=
DB_USER=
DB_PASSWORD=
DB_NAME=
REDIS_HOST=
REDIS_PORT=
NODE_ENV=
```

### Mobile Development

```bash
cd AppMusic/melody

# Get dependencies
flutter pub get

# Run on device
flutter run

# Build APK (Android)
flutter build apk --release

# Build IPA (iOS)
flutter build ios --release

# Analyze code
flutter analyze

# Run tests
flutter test
```

### Data Crawlers

```bash
cd DatabaseAppMusic

# Install dependencies
pip install -r requirements.txt

# Run Spotify crawler
python spotifychartcrawl.py

# Run Billboard crawler
python billboardcrawl.py

# Run iTunes crawler
python itunes.py
```



---

## 🔌 API Endpoints

### Music API

```
GET    /api/music                      # Get all music (paginated)
GET    /api/music/:id                  # Get music by ID
GET    /api/music/search?q={query}    # Search music
GET    /api/music/random?limit={n}    # Random music
GET    /api/music/rankings/:region    # Get rankings by region
POST   /api/music/:id/play            # Update play count
```

### Playlist API

```
GET    /api/playlists                 # Get all playlists
POST   /api/playlists                 # Create playlist
GET    /api/playlists/:id             # Get playlist by ID
PUT    /api/playlists/:id             # Update playlist
DELETE /api/playlists/:id             # Delete playlist
```

### Other APIs
- `/api/artists` - Artists management
- `/api/genres` - Genres management
- `/api/users` - User management
- `/api/health` - Health check

**API Documentation**: [Postman Collection](BackendAppMusic/test/BackendMusic.postman_collection.json)

---

## 🎨 Screenshots

> **Coming soon!** Screenshots của app sẽ được update sau.

---

## 🧪 Testing

### Backend Tests

```bash
cd BackendAppMusic
npm test
```

### Mobile Tests

```bash
cd AppMusic/melody

# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart
```

---

## 🚢 Deployment

### Backend Deployment

**Docker (Recommended):**
```bash
docker-compose up -d --build
```

**Manual:**
```bash
npm start
```

### Mobile Deployment

**Android:**
```bash
flutter build apk --release
# APK output: build/app/outputs/flutter-apk/app-release.apk
```

**iOS:**
```bash
flutter build ios --release
# Build with Xcode and submit to App Store
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'feat: add some amazing feature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

**Coding Standards**: Xem [Code Standards](docs/code-standards.md)

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **YouTube** - Audio streaming source
- **Spotify Charts** - Music rankings data
- **Billboard** - Charts data
- **iTunes API** - Music metadata
- **Flutter Team** - Amazing framework
- **Node.js Community** - Ecosystem

---

## 📞 Contact

**Project Maintainer**: Your Name

- Email: your.email@example.com
- GitHub: [@your-username](https://github.com/your-username)

**Bug Reports & Feature Requests**: [GitHub Issues](https://github.com/your-username/AppMusic/issues)

---

## 🗺️ Roadmap

### ✅ Phase 1: MVP (Completed)
- [x] Basic music streaming
- [x] YouTube integration
- [x] Rankings display
- [x] Search functionality
- [x] Playlist management

### 🚧 Phase 2: Enhancement (In Progress)
- [ ] User profiles
- [ ] Social features
- [ ] Lyrics integration
- [ ] Audio equalizer

### 📋 Phase 3: Scale (Planned)
- [ ] Offline downloads
- [ ] Podcast support
- [ ] AI recommendations
- [ ] Multi-language support
- [ ] Web player

---

## ⚠️ Disclaimer

This app is for **educational purposes only**. All music content is streamed directly from YouTube and we do not host any copyrighted content. Please respect copyright laws in your country.

---

<div align="center">

**Made with ❤️ by the Linh Dang**

[⬆ Back to top](#-appmusic---music-streaming-platform)

</div>

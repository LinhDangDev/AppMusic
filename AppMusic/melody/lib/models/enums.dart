// Database Enums - All custom types from PostgreSQL

// ============================================
// USER & AUTHENTICATION ENUMS
// ============================================

enum UserStatus { active, inactive, suspended }

enum LoginStatus { success, failed }

// ============================================
// PLAYBACK & REPEAT MODES
// ============================================

enum RepeatMode { off, one, all }

// ============================================
// UPDATE & CHANGE TRACKING
// ============================================

enum UpdateType { playCount, popularity, metadata }

// ============================================
// SUBSCRIPTION & PAYMENT
// ============================================

enum SubscriptionStatus { active, expired, cancelled, pending }

enum PaymentStatus { pending, success, failed, refunded }

// ============================================
// MUSIC SOURCES
// ============================================

enum MusicSource { youtube, itunes }

enum LyricsState { pending, found, notFound }

// ============================================
// QUEUE & PLAYBACK
// ============================================

enum QueueType { manual, playlist, auto }

enum PlaySource { search, playlist, queue }

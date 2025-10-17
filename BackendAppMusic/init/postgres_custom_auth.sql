-- ============================================
-- AppMusic - Custom Authentication Schema
-- PostgreSQL Version
-- Không dùng Firebase, tự code authentication
-- ============================================
-- Drop database if exists
DROP DATABASE IF EXISTS app_music;
CREATE DATABASE app_music;
USE app_music;

-- Connect to app_music database before running below commands
-- \c app_music

-- ============================================
-- CREATE ENUMS
-- ============================================

CREATE TYPE user_status AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED');
CREATE TYPE login_status AS ENUM ('SUCCESS', 'FAILED');
CREATE TYPE repeat_mode AS ENUM ('OFF', 'ONE', 'ALL');
CREATE TYPE update_type AS ENUM ('PLAY_COUNT', 'POPULARITY', 'METADATA');
CREATE TYPE subscription_status AS ENUM ('ACTIVE', 'EXPIRED', 'CANCELLED', 'PENDING');
CREATE TYPE payment_status AS ENUM ('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED');
CREATE TYPE music_source AS ENUM ('youtube', 'itunes');
CREATE TYPE lyrics_state AS ENUM ('PENDING', 'FOUND', 'NOT_FOUND');
CREATE TYPE queue_type AS ENUM ('manual', 'playlist', 'auto');
CREATE TYPE play_source AS ENUM ('search', 'playlist', 'queue');

-- ============================================
-- TABLES với Custom Authentication
-- ============================================

-- Users Table - Custom Auth (NO FIREBASE)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,          -- Bcrypt hashed password
    name VARCHAR(255) NOT NULL,
    profile_pic_url TEXT,
    is_premium BOOLEAN DEFAULT FALSE,
    is_email_verified BOOLEAN DEFAULT FALSE,      -- Email verification status
    favorite_genres JSONB,
    favorite_artists JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    status user_status DEFAULT 'ACTIVE'
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);

-- Email Verification Tokens
CREATE TABLE email_verification_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_email_verification_token ON email_verification_tokens(token);
CREATE INDEX idx_email_verification_user_id ON email_verification_tokens(user_id);

-- Password Reset Tokens
CREATE TABLE password_reset_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_used BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_password_reset_token ON password_reset_tokens(token);
CREATE INDEX idx_password_reset_user_id ON password_reset_tokens(user_id);

-- Refresh Tokens (JWT)
CREATE TABLE refresh_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(500) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_revoked BOOLEAN DEFAULT FALSE,
    device_info VARCHAR(255),                      -- Track devices
    ip_address VARCHAR(45)                         -- IPv4/IPv6
);

CREATE INDEX idx_refresh_token ON refresh_tokens(token);
CREATE INDEX idx_refresh_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_expires_at ON refresh_tokens(expires_at);

-- Login History / Audit Trail
CREATE TABLE login_history (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    login_status login_status NOT NULL,
    failure_reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_login_history_user_id ON login_history(user_id);
CREATE INDEX idx_login_history_created_at ON login_history(created_at);

-- Account Security Settings
CREATE TABLE security_settings (
    user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_secret VARCHAR(255),
    failed_login_attempts INTEGER DEFAULT 0,
    last_failed_login TIMESTAMP,
    account_locked_until TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- Các bảng nghiệp vụ khác
-- ============================================

CREATE TABLE artists (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    bio TEXT,
    image_url VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Full-text search index
CREATE INDEX idx_artists_name_trgm ON artists USING gin(name gin_trgm_ops);

CREATE TABLE genres (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE music (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    artist_id INTEGER REFERENCES artists(id),
    album VARCHAR(255),
    duration INTEGER,
    release_date DATE,
    youtube_thumbnail VARCHAR(255),
    youtube_id VARCHAR(50),
    youtube_url VARCHAR(255),
    image_url TEXT,
    preview_url TEXT,
    source music_source,
    source_id VARCHAR(255),
    play_count INTEGER DEFAULT 0,
    lyrics TEXT,
    genius_id VARCHAR(50),
    lyrics_state lyrics_state DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_music_artist ON music(artist_id);
CREATE INDEX idx_music_source ON music(source, source_id);
-- Full-text search index
CREATE INDEX idx_music_title_trgm ON music USING gin(title gin_trgm_ops);

CREATE TABLE music_genres (
    music_id INTEGER NOT NULL REFERENCES music(id) ON DELETE CASCADE,
    genre_id INTEGER NOT NULL REFERENCES genres(id) ON DELETE CASCADE,
    PRIMARY KEY (music_id, genre_id)
);

CREATE INDEX idx_music_genres_genre ON music_genres(genre_id);

CREATE TABLE music_updates (
    id SERIAL PRIMARY KEY,
    music_id INTEGER NOT NULL REFERENCES music(id) ON DELETE CASCADE,
    update_type update_type NOT NULL,
    old_value JSONB,
    new_value JSONB,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_music_updates_music_id ON music_updates(music_id);

CREATE TABLE promo_codes (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    discount_percent INTEGER,
    discount_amount DECIMAL(10, 2),
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMP,
    max_uses INTEGER,
    current_uses INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_promo_codes_code_active ON promo_codes(code, is_active);

CREATE TABLE rankings (
    id SERIAL PRIMARY KEY,
    platform VARCHAR(255) NOT NULL,
    region VARCHAR(10),
    music_id INTEGER NOT NULL REFERENCES music(id) ON DELETE CASCADE,
    rank_position INTEGER NOT NULL,
    position INTEGER,
    ranking_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (platform, music_id, ranking_date),
    UNIQUE (region, position)
);

CREATE INDEX idx_rankings_date ON rankings(ranking_date);
CREATE INDEX idx_rankings_platform ON rankings(platform);
CREATE INDEX idx_rankings_region ON rankings(region, position);
CREATE INDEX idx_rankings_music_id ON rankings(music_id);

CREATE TABLE subscription_plans (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    duration_days INTEGER NOT NULL,
    features JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_subscriptions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan_id INTEGER NOT NULL REFERENCES subscription_plans(id),
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP NOT NULL,
    auto_renewal BOOLEAN DEFAULT FALSE,
    status subscription_status DEFAULT 'PENDING'
);

CREATE INDEX idx_user_subscriptions_user_status ON user_subscriptions(user_id, status);
CREATE INDEX idx_user_subscriptions_plan_id ON user_subscriptions(plan_id);

CREATE TABLE payment_history (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subscription_id INTEGER NOT NULL REFERENCES user_subscriptions(id),
    amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50),
    transaction_id VARCHAR(255),
    status payment_status DEFAULT 'PENDING',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payment_history_user ON payment_history(user_id);
CREATE INDEX idx_payment_history_subscription ON payment_history(subscription_id);

CREATE TABLE promo_usage (
    id SERIAL PRIMARY KEY,
    promo_id INTEGER NOT NULL REFERENCES promo_codes(id),
    user_id INTEGER NOT NULL REFERENCES users(id),
    subscription_id INTEGER NOT NULL REFERENCES user_subscriptions(id),
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_promo_usage_promo_id ON promo_usage(promo_id);
CREATE INDEX idx_promo_usage_user_id ON promo_usage(user_id);
CREATE INDEX idx_promo_usage_subscription_id ON promo_usage(subscription_id);

CREATE TABLE playlists (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    is_shared BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_playlists_user ON playlists(user_id);

CREATE TABLE playback_state (
    user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    current_music_id INTEGER REFERENCES music(id) ON DELETE SET NULL,
    current_playlist_id INTEGER REFERENCES playlists(id) ON DELETE SET NULL,
    repeat_mode repeat_mode DEFAULT 'OFF',
    shuffle_mode BOOLEAN DEFAULT FALSE,
    last_position INTEGER,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_playback_current_music ON playback_state(current_music_id);
CREATE INDEX idx_playback_current_playlist ON playback_state(current_playlist_id);

CREATE TABLE playlist_songs (
    playlist_id INTEGER NOT NULL REFERENCES playlists(id) ON DELETE CASCADE,
    music_id INTEGER NOT NULL REFERENCES music(id) ON DELETE CASCADE,
    position INTEGER,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist_id, music_id)
);

CREATE INDEX idx_playlist_songs_music_id ON playlist_songs(music_id);
CREATE INDEX idx_playlist_songs_position ON playlist_songs(playlist_id, position);

CREATE TABLE queue (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    music_id INTEGER NOT NULL REFERENCES music(id) ON DELETE CASCADE,
    position INTEGER NOT NULL,
    queue_type queue_type DEFAULT 'manual',
    source_id INTEGER,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    repeat_mode repeat_mode DEFAULT 'OFF',
    UNIQUE (user_id, position)
);

CREATE INDEX idx_queue_music_id ON queue(music_id);
CREATE INDEX idx_queue_user_position ON queue(user_id, position);

CREATE TABLE favorites (
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    music_id INTEGER NOT NULL REFERENCES music(id) ON DELETE CASCADE,
    artist_id INTEGER NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, music_id, artist_id)
);

CREATE INDEX idx_favorites_music_id ON favorites(music_id);
CREATE INDEX idx_favorites_artist_id ON favorites(artist_id);

CREATE TABLE offline_songs (
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    music_id INTEGER NOT NULL REFERENCES music(id) ON DELETE CASCADE,
    downloaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiration_date TIMESTAMP,
    PRIMARY KEY (user_id, music_id)
);

CREATE INDEX idx_offline_songs_music_id ON offline_songs(music_id);

CREATE TABLE search_history (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    query VARCHAR(255) NOT NULL,
    result_count INTEGER,
    searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_search_history_user_id ON search_history(user_id);

CREATE TABLE play_history (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    music_id INTEGER REFERENCES music(id) ON DELETE CASCADE,
    play_duration INTEGER DEFAULT 0,
    source_type play_source DEFAULT 'search',
    source_id INTEGER,
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_play_history_user_date ON play_history(user_id, played_at);

CREATE TABLE lyrics_database (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    artist VARCHAR(255) NOT NULL,
    lyrics TEXT,
    source VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (title, artist)
);

-- ============================================
-- TRIGGERS & FUNCTIONS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_artists_updated_at BEFORE UPDATE ON artists
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_music_updated_at BEFORE UPDATE ON music
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_playlists_updated_at BEFORE UPDATE ON playlists
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_security_settings_updated_at BEFORE UPDATE ON security_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rankings_updated_at BEFORE UPDATE ON rankings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger for tracking play count changes
CREATE OR REPLACE FUNCTION log_music_play_count_update()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.play_count != OLD.play_count THEN
        INSERT INTO music_updates (music_id, update_type, old_value, new_value)
        VALUES (
            NEW.id,
            'PLAY_COUNT',
            jsonb_build_object('play_count', OLD.play_count),
            jsonb_build_object('play_count', NEW.play_count)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER track_play_count_changes
AFTER UPDATE ON music
FOR EACH ROW
EXECUTE FUNCTION log_music_play_count_update();

-- ============================================
-- ENABLE pg_trgm extension for full-text search
-- ============================================
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ============================================
-- SEED DATA
-- ============================================

INSERT INTO genres (name, description, image_url) VALUES
('Pop', 'Popular contemporary music', NULL),
('Romance', 'Romantic and love songs', NULL),
('Sad', 'Emotional and melancholic songs', NULL),
('R&B & Soul', 'Rhythm and blues, and soul music', NULL),
('Party', 'Upbeat party music', NULL),
('Mandopop & Cantopop', 'Mandarin and Cantonese pop music', NULL),
('Folk & Acoustic', 'Traditional and acoustic music', NULL),
('K-Pop', 'Korean pop music', NULL),
('Feel Good', 'Uplifting and positive music', NULL),
('Hip-Hop', 'Hip hop and rap music', NULL),
('Sleep', 'Calm and relaxing music for sleep', NULL),
('Workout', 'Energetic music for exercise', NULL),
('Family', 'Family-friendly music', NULL),
('Commute', 'Music for traveling', NULL),
('Chill', 'Relaxing and laid-back music', NULL),
('Focus', 'Music for concentration', NULL),
('Dance & Electronic', 'Electronic dance music', NULL),
('Classical', 'Classical music', NULL),
('2000s', 'Music from the 2000s', NULL),
('Korean Hip-Hop', 'Korean hip hop music', NULL),
('Energy Boosters', 'High-energy music', NULL),
('Soundtracks & Musicals', 'Movie and musical soundtracks', NULL),
('1980s', 'Music from the 1980s', NULL),
('Indie & Alternative', 'Independent and alternative music', NULL);

INSERT INTO artists (name, bio, description) VALUES
('Unknown Artist', 'Default artist for system', 'Default artist for system'),
('Taylor Swift', 'American singer-songwriter', 'American singer-songwriter'),
('Ed Sheeran', 'English singer-songwriter', 'English singer-songwriter');

-- Create default user for testing
INSERT INTO users (name, email, password_hash) VALUES
('Default User', 'user@example.com', '$2b$10$YourHashedPasswordHere');

-- ============================================
-- COMMENTS
-- ============================================

COMMENT ON TABLE users IS 'User accounts with custom authentication (NO Firebase)';
COMMENT ON TABLE email_verification_tokens IS 'Email verification tokens for new user registration';
COMMENT ON TABLE password_reset_tokens IS 'Password reset tokens for forgot password flow';
COMMENT ON TABLE refresh_tokens IS 'JWT refresh tokens for maintaining user sessions';
COMMENT ON TABLE login_history IS 'Audit trail of all login attempts';
COMMENT ON TABLE security_settings IS 'User security settings including 2FA and account lockout';
COMMENT ON TABLE music IS 'Music tracks with metadata';
COMMENT ON TABLE artists IS 'Music artists';
COMMENT ON TABLE genres IS 'Music genres';
COMMENT ON TABLE playlists IS 'User playlists';
COMMENT ON TABLE rankings IS 'Music rankings by platform and region';

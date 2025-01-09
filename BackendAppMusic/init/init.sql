-- Reset database
DROP DATABASE IF EXISTS app_music;
CREATE DATABASE app_music;
USE app_music;

-- Create user
DROP USER IF EXISTS 'appmusic'@'%';
CREATE USER 'appmusic'@'%' IDENTIFIED BY 'appmusic123';
GRANT ALL PRIVILEGES ON app_music.* TO 'appmusic'@'%';
FLUSH PRIVILEGES;

-- Base tables (no dependencies)
CREATE TABLE Artists (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    bio TEXT,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Music (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    artist_id INT,
    album VARCHAR(255),
    duration INT,
    release_date DATE,
    youtube_url VARCHAR(255),
    youtube_id VARCHAR(50),
    youtube_thumbnail VARCHAR(255),
    image_url TEXT,
    preview_url TEXT,
    source ENUM('youtube', 'itunes', 'local') DEFAULT 'itunes',
    source_id VARCHAR(255),
    play_count INT DEFAULT 0,
    lyrics TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (artist_id) REFERENCES Artists(id)
);

CREATE TABLE Genres (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    firebase_uid VARCHAR(128) UNIQUE NOT NULL,
    email VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    profile_pic_url TEXT,
    is_premium BOOLEAN DEFAULT FALSE,
    favorite_genres JSON,
    favorite_artists JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED') DEFAULT 'ACTIVE'
);

-- Dependent tables level 1
CREATE TABLE Music_Genres (
    music_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (music_id, genre_id),
    FOREIGN KEY (music_id) REFERENCES Music(id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES Genres(id) ON DELETE CASCADE
);

CREATE TABLE Playlists (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    is_shared BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- Dependent tables level 2
CREATE TABLE Playlist_Songs (
    playlist_id INT NOT NULL,
    music_id INT NOT NULL,
    position INT,
    PRIMARY KEY (playlist_id, music_id),
    FOREIGN KEY (playlist_id) REFERENCES Playlists(id) ON DELETE CASCADE,
    FOREIGN KEY (music_id) REFERENCES Music(id) ON DELETE CASCADE
);

CREATE TABLE Favorites (
    user_id INT NOT NULL,
    music_id INT,
    artist_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, music_id, artist_id),
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (music_id) REFERENCES Music(id) ON DELETE CASCADE,
    FOREIGN KEY (artist_id) REFERENCES Artists(id) ON DELETE CASCADE
);

CREATE TABLE Queue (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    music_id INT NOT NULL,
    position INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    repeat_mode ENUM('OFF', 'ONE', 'ALL') DEFAULT 'OFF',
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (music_id) REFERENCES Music(id) ON DELETE CASCADE,
    UNIQUE KEY unique_queue_position (user_id, position)
);

-- Additional tables
CREATE TABLE Offline_Songs (
    user_id INT NOT NULL,
    music_id INT NOT NULL,
    downloaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiration_date TIMESTAMP,
    PRIMARY KEY (user_id, music_id),
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (music_id) REFERENCES Music(id) ON DELETE CASCADE
);

CREATE TABLE Rankings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    platform VARCHAR(255) NOT NULL,
    music_id INT NOT NULL,
    rank_position INT NOT NULL,
    ranking_date DATE DEFAULT (CURRENT_DATE),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (music_id) REFERENCES Music(id) ON DELETE CASCADE,
    UNIQUE KEY unique_ranking (platform, music_id, ranking_date)
);

CREATE TABLE PlaybackState (
    user_id INT PRIMARY KEY,
    current_music_id INT,
    current_playlist_id INT,
    repeat_mode ENUM('OFF', 'ONE', 'ALL') DEFAULT 'OFF',
    shuffle_mode BOOLEAN DEFAULT FALSE,
    last_position INT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (current_music_id) REFERENCES Music(id) ON DELETE SET NULL,
    FOREIGN KEY (current_playlist_id) REFERENCES Playlists(id) ON DELETE SET NULL
);

CREATE TABLE Subscription_Plans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    duration_days INT NOT NULL,
    features JSON,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE User_Subscriptions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP NOT NULL,
    auto_renewal BOOLEAN DEFAULT FALSE,
    status ENUM('ACTIVE', 'EXPIRED', 'CANCELLED', 'PENDING') DEFAULT 'PENDING',
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES Subscription_Plans(id)
);

CREATE TABLE Payment_History (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    subscription_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50),
    transaction_id VARCHAR(255),
    status ENUM('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED') DEFAULT 'PENDING',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (subscription_id) REFERENCES User_Subscriptions(id)
);

CREATE TABLE Promo_Codes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_percent INT,
    discount_amount DECIMAL(10,2),
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMP,
    max_uses INT,
    current_uses INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE Promo_Usage (
    id INT AUTO_INCREMENT PRIMARY KEY,
    promo_id INT NOT NULL,
    user_id INT NOT NULL,
    subscription_id INT NOT NULL,
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (promo_id) REFERENCES Promo_Codes(id),
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (subscription_id) REFERENCES User_Subscriptions(id)
);

CREATE TABLE Music_Updates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    music_id INT NOT NULL,
    update_type ENUM('PLAY_COUNT', 'POPULARITY', 'METADATA') NOT NULL,
    old_value JSON,
    new_value JSON,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (music_id) REFERENCES Music(id) ON DELETE CASCADE
);

CREATE TABLE Search_History (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    query VARCHAR(255) NOT NULL,
    result_count INT,
    searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- Thêm bảng mới để lưu cache của stream URLs
CREATE TABLE Stream_Cache (
    id INT AUTO_INCREMENT PRIMARY KEY,
    music_id INT NOT NULL,
    stream_url TEXT NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (music_id) REFERENCES Music(id) ON DELETE CASCADE,
    INDEX idx_expires (expires_at)
);

-- Thêm bảng để theo dõi lỗi streaming
CREATE TABLE Streaming_Errors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    music_id INT NOT NULL,
    error_type VARCHAR(50) NOT NULL,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (music_id) REFERENCES Music(id) ON DELETE CASCADE
);

-- Thêm bảng để lưu thông tin về chất lượng audio
CREATE TABLE Audio_Quality (
    id INT AUTO_INCREMENT PRIMARY KEY,
    music_id INT NOT NULL,
    quality VARCHAR(20) NOT NULL,  -- LOW, MEDIUM, HIGH
    format VARCHAR(20) NOT NULL,   -- mp3, aac, etc.
    bitrate INT,                   -- kbps
    file_size BIGINT,             -- bytes
    duration INT,                  -- seconds
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (music_id) REFERENCES Music(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_music_artist ON Music(artist_id);
CREATE INDEX idx_rankings_date ON Rankings(ranking_date);
CREATE INDEX idx_rankings_platform ON Rankings(platform);
CREATE INDEX idx_playlists_user ON Playlists(user_id);
CREATE INDEX idx_music_genres ON Music_Genres(genre_id);
CREATE INDEX idx_users_email ON Users(email);
CREATE INDEX idx_user_subscriptions ON User_Subscriptions(user_id, status);
CREATE INDEX idx_payment_history_user ON Payment_History(user_id);
CREATE INDEX idx_promo_codes ON Promo_Codes(code, is_active);
CREATE INDEX idx_firebase_uid ON Users(firebase_uid);
CREATE FULLTEXT INDEX idx_music_search ON Music(title);
CREATE FULLTEXT INDEX idx_artist_search ON Artists(name);
CREATE INDEX idx_music_source ON Music(source, source_id);
CREATE INDEX idx_stream_cache_music ON Stream_Cache(music_id);
CREATE INDEX idx_streaming_errors_music ON Streaming_Errors(music_id);
CREATE INDEX idx_audio_quality_music ON Audio_Quality(music_id);

-- Trigger
DELIMITER //
CREATE TRIGGER update_popularity_score
AFTER UPDATE ON Music
FOR EACH ROW
BEGIN
    IF NEW.play_count != OLD.play_count THEN
        INSERT INTO Music_Updates (music_id, update_type, old_value, new_value)
        VALUES (
            NEW.id,
            'PLAY_COUNT',
            JSON_OBJECT('play_count', OLD.play_count),
            JSON_OBJECT('play_count', NEW.play_count)
        );
    END IF;
END //
DELIMITER ;

-- Thêm trigger để xóa cache khi cập nhật music
DELIMITER //
CREATE TRIGGER clear_stream_cache
AFTER UPDATE ON Music
FOR EACH ROW
BEGIN
    IF NEW.source != OLD.source OR NEW.source_id != OLD.source_id THEN
        DELETE FROM Stream_Cache WHERE music_id = NEW.id;
    END IF;
END //
DELIMITER ;

-- Thêm procedure để cập nhật nguồn YouTube
DELIMITER //
CREATE PROCEDURE update_youtube_source(
    IN p_music_id INT,
    IN p_youtube_id VARCHAR(50),
    IN p_youtube_url VARCHAR(255),
    IN p_youtube_thumbnail VARCHAR(255)
)
BEGIN
    UPDATE Music 
    SET 
        source = 'youtube',
        source_id = p_youtube_id,
        youtube_id = p_youtube_id,
        youtube_url = p_youtube_url,
        youtube_thumbnail = p_youtube_thumbnail,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_music_id;
END //
DELIMITER ;

-- Thêm procedure để ghi nhận lỗi streaming
DELIMITER //
CREATE PROCEDURE log_streaming_error(
    IN p_music_id INT,
    IN p_error_type VARCHAR(50),
    IN p_error_message TEXT
)
BEGIN
    INSERT INTO Streaming_Errors (music_id, error_type, error_message)
    VALUES (p_music_id, p_error_type, p_error_message);
END //
DELIMITER ;


-- Reset database
DROP DATABASE IF EXISTS app_music;
CREATE DATABASE app_music;
USE app_music;

-- Create user
DROP USER IF EXISTS 'appmusic'@'%';
CREATE USER 'appmusic'@'%' IDENTIFIED BY 'appmusic123';
GRANT ALL PRIVILEGES ON app_music.* TO 'appmusic'@'%';
FLUSH PRIVILEGES;

-- Base tables
CREATE TABLE Users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    avatar VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Artists (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    image_url VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Music (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    artist_id INT NOT NULL,
    duration INT,
    play_count INT DEFAULT 0,
    image_url VARCHAR(255),
    preview_url VARCHAR(255),
    source ENUM('youtube', 'itunes') DEFAULT 'youtube',
    source_id VARCHAR(50),
    youtube_url VARCHAR(255),
    youtube_thumbnail VARCHAR(255),
    lyrics TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (artist_id) REFERENCES Artists(id)
);

CREATE TABLE Genres (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Music_Genres (
    music_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (music_id, genre_id),
    FOREIGN KEY (music_id) REFERENCES Music(id),
    FOREIGN KEY (genre_id) REFERENCES Genres(id)
);

CREATE TABLE Playlists (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

CREATE TABLE Playlist_Songs (
    playlist_id INT,
    music_id INT,
    position INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist_id, music_id),
    FOREIGN KEY (playlist_id) REFERENCES Playlists(id) ON DELETE CASCADE,
    FOREIGN KEY (music_id) REFERENCES Music(id) ON DELETE CASCADE
);

CREATE TABLE Queue (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    music_id INT NOT NULL,
    position INT NOT NULL,
    queue_type ENUM('manual', 'playlist', 'auto') DEFAULT 'manual',
    source_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id),
    FOREIGN KEY (music_id) REFERENCES Music(id)
);

CREATE TABLE Play_History (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    music_id INT,
    play_duration INT DEFAULT 0,
    source_type ENUM('search', 'playlist', 'queue') DEFAULT 'search',
    source_id INT,
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (music_id) REFERENCES Music(id) ON DELETE CASCADE
);

CREATE TABLE Favorites (
    user_id INT,
    music_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, music_id),
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (music_id) REFERENCES Music(id) ON DELETE CASCADE
);

CREATE TABLE Rankings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    music_id INT NOT NULL,
    region ENUM('US', 'VN') NOT NULL,
    position INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (music_id) REFERENCES Music(id),
    UNIQUE KEY unique_ranking (region, position)
);

-- Create indexes
CREATE INDEX idx_music_artist ON Music(artist_id);
CREATE FULLTEXT INDEX idx_music_search ON Music(title);
CREATE FULLTEXT INDEX idx_artist_search ON Artists(name);
CREATE INDEX idx_music_source ON Music(source, source_id);
CREATE INDEX idx_queue_user ON Queue(user_id, position);
CREATE INDEX idx_history_user_date ON Play_History(user_id, played_at);
CREATE INDEX idx_playlist_songs_position ON Playlist_Songs(playlist_id, position);
CREATE INDEX idx_rankings_region ON Rankings(region, position);

-- Insert minimal required data
INSERT INTO Users (name, email) VALUES
('Default User', 'user@example.com');

INSERT INTO Artists (name, description) VALUES
('Unknown Artist', 'Default artist for system'),
('Taylor Swift', 'American singer-songwriter'),
('Ed Sheeran', 'English singer-songwriter');

INSERT INTO Genres (name, description, image_url) VALUES
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

INSERT INTO Playlists (name, description, user_id) VALUES
('My Favorites', 'My favorite songs', 1);


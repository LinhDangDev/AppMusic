CREATE DATABASE App_music;

USE App_music;

CREATE TABLE Artists (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    image_url TEXT,
    bio TEXT,
    profile_pic_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_artist_name (name)
);

CREATE TABLE Music (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    artist_id INT NOT NULL,
    image_url TEXT,
    album VARCHAR(255),
    genre VARCHAR(255),
    s3_url TEXT,
    duration INT,
    lyrics TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (artist_id) REFERENCES Artists(id) ON DELETE CASCADE,
    UNIQUE KEY unique_song (title, artist_id)
);

CREATE TABLE Users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    profile_pic_url TEXT,
    is_premium BOOLEAN DEFAULT FALSE,
    favorite_genres JSON,
    favorite_artists JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Playlists (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    is_shared BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

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
    user_id INT NOT NULL,
    music_id INT NOT NULL,
    position INT,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, music_id),
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (music_id) REFERENCES Music(id) ON DELETE CASCADE
);

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
    `rank_position` INT NOT NULL,
    ranking_date DATE DEFAULT (CURRENT_DATE),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (music_id) REFERENCES Music(id) ON DELETE CASCADE,
    UNIQUE KEY unique_ranking (platform, music_id, ranking_date)
);

CREATE INDEX idx_music_artist ON Music(artist_id);
CREATE INDEX idx_rankings_date ON Rankings(ranking_date);
CREATE INDEX idx_rankings_platform ON Rankings(platform);
CREATE INDEX idx_playlists_user ON Playlists(user_id);

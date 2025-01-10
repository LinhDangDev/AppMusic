create table Artists
(
    id         int auto_increment
        primary key,
    name       varchar(255)                        not null,
    bio        text                                null,
    image_url  varchar(255)                        null,
    created_at timestamp default CURRENT_TIMESTAMP null,
    updated_at timestamp default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint name
        unique (name)
);

create fulltext index idx_artist_search
    on Artists (name);

create table Genres
(
    id          int auto_increment
        primary key,
    name        varchar(100)                        not null,
    description text                                null,
    image_url   varchar(255)                        null,
    created_at  timestamp default CURRENT_TIMESTAMP null,
    constraint name
        unique (name)
);

create table Music
(
    id                int auto_increment
        primary key,
    title             varchar(255)                        not null,
    artist_id         int                                 null,
    album             varchar(255)                        null,
    duration          int                                 null,
    release_date      date                                null,
    youtube_thumbnail varchar(255)                        null,
    youtube_id        varchar(50)                         null,
    image_url         text                                null,
    preview_url       text                                null,
    source            varchar(50)                         null,
    source_id         varchar(255)                        null,
    play_count        int       default 0                 null,
    created_at        timestamp default CURRENT_TIMESTAMP null,
    updated_at        timestamp default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint Music_ibfk_1
        foreign key (artist_id) references Artists (id)
);

create index idx_music_artist
    on Music (artist_id);

create fulltext index idx_music_search
    on Music (title);

create definer = root@localhost trigger update_popularity_score
    after update
    on Music
    for each row
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
END;

create table Music_Genres
(
    music_id int not null,
    genre_id int not null,
    primary key (music_id, genre_id),
    constraint Music_Genres_ibfk_1
        foreign key (music_id) references Music (id)
            on delete cascade,
    constraint Music_Genres_ibfk_2
        foreign key (genre_id) references Genres (id)
            on delete cascade
);

create index idx_music_genres
    on Music_Genres (genre_id);

create table Music_Updates
(
    id          int auto_increment
        primary key,
    music_id    int                                           not null,
    update_type enum ('PLAY_COUNT', 'POPULARITY', 'METADATA') not null,
    old_value   json                                          null,
    new_value   json                                          null,
    updated_at  timestamp default CURRENT_TIMESTAMP           null,
    constraint Music_Updates_ibfk_1
        foreign key (music_id) references Music (id)
            on delete cascade
);

create index music_id
    on Music_Updates (music_id);

create table Promo_Codes
(
    id               int auto_increment
        primary key,
    code             varchar(50)                          not null,
    discount_percent int                                  null,
    discount_amount  decimal(10, 2)                       null,
    valid_from       timestamp  default CURRENT_TIMESTAMP null,
    valid_until      timestamp                            null,
    max_uses         int                                  null,
    current_uses     int        default 0                 null,
    is_active        tinyint(1) default 1                 null,
    constraint code
        unique (code)
);

create index idx_promo_codes
    on Promo_Codes (code, is_active);

create table Rankings
(
    id            int auto_increment
        primary key,
    platform      varchar(255)                        not null,
    music_id      int                                 not null,
    rank_position int                                 not null,
    ranking_date  date      default (curdate())       null,
    created_at    timestamp default CURRENT_TIMESTAMP null,
    constraint unique_ranking
        unique (platform, music_id, ranking_date),
    constraint Rankings_ibfk_1
        foreign key (music_id) references Music (id)
            on delete cascade
);

create index idx_rankings_date
    on Rankings (ranking_date);

create index idx_rankings_platform
    on Rankings (platform);

create index music_id
    on Rankings (music_id);

create table Subscription_Plans
(
    id            int auto_increment
        primary key,
    name          varchar(100)                         not null,
    description   text                                 null,
    price         decimal(10, 2)                       not null,
    duration_days int                                  not null,
    features      json                                 null,
    is_active     tinyint(1) default 1                 null,
    created_at    timestamp  default CURRENT_TIMESTAMP null
);

create table Users
(
    id               int auto_increment
        primary key,
    firebase_uid     varchar(128)                                                       not null,
    email            varchar(255)                                                       not null,
    name             varchar(255)                                                       null,
    profile_pic_url  text                                                               null,
    is_premium       tinyint(1)                               default 0                 null,
    favorite_genres  json                                                               null,
    favorite_artists json                                                               null,
    created_at       timestamp                                default CURRENT_TIMESTAMP null,
    updated_at       timestamp                                default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    last_login       timestamp                                                          null,
    status           enum ('ACTIVE', 'INACTIVE', 'SUSPENDED') default 'ACTIVE'          null,
    constraint firebase_uid
        unique (firebase_uid)
);

create table Favorites
(
    user_id    int                                 not null,
    music_id   int                                 not null,
    artist_id  int                                 not null,
    created_at timestamp default CURRENT_TIMESTAMP null,
    primary key (user_id, music_id, artist_id),
    constraint Favorites_ibfk_1
        foreign key (user_id) references Users (id)
            on delete cascade,
    constraint Favorites_ibfk_2
        foreign key (music_id) references Music (id)
            on delete cascade,
    constraint Favorites_ibfk_3
        foreign key (artist_id) references Artists (id)
            on delete cascade
);

create index artist_id
    on Favorites (artist_id);

create index music_id
    on Favorites (music_id);

create table Offline_Songs
(
    user_id         int                                 not null,
    music_id        int                                 not null,
    downloaded_at   timestamp default CURRENT_TIMESTAMP null,
    expiration_date timestamp                           null,
    primary key (user_id, music_id),
    constraint Offline_Songs_ibfk_1
        foreign key (user_id) references Users (id)
            on delete cascade,
    constraint Offline_Songs_ibfk_2
        foreign key (music_id) references Music (id)
            on delete cascade
);

create index music_id
    on Offline_Songs (music_id);

create table Playlists
(
    id         int auto_increment
        primary key,
    user_id    int                                  not null,
    name       varchar(255)                         not null,
    is_shared  tinyint(1) default 0                 null,
    created_at timestamp  default CURRENT_TIMESTAMP null,
    constraint Playlists_ibfk_1
        foreign key (user_id) references Users (id)
            on delete cascade
);

create table PlaybackState
(
    user_id             int                                                  not null
        primary key,
    current_music_id    int                                                  null,
    current_playlist_id int                                                  null,
    repeat_mode         enum ('OFF', 'ONE', 'ALL') default 'OFF'             null,
    shuffle_mode        tinyint(1)                 default 0                 null,
    last_position       int                                                  null,
    updated_at          timestamp                  default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint PlaybackState_ibfk_1
        foreign key (user_id) references Users (id)
            on delete cascade,
    constraint PlaybackState_ibfk_2
        foreign key (current_music_id) references Music (id)
            on delete set null,
    constraint PlaybackState_ibfk_3
        foreign key (current_playlist_id) references Playlists (id)
            on delete set null
);

create index current_music_id
    on PlaybackState (current_music_id);

create index current_playlist_id
    on PlaybackState (current_playlist_id);

create table Playlist_Songs
(
    playlist_id int not null,
    music_id    int not null,
    position    int null,
    primary key (playlist_id, music_id),
    constraint Playlist_Songs_ibfk_1
        foreign key (playlist_id) references Playlists (id)
            on delete cascade,
    constraint Playlist_Songs_ibfk_2
        foreign key (music_id) references Music (id)
            on delete cascade
);

create index music_id
    on Playlist_Songs (music_id);

create index idx_playlists_user
    on Playlists (user_id);

create table Queue
(
    id          int auto_increment
        primary key,
    user_id     int                                                  not null,
    music_id    int                                                  not null,
    position    int                                                  not null,
    added_at    timestamp                  default CURRENT_TIMESTAMP null,
    repeat_mode enum ('OFF', 'ONE', 'ALL') default 'OFF'             null,
    constraint unique_queue_position
        unique (user_id, position),
    constraint Queue_ibfk_1
        foreign key (user_id) references Users (id)
            on delete cascade,
    constraint Queue_ibfk_2
        foreign key (music_id) references Music (id)
            on delete cascade
);

create index music_id
    on Queue (music_id);

create table Search_History
(
    id           int auto_increment
        primary key,
    user_id      int                                 not null,
    query        varchar(255)                        not null,
    result_count int                                 null,
    searched_at  timestamp default CURRENT_TIMESTAMP null,
    constraint Search_History_ibfk_1
        foreign key (user_id) references Users (id)
            on delete cascade
);

create index user_id
    on Search_History (user_id);

create table User_Subscriptions
(
    id           int auto_increment
        primary key,
    user_id      int                                                                          not null,
    plan_id      int                                                                          not null,
    start_date   timestamp                                          default CURRENT_TIMESTAMP null,
    end_date     timestamp                                                                    not null,
    auto_renewal tinyint(1)                                         default 0                 null,
    status       enum ('ACTIVE', 'EXPIRED', 'CANCELLED', 'PENDING') default 'PENDING'         null,
    constraint User_Subscriptions_ibfk_1
        foreign key (user_id) references Users (id)
            on delete cascade,
    constraint User_Subscriptions_ibfk_2
        foreign key (plan_id) references Subscription_Plans (id)
);

create table Payment_History
(
    id              int auto_increment
        primary key,
    user_id         int                                                                         not null,
    subscription_id int                                                                         not null,
    amount          decimal(10, 2)                                                              not null,
    payment_method  varchar(50)                                                                 null,
    transaction_id  varchar(255)                                                                null,
    status          enum ('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED') default 'PENDING'         null,
    payment_date    timestamp                                         default CURRENT_TIMESTAMP null,
    constraint Payment_History_ibfk_1
        foreign key (user_id) references Users (id)
            on delete cascade,
    constraint Payment_History_ibfk_2
        foreign key (subscription_id) references User_Subscriptions (id)
);

create index idx_payment_history_user
    on Payment_History (user_id);

create index subscription_id
    on Payment_History (subscription_id);

create table Promo_Usage
(
    id              int auto_increment
        primary key,
    promo_id        int                                 not null,
    user_id         int                                 not null,
    subscription_id int                                 not null,
    used_at         timestamp default CURRENT_TIMESTAMP null,
    constraint Promo_Usage_ibfk_1
        foreign key (promo_id) references Promo_Codes (id),
    constraint Promo_Usage_ibfk_2
        foreign key (user_id) references Users (id),
    constraint Promo_Usage_ibfk_3
        foreign key (subscription_id) references User_Subscriptions (id)
);

create index promo_id
    on Promo_Usage (promo_id);

create index subscription_id
    on Promo_Usage (subscription_id);

create index user_id
    on Promo_Usage (user_id);

create index idx_user_subscriptions
    on User_Subscriptions (user_id, status);

create index plan_id
    on User_Subscriptions (plan_id);

create index idx_firebase_uid
    on Users (firebase_uid);

create index idx_users_email
    on Users (email);


/**
 * Database Type Definitions
 * Mapping from PostgreSQL schema to TypeScript interfaces
 */

// ============================================
// ENUMS (from PostgreSQL custom types)
// ============================================

export enum UserStatus {
    ACTIVE = 'ACTIVE',
    INACTIVE = 'INACTIVE',
    SUSPENDED = 'SUSPENDED'
}

export enum LoginStatus {
    SUCCESS = 'SUCCESS',
    FAILED = 'FAILED'
}

export enum RepeatMode {
    OFF = 'OFF',
    ONE = 'ONE',
    ALL = 'ALL'
}

export enum UpdateType {
    PLAY_COUNT = 'PLAY_COUNT',
    POPULARITY = 'POPULARITY',
    METADATA = 'METADATA'
}

export enum SubscriptionStatus {
    ACTIVE = 'ACTIVE',
    EXPIRED = 'EXPIRED',
    CANCELLED = 'CANCELLED',
    PENDING = 'PENDING'
}

export enum PaymentStatus {
    PENDING = 'PENDING',
    SUCCESS = 'SUCCESS',
    FAILED = 'FAILED',
    REFUNDED = 'REFUNDED'
}

export enum MusicSource {
    YOUTUBE = 'youtube',
    ITUNES = 'itunes'
}

export enum LyricsState {
    PENDING = 'PENDING',
    FOUND = 'FOUND',
    NOT_FOUND = 'NOT_FOUND'
}

export enum QueueType {
    MANUAL = 'manual',
    PLAYLIST = 'playlist',
    AUTO = 'auto'
}

export enum PlaySource {
    SEARCH = 'search',
    PLAYLIST = 'playlist',
    QUEUE = 'queue'
}

// ============================================
// USER & AUTHENTICATION TYPES
// ============================================

export interface User {
    id: number;
    email: string;
    password_hash: string;
    name: string;
    profile_pic_url?: string;
    avatar?: string;
    is_premium: boolean;
    is_email_verified: boolean;
    favorite_genres?: any;
    favorite_artists?: any;
    created_at: Date;
    updated_at: Date;
    last_login?: Date;
    status: UserStatus;
}

export interface EmailVerificationToken {
    id: number;
    user_id: number;
    token: string;
    expires_at: Date;
    created_at: Date;
}

export interface PasswordResetToken {
    id: number;
    user_id: number;
    token: string;
    expires_at: Date;
    created_at: Date;
    is_used: boolean;
}

export interface RefreshToken {
    id: number;
    user_id: number;
    token: string;
    expires_at: Date;
    created_at: Date;
    is_revoked: boolean;
    device_info?: string;
    ip_address?: string;
}

export interface LoginHistory {
    id: number;
    user_id?: number;
    ip_address?: string;
    user_agent?: string;
    login_status: LoginStatus;
    failure_reason?: string;
    created_at: Date;
}

export interface SecuritySettings {
    user_id: number;
    two_factor_enabled: boolean;
    two_factor_secret?: string;
    failed_login_attempts: number;
    last_failed_login?: Date;
    account_locked_until?: Date;
    created_at: Date;
    updated_at: Date;
}

// ============================================
// MUSIC CATALOG TYPES
// ============================================

export interface Artist {
    id: number;
    name: string;
    bio?: string;
    image_url?: string;
    description?: string;
    created_at: Date;
    updated_at: Date;
}

export interface Genre {
    id: number;
    name: string;
    description?: string;
    image_url?: string;
    created_at: Date;
    updated_at: Date;
}

export interface Music {
    id: number;
    title: string;
    artist_id?: number;
    artist_name?: string;
    album?: string;
    duration?: number;
    release_date?: Date;
    youtube_thumbnail?: string;
    youtube_id?: string;
    youtube_url?: string;
    image_url?: string;
    preview_url?: string;
    source?: MusicSource;
    source_id?: string;
    play_count: number;
    lyrics?: string;
    genius_id?: string;
    lyrics_state: LyricsState;
    created_at: Date;
    updated_at: Date;
}

export interface MusicGenre {
    music_id: number;
    genre_id: number;
}

export interface MusicUpdate {
    id: number;
    music_id: number;
    update_type: UpdateType;
    old_value?: any;
    new_value?: any;
    updated_at: Date;
}

export interface Ranking {
    id: number;
    platform: string;
    region?: string;
    music_id: number;
    rank_position: number;
    position?: number;
    ranking_date: Date;
    created_at: Date;
    updated_at: Date;
}

export interface LyricsDatabase {
    id: number;
    title: string;
    artist: string;
    lyrics?: string;
    source?: string;
    created_at: Date;
}

// ============================================
// PLAYLIST & USER INTERACTION TYPES
// ============================================

export interface Playlist {
    id: number;
    user_id: number;
    name: string;
    description?: string;
    is_shared: boolean;
    created_at: Date;
    updated_at: Date;
}

export interface PlaylistSong {
    playlist_id: number;
    music_id: number;
    position?: number;
    added_at: Date;
}

export interface Queue {
    id: number;
    user_id: number;
    music_id: number;
    position: number;
    queue_type: QueueType;
    source_id?: number;
    created_at: Date;
}

export interface Favorite {
    user_id: number;
    music_id: number;
    created_at: Date;
}

export interface PlayHistory {
    id: number;
    user_id?: number;
    music_id?: number;
    play_duration: number;
    source_type: PlaySource;
    source_id?: number;
    played_at: Date;
}

export interface SearchHistory {
    id: number;
    user_id: number;
    query: string;
    result_count?: number;
    searched_at: Date;
}

export interface OfflineSong {
    user_id: number;
    music_id: number;
    downloaded_at: Date;
    expiration_date?: Date;
}

export interface PlaybackState {
    user_id: number;
    current_music_id?: number;
    current_playlist_id?: number;
    repeat_mode: RepeatMode;
    shuffle_mode: boolean;
    last_position?: number;
    updated_at: Date;
}

// ============================================
// SUBSCRIPTION & PAYMENT TYPES
// ============================================

export interface PromoCode {
    id: number;
    code: string;
    discount_percent?: number;
    discount_amount?: number;
    valid_from: Date;
    valid_until?: Date;
    max_uses?: number;
    current_uses: number;
    is_active: boolean;
}

export interface SubscriptionPlan {
    id: number;
    name: string;
    description?: string;
    price: number;
    duration_days: number;
    features?: any;
    is_active: boolean;
    created_at: Date;
}

export interface UserSubscription {
    id: number;
    user_id: number;
    plan_id: number;
    start_date: Date;
    end_date: Date;
    auto_renewal: boolean;
    status: SubscriptionStatus;
}

export interface PaymentHistory {
    id: number;
    user_id: number;
    subscription_id: number;
    amount: number;
    payment_method?: string;
    transaction_id?: string;
    status: PaymentStatus;
    payment_date: Date;
}

export interface PromoUsage {
    id: number;
    promo_id: number;
    user_id: number;
    subscription_id: number;
    used_at: Date;
}

// ============================================
// ELASTICSEARCH SYNC TYPES
// ============================================

export interface ElasticsearchSyncQueue {
    id: number;
    entity_type: string;
    entity_id: number;
    operation: string;
    payload?: any;
    status: string;
    retry_count: number;
    error_message?: string;
    created_at: Date;
    synced_at?: Date;
}

// ============================================
// VIEW TYPES (Read-only data models)
// ============================================

export interface ActiveSession {
    id: number;
    user_id: number;
    email: string;
    name: string;
    device_info?: string;
    ip_address?: string;
    created_at: Date;
    expires_at: Date;
    session_status: 'Active' | 'Expired';
}

export interface UserMusicStats {
    user_id: number;
    name: string;
    songs_played: number;
    songs_favorited: number;
    playlists_count: number;
}

export interface ElasticsearchSyncStatus {
    entity_type: string;
    operation: string;
    status: string;
    count: number;
    latest_created: Date;
    latest_synced?: Date;
    avg_retries: number;
}

// ============================================
// COMPOSITE/DTO TYPES (For API responses)
// ============================================

export interface MusicWithDetails extends Music {
    artist_name?: string;
    genres?: Genre[];
    favorite_count?: number;
    is_favorited?: boolean;
}

export interface PlaylistWithSongs extends Playlist {
    songs?: MusicWithDetails[];
    total_songs?: number;
}

export interface UserProfile extends User {
    stats?: UserMusicStats;
    subscription?: UserSubscription;
}

export interface AuthResponse {
    user: User;
    access_token: string;
    refresh_token: string;
    expires_in: number;
}

export interface ApiResponse<T> {
    success: boolean;
    status: number;
    message: string;
    data?: T;
    error?: {
        code: string;
        details?: string;
    };
    timestamp?: Date;
}

/**
 * API Response Types
 * Standard response format for all endpoints
 */

// Standard API Response Wrapper
export interface ApiResponse<T = any> {
    success: boolean;
    data?: T;
    message?: string;
    code?: string;
    statusCode?: number;
    timestamp?: string;
    errors?: ApiError[];
}

// Pagination Info
export interface PaginationInfo {
    page: number;
    limit: number;
    total: number;
    total_pages: number;
}

// Paginated Response
export interface PaginatedResponse<T> extends ApiResponse<T[]> {
    pagination: PaginationInfo;
}

// API Error Detail
export interface ApiError {
    field?: string;
    message: string;
    code?: string;
}

// Error Codes
export enum ErrorCode {
    VALIDATION_ERROR = 'VALIDATION_ERROR',
    UNAUTHORIZED = 'UNAUTHORIZED',
    FORBIDDEN = 'FORBIDDEN',
    NOT_FOUND = 'NOT_FOUND',
    CONFLICT = 'CONFLICT',
    EMAIL_ALREADY_EXISTS = 'EMAIL_ALREADY_EXISTS',
    INVALID_CREDENTIALS = 'INVALID_CREDENTIALS',
    ACCOUNT_LOCKED = 'ACCOUNT_LOCKED',
    EMAIL_NOT_VERIFIED = 'EMAIL_NOT_VERIFIED',
    TOKEN_EXPIRED = 'TOKEN_EXPIRED',
    INTERNAL_ERROR = 'INTERNAL_ERROR',
}

// Request/Response DTOs
export namespace Auth {
    export interface RegisterRequest {
        email: string;
        password: string;
        name: string;
    }

    export interface LoginRequest {
        email: string;
        password: string;
    }

    export interface RefreshTokenRequest {
        refreshToken: string;
    }

    export interface PasswordResetRequest {
        email: string;
    }

    export interface ResetPasswordRequest {
        token: string;
        newPassword: string;
    }

    export interface ChangePasswordRequest {
        currentPassword: string;
        newPassword: string;
    }

    export interface AuthResponse {
        id: number;
        email: string;
        name: string;
        is_premium: boolean;
        accessToken: string;
        refreshToken: string;
    }

    export interface TokenRefreshResponse {
        accessToken: string;
        refreshToken: string;
    }

    export interface VerifyEmailResponse {
        success: boolean;
        message: string;
    }

    export interface PasswordResetResponse {
        success: boolean;
        message: string;
    }
}

export namespace User {
    export interface ProfileResponse {
        id: number;
        email: string;
        name: string;
        profile_pic_url?: string;
        is_premium: boolean;
        is_email_verified: boolean;
        favorite_genres?: string[];
        favorite_artists?: number[];
        created_at: string;
        last_login?: string;
    }

    export interface UpdateProfileRequest {
        name?: string;
        profile_pic_url?: string;
        favorite_genres?: string[];
        favorite_artists?: number[];
    }

    export interface PreferencesResponse {
        user_id: number;
        favorite_genres: string[];
        favorite_artists: number[];
        notification_enabled: boolean;
        privacy_mode: boolean;
    }

    export interface UpdatePreferencesRequest {
        favorite_genres?: string[];
        favorite_artists?: number[];
        notification_enabled?: boolean;
        privacy_mode?: boolean;
    }

    export interface UserStatsResponse {
        user_id: number;
        songs_played: number;
        songs_favorited: number;
        playlists_count: number;
        total_play_time: number;
        last_played_music_id?: number;
        favorite_genre?: string;
    }
}

export namespace Music {
    export interface MusicResponse {
        id: number;
        title: string;
        artist_id: number;
        artist_name: string;
        album?: string;
        duration: number;
        release_date?: string;
        youtube_id?: string;
        image_url?: string;
        play_count: number;
        created_at: string;
    }

    export interface CreateMusicRequest {
        title: string;
        artist_id: number;
        album?: string;
        duration: number;
        release_date?: string;
        youtube_id?: string;
        image_url?: string;
    }

    export interface UpdateMusicRequest {
        title?: string;
        album?: string;
        duration?: number;
        release_date?: string;
        image_url?: string;
    }

    export interface SearchMusicRequest {
        q: string;
        limit?: number;
        type?: 'title' | 'artist' | 'album';
    }

    export interface SearchMusicResponse {
        results: MusicResponse[];
        total: number;
    }
}

export namespace Playlist {
    export interface PlaylistResponse {
        id: number;
        user_id: number;
        name: string;
        description?: string;
        is_shared: boolean;
        songs_count: number;
        created_at: string;
        updated_at: string;
    }

    export interface PlaylistDetailResponse extends PlaylistResponse {
        songs: Music.MusicResponse[];
    }

    export interface CreatePlaylistRequest {
        name: string;
        description?: string;
        is_shared?: boolean;
    }

    export interface UpdatePlaylistRequest {
        name?: string;
        description?: string;
        is_shared?: boolean;
    }

    export interface AddSongRequest {
        music_id: number;
    }

    export interface RemoveSongRequest {
        music_id: number;
    }
}

export namespace Favorite {
    export interface FavoriteResponse {
        user_id: number;
        music_id: number;
        created_at: string;
    }

    export interface AddFavoriteRequest {
        music_id: number;
    }
}

export namespace Ranking {
    export interface RankingResponse {
        id: number;
        rank_position: number;
        music_id: number;
        title: string;
        artist_name: string;
        platform: string;
        region?: string;
        ranking_date: string;
    }

    export interface GetRankingsRequest {
        platform?: string;
        region?: string;
        limit?: number;
    }
}

// JWT Payload
export interface JWTPayload {
    id: number;
    email: string;
    name: string;
    is_premium: boolean;
    iat?: number;
    exp?: number;
}

// Database Models (for reference)
export interface DatabaseUser {
    id: number;
    email: string;
    password_hash: string;
    name: string;
    profile_pic_url?: string;
    is_premium: boolean;
    is_email_verified: boolean;
    favorite_genres?: any;
    favorite_artists?: any;
    created_at: string;
    updated_at: string;
    last_login?: string;
    status: 'ACTIVE' | 'INACTIVE' | 'SUSPENDED';
}

export interface DatabaseMusic {
    id: number;
    title: string;
    artist_id: number;
    album?: string;
    duration: number;
    release_date?: string;
    youtube_id?: string;
    youtube_url?: string;
    image_url?: string;
    play_count: number;
    created_at: string;
    updated_at: string;
}

export interface DatabasePlaylist {
    id: number;
    user_id: number;
    name: string;
    description?: string;
    is_shared: boolean;
    created_at: string;
    updated_at: string;
}

// Request Context (for middleware)
export interface RequestContext {
    userId?: number;
    user?: Auth.AuthResponse;
    ip: string;
    userAgent: string;
    timestamp: string;
}

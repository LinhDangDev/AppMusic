class ApiConstants {
  // Backend URL
  static const String baseUrl = 'http://localhost:3000';

  // API Paths
  static const String apiV1 = '/api/v1';

  // Auth Endpoints
  static const String authRegister = '$apiV1/auth/register';
  static const String authLogin = '$apiV1/auth/login';
  static const String authLogout = '$apiV1/auth/logout';
  static const String authRefreshToken = '$apiV1/auth/refresh-token';
  static const String authVerifyEmail = '$apiV1/auth/verify-email';
  static const String authRequestPasswordReset =
      '$apiV1/auth/request-password-reset';
  static const String authResetPassword = '$apiV1/auth/reset-password';
  static const String authChangePassword = '$apiV1/auth/change-password';

  // User Endpoints
  static const String userProfile = '$apiV1/users/profile';
  static const String userUpdate = '$apiV1/users/profile';
  static const String userDelete = '$apiV1/users/delete';

  // Music Endpoints
  static const String musicList = '$apiV1/music';
  static const String musicSearch = '$apiV1/music/search';
  static const String musicDetail = '$apiV1/music/:id';

  // Playlist Endpoints
  static const String playlistList = '$apiV1/playlists';
  static const String playlistCreate = '$apiV1/playlists';
  static const String playlistDetail = '$apiV1/playlists/:id';
  static const String playlistUpdate = '$apiV1/playlists/:id';
  static const String playlistDelete = '$apiV1/playlists/:id';

  // Favorites Endpoints
  static const String favoritesList = '$apiV1/favorites';
  static const String favoritesAdd = '$apiV1/favorites';
  static const String favoritesRemove = '$apiV1/favorites/:musicId';

  // HTTP Timeouts (in seconds)
  static const int connectTimeout = 10;
  static const int receiveTimeout = 10;
  static const int sendTimeout = 10;

  // Token configuration
  static const int accessTokenExpiryMinutes = 15;
  static const int refreshTokenExpiryDays = 7;
  static const int tokenRefreshThresholdSeconds = 60;

  // Error messages
  static const String unknownError = 'An unknown error occurred';
  static const String networkError =
      'Network error. Please check your connection';
  static const String unauthorizedError = 'Unauthorized. Please login again';
  static const String invalidCredentials = 'Invalid email or password';
  static const String accountLocked =
      'Account locked. Too many failed attempts';
  static const String emailNotVerified = 'Please verify your email first';
  static const String userNotFound = 'User not found';
  static const String emailAlreadyExists = 'Email already exists';
  static const String weakPassword =
      'Password is too weak. Use at least 8 characters with uppercase, lowercase, and numbers';
}

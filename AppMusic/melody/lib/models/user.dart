import 'enums.dart';

class User {
  final int id;
  final String email;
  final String passwordHash;
  final String name;
  final String? profilePicUrl;
  final String? avatar;
  final bool isPremium;
  final bool isEmailVerified;
  final dynamic favoriteGenres;
  final dynamic favoriteArtists;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
  final UserStatus status;

  User({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.name,
    this.profilePicUrl,
    this.avatar,
    required this.isPremium,
    required this.isEmailVerified,
    this.favoriteGenres,
    this.favoriteArtists,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      passwordHash: json['password_hash'] as String,
      name: json['name'] as String,
      profilePicUrl: json['profile_pic_url'] as String?,
      avatar: json['avatar'] as String?,
      isPremium: json['is_premium'] as bool? ?? false,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      favoriteGenres: json['favorite_genres'],
      favoriteArtists: json['favorite_artists'],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      status:
          UserStatus.values.byName((json['status'] as String).toLowerCase()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'password_hash': passwordHash,
        'name': name,
        'profile_pic_url': profilePicUrl,
        'avatar': avatar,
        'is_premium': isPremium,
        'is_email_verified': isEmailVerified,
        'favorite_genres': favoriteGenres,
        'favorite_artists': favoriteArtists,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'last_login': lastLogin?.toIso8601String(),
        'status': status.name.toUpperCase(),
      };
}

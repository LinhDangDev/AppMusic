// Artists table model

class Artist {
  final int id;
  final String name;
  final String? bio;
  final String? imageUrl;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Artist({
    required this.id,
    required this.name,
    this.bio,
    this.imageUrl,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] as int,
      name: json['name'] as String,
      bio: json['bio'] as String?,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bio': bio,
        'image_url': imageUrl,
        'description': description,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

import 'package:flutter/material.dart';

// Genres table model

class Genre {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final Color borderColor;
  final DateTime createdAt;
  final DateTime updatedAt;

  Genre({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.borderColor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      borderColor: _getGenreColor(json['name'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image_url': imageUrl,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  /// Generate a consistent color for genre based on name
  static Color _getGenreColor(String genreName) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.cyan,
      Colors.lime,
    ];
    final index = genreName.hashCode % colors.length;
    return colors[index.abs()];
  }
}

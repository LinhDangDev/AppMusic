import 'package:flutter/material.dart';
import 'dart:math';

class Genre {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final Color borderColor;

  Genre({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.borderColor,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      borderColor: _getRandomColor(),
    );
  }

  static Color _getRandomColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[Random().nextInt(colors.length)];
  }
} 
import 'package:flutter/material.dart';

class AppColors {
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF121212),
      Color(0xFF1E1E1E),
      Color(0xFF121212),
    ],
    stops: [0.0, 0.5, 1.0],
  );
} 
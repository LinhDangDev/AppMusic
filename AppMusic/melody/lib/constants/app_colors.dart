import 'package:flutter/material.dart';

class AppColors {
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF353340),
      Color(0xFF161718),
      Color(0xFF353340),
    ],
    stops: [0.0, 0.6, 1.0],
  );
} 
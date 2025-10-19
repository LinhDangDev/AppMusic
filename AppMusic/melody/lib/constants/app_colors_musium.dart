import 'package:flutter/material.dart';

/// Musium Design System - Color Palette
/// Modern dark theme with teal/cyan accents
class AppColorMusium {
  // ============================================================================
  // PRIMARY BACKGROUND COLORS
  // ============================================================================

  /// Main dark background - darkest level
  static const Color darkBg = Color(0xFF1E1E1E);

  /// Surface background - primary interactive elements
  static const Color darkSurface = Color(0xFF2A2A2A);

  /// Light surface - elevated interactive elements
  static const Color darkSurfaceLight = Color(0xFF333333);

  /// Lightest surface - cards, popups
  static const Color darkSurfaceLighter = Color(0xFF404040);

  // ============================================================================
  // PRIMARY ACCENT COLORS
  // ============================================================================

  /// Primary accent - buttons, active states, highlights
  static const Color accentTeal = Color(0xFF00C8C8);

  /// Primary accent dark variant
  static const Color accentTealDark = Color(0xFF00A0A0);

  /// Primary accent light variant
  static const Color accentTealLight = Color(0xFF00E6E6);

  /// Secondary accent - gradients, overlays
  static const Color accentPurple = Color(0xFFB83DFF);

  /// Secondary accent dark variant
  static const Color accentPurpleDark = Color(0xFF9A1FE3);

  /// Tertiary accent - highlights, special elements
  static const Color accentPink = Color(0xFFFF00FF);

  // ============================================================================
  // TEXT COLORS
  // ============================================================================

  /// Primary text - headings, main content
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text - subtitles, metadata
  static const Color textSecondary = Color(0xFFA0A0A0);

  /// Tertiary text - hints, timestamps, disabled
  static const Color textTertiary = Color(0xFF707070);

  /// Disabled text
  static const Color textDisabled = Color(0xFF505050);

  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================

  /// Success state - positive actions, confirmations
  static const Color success = Color(0xFF00C8C8);

  /// Error state - errors, warnings, destructive actions
  static const Color error = Color(0xFFFF5252);

  /// Warning state - warnings, cautions
  static const Color warning = Color(0xFFFFA726);

  /// Info state - informational messages
  static const Color info = Color(0xFF00C8C8);

  // ============================================================================
  // OVERLAY & TRANSPARENCY COLORS
  // ============================================================================

  /// Overlay for modals - semi-transparent black
  static const Color overlayDark = Color(0x80000000);

  /// Overlay for elements
  static const Color overlay20 = Color(0x33000000);
  static const Color overlay40 = Color(0x66000000);
  static const Color overlay60 = Color(0x99000000);
  static const Color overlay80 = Color(0xCCFFFFFF);

  // ============================================================================
  // GRADIENT DEFINITIONS
  // ============================================================================

  /// Main dark gradient background
  static const LinearGradient darkGradientBg = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkBg, darkSurface],
  );

  /// Teal accent gradient
  static const LinearGradient accentTealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentTeal, accentTealDark],
  );

  /// Purple accent gradient
  static const LinearGradient accentPurpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPurple, accentPurpleDark],
  );

  /// Welcome screen gradient
  static const LinearGradient welcomeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [accentPurple, accentPink],
  );

  /// Featured content gradient
  static const LinearGradient featuredGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentTeal, accentPurple],
  );

  // ============================================================================
  // GENRE CARD COLORS
  // ============================================================================

  static const Map<String, Color> genreColors = {
    'pop': Color(0xFFFF006E),
    'rock': Color(0xFFFF8C00),
    'jazz': Color(0xFF00C8FF),
    'classical': Color(0xFFB83DFF),
    'hiphop': Color(0xFFFFD60A),
    'electronic': Color(0xFF00E6E6),
    'indie': Color(0xFF00C8C8),
    'country': Color(0xFFD4A574),
    'rnb': Color(0xFFE91E63),
    'reggae': Color(0xFF4CAF50),
    'latin': Color(0xFFFFA500),
    'k-pop': Color(0xFFFF1493),
  };

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get genre color by name
  static Color getGenreColor(String genre) {
    return genreColors[genre.toLowerCase()] ?? accentTeal;
  }

  /// Create a semi-transparent color
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Check if color is light or dark
  static bool isLight(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }
}

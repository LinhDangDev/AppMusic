import 'package:flutter/material.dart';
import 'app_colors_musium.dart';

/// Musium Design System - Typography
/// Modern sans-serif typography with clear hierarchy
class AppTypographyMusium {
  // ============================================================================
  // HEADING STYLES
  // ============================================================================

  /// Large primary heading - 32px, bold, used for welcome/onboarding screens
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColorMusium.textPrimary,
  );

  /// Secondary heading - 24px, semibold, used for screen titles
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.25,
    color: AppColorMusium.textPrimary,
  );

  /// Tertiary heading - 20px, semibold, used for section headers
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
    color: AppColorMusium.textPrimary,
  );

  /// Small heading - 18px, semibold, used for subsection headers
  static const TextStyle heading4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
    color: AppColorMusium.textPrimary,
  );

  /// Extra small heading - 16px, semibold
  static const TextStyle heading5 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
    color: AppColorMusium.textPrimary,
  );

  // ============================================================================
  // BODY STYLES
  // ============================================================================

  /// Large body text - 16px, regular, used for song titles, primary content
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
    color: AppColorMusium.textPrimary,
  );

  /// Medium body text - 14px, regular, used for artist names, secondary info
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    height: 1.43,
    color: AppColorMusium.textSecondary,
  );

  /// Small body text - 12px, regular, used for timestamps, descriptions
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.33,
    color: AppColorMusium.textTertiary,
  );

  // ============================================================================
  // LABEL STYLES
  // ============================================================================

  /// Large label - 14px, bold, used for button text, tab labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColorMusium.textPrimary,
  );

  /// Medium label - 12px, bold, used for badges, tags
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.33,
    color: AppColorMusium.textSecondary,
  );

  /// Small label - 11px, bold, used for small text labels
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.45,
    color: AppColorMusium.textTertiary,
  );

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Apply color to any text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Make text bold/emphasized
  static TextStyle emphasized(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w700);
  }

  /// Make text light
  static TextStyle light(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w300);
  }

  /// Combine multiple text style properties
  static TextStyle combine({
    required TextStyle baseStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return baseStyle.copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // ============================================================================
  // THEME DATA CREATION
  // ============================================================================

  /// Create Material 3 dark theme with Musium typography
  static ThemeData createDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColorMusium.accentTeal,
        secondary: AppColorMusium.accentPurple,
        tertiary: AppColorMusium.accentPink,
        surface: AppColorMusium.darkSurface,
        background: AppColorMusium.darkBg,
        error: AppColorMusium.error,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: AppColorMusium.textPrimary,
        onBackground: AppColorMusium.textPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColorMusium.darkBg,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorMusium.darkSurface,
        surfaceTintColor: AppColorMusium.darkSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: heading2.copyWith(
          color: AppColorMusium.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColorMusium.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColorMusium.darkSurfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: heading1,
        displayMedium: heading2,
        displaySmall: heading3,
        headlineLarge: heading1,
        headlineMedium: heading2,
        headlineSmall: heading3,
        titleLarge: heading4,
        titleMedium: heading5,
        titleSmall: heading5.copyWith(
          color: AppColorMusium.textSecondary,
        ),
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColorMusium.darkSurfaceLight,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColorMusium.textTertiary,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColorMusium.textTertiary,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColorMusium.accentTeal,
            width: 2,
          ),
        ),
        hintStyle: bodyMedium.copyWith(
          color: AppColorMusium.textTertiary,
        ),
        labelStyle: bodyMedium.copyWith(
          color: AppColorMusium.textSecondary,
        ),
        errorStyle: bodySmall.copyWith(
          color: AppColorMusium.error,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorMusium.accentTeal,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: labelLarge.copyWith(
            color: Colors.black,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorMusium.accentTeal,
          side: const BorderSide(
            color: AppColorMusium.accentTeal,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorMusium.accentTeal,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          textStyle: labelLarge,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColorMusium.darkSurface,
        selectedItemColor: AppColorMusium.accentTeal,
        unselectedItemColor: AppColorMusium.textTertiary,
        selectedLabelStyle: labelMedium.copyWith(
          color: AppColorMusium.accentTeal,
        ),
        unselectedLabelStyle: labelMedium.copyWith(
          color: AppColorMusium.textTertiary,
        ),
        elevation: 8,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColorMusium.accentTeal,
        unselectedLabelColor: AppColorMusium.textTertiary,
        indicatorColor: AppColorMusium.accentTeal,
        labelStyle: labelLarge,
        unselectedLabelStyle: labelMedium,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColorMusium.darkSurfaceLight,
        labelStyle: labelMedium,
        secondaryLabelStyle: labelMedium.copyWith(
          color: AppColorMusium.accentTeal,
        ),
        brightness: Brightness.dark,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColorMusium.darkSurfaceLight,
        contentTextStyle: bodyMedium,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

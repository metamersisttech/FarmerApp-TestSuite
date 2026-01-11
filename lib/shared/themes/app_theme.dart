import 'package:flutter/material.dart';

/// App Theme
///
/// Centralized theme configuration for the app.
/// Contains colors, typography, and component themes.

class AppTheme {
  // ============ Brand Colors ============
  static const Color primaryColor = Color(0xFF3B9B59); // Green
  static const Color primaryLight = Color(0xFF5CB87A);
  static const Color primaryDark = Color(0xFF2D7A45);

  static const Color secondaryColor = Color(0xFFF1EFE6); // Light cream
  static const Color secondaryForeground = Color(0xFF524B41);
  static const Color accentColor = Color(0xFFF0A63A); // Orange

  // ============ Neutral Colors ============
  static const Color backgroundColor = Color(0xFFFAF9F3); // Cream/off-white
  static const Color surfaceColor = Color(0xFFFFFFFF); // Card white
  static const Color errorColor = Color(0xFFD6453A); // Destructive red
  static const Color successColor = Color(0xFF3B9B59); // Same as primary green
  static const Color warningColor = Color(0xFFF0A63A); // Orange accent

  // ============ Border & Input Colors ============
  static const Color borderColor = Color(0xFFE3E0D6);
  static const Color inputColor = Color(0xFFF4F3ED);
  static const Color mutedColor = Color(0xFFF4F3ED);
  static const Color mutedForeground = Color(0xFF7A7266);

  // ============ Auth Colors ============
  static const Color authBackgroundColor = Color(0xFFFAF9F3); // Same as background
  static const Color authPrimaryColor = Color(0xFF3B9B59); // Primary green
  static const Color authFieldFillColor = Color(0xFFF4F3ED); // Input/muted color
  static const Color authBorderColor = Color(0xFFE3E0D6); // Border color
  static const Color authTextPrimary = Color(0xFF3A352D); // Foreground
  static const Color authTextSecondary = Color(0xFF7A7266); // Muted foreground

  // ============ Text Colors ============
  static const Color textPrimary = Color(0xFF3A352D); // Foreground
  static const Color textSecondary = Color(0xFF7A7266); // Muted foreground
  static const Color textHint = Color(0xFF7A7266);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ============ Border Radius ============
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 18.0;
  static const double borderRadiusXLarge = 24.0;

  // ============ Light Theme ============
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: textOnPrimary,
        onSecondary: textOnPrimary,
        onSurface: textPrimary,
        onError: textOnPrimary,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryColor),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: textHint),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: textHint),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textHint),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textPrimary),
        bodySmall: TextStyle(fontSize: 12, color: textSecondary),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
    );
  }

  // ============ Dark Theme (Optional) ============
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Color(0xFF1E1E1E),
        error: errorColor,
        onPrimary: textOnPrimary,
        onSecondary: textOnPrimary,
        onSurface: Colors.white,
        onError: textOnPrimary,
      ),
    );
  }
}

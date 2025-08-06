import 'package:flutter/material.dart';

class AppTheme {
  // 1. Core palette
  static const Color primary         = Color(0xFF00796B); // Deep Teal
  static const Color secondary       = Color(0xFFFF7043); // Sunset Orange
  static const Color backgroundLight = Color(0xFFF5F5F5); // Light Gray
  static const Color surface         = Color(0xFFFFFFFF); // White
  static const Color textPrimary     = Color(0xFF212121); // Dark Charcoal
  static const Color textSecondary   = Color(0xFF000000); // Black
  static const Color hintText        = Color(0xFFA7A7A7); // Gray

  // 2. Opacity variants as consts (no .withOpacity())
  static const Color surface12       = Color(0x1FFFFFFF); // ~12% black-on-white
  static const Color white14         = Color.fromRGBO(255, 255, 255, 0.14);

  // 3. ThemeData
  static final ThemeData customTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: surface,
    primaryColor: primary,

    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      background: surface,
      surface: surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: textPrimary,
      onSurface: textPrimary,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      iconTheme: IconThemeData(color: textSecondary),
      titleTextStyle: TextStyle(
        color: textSecondary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textSecondary),
      titleLarge: TextStyle(
        color: textSecondary,
        fontWeight: FontWeight.bold,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,
      hintStyle: TextStyle(
        color: hintText,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.all(12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: white14,  // use our const
          width: 1,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: white14,  // use our const
          width: 1,
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: surface,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  );
}

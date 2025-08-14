import 'package:flutter/material.dart';
import 'dart:ui';

class GlassTheme {
  // Primary Colors - Rich Brown Theme
  static const Color primaryColor = Color(0xFF8B4513); // Saddle Brown
  static const Color secondaryColor = Color(0xFFA0522D); // Sienna
  static const Color accentColor = Color(0xFFCD853F); // Peru
  static const Color lightBrown = Color(0xFFDEB887); // Burlywood
  static const Color pastelBrown = Color(0xFFF5DEB3); // Wheat
  static const Color creamBrown = Color(0xFFFDF5E6); // Old Lace

  // Background Colors
  static const Color backgroundColor = Color(0xFF2F1B14); // Dark Brown
  static const Color surfaceColor = Color(0xFFFDF5E6); // Cream
  static const Color cardColor = Color(0xFFFFFFFF); // White

  // Text Colors
  static const Color primaryTextColor = Color(0xFF2F1B14); // Dark Brown
  static const Color secondaryTextColor = Color(0xFF5D4037); // Brown Grey
  static const Color lightTextColor = Color(0xFF8D6E63); // Light Brown Grey
  static const Color whiteTextColor = Color(0xFFFFFFFF); // White

  // Status Colors
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color warningColor = Color(0xFFFF9800); // Orange
  static const Color errorColor = Color(0xFFF44336); // Red
  static const Color infoColor = Color(0xFF2196F3); // Blue

  // Glass Effect Colors
  static const List<Color> glassGradient = [
    Color(0xFF8B4513), // Saddle Brown
    Color(0xFFA0522D), // Sienna
    Color(0xFFCD853F), // Peru
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFF2F1B14), // Dark Brown
    Color(0xFF5D4037), // Brown Grey
    Color(0xFF8B4513), // Saddle Brown
  ];

  // Glass Effect Decorations
  static BoxDecoration get glassCardDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: 0.8),
            secondaryColor.withValues(alpha: 0.7),
            accentColor.withValues(alpha: 0.6),
          ],
        ),
        border: Border.all(
          color: pastelBrown.withValues(alpha: 0.4),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: pastelBrown.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: pastelBrown.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
            spreadRadius: 1,
          ),
        ],
      );

  static BoxDecoration get backgroundDecoration => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: backgroundGradient,
        ),
      );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor.withValues(alpha: 0.1),
        foregroundColor: whiteTextColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: whiteTextColor,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: whiteTextColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: whiteTextColor,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pastelBrown.withValues(alpha: 0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: pastelBrown.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: pastelBrown.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(color: lightTextColor.withValues(alpha: 0.7)),
        labelStyle: const TextStyle(color: primaryTextColor),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceColor.withValues(alpha: 0.01),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return surfaceColor.withValues(alpha: 0.01);
        }),
        checkColor: WidgetStateProperty.all(whiteTextColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: whiteTextColor,
          fontFamily: 'Poppins',
          letterSpacing: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: whiteTextColor,
          fontFamily: 'Poppins',
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: whiteTextColor,
          fontFamily: 'Poppins',
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: whiteTextColor,
          fontFamily: 'Poppins',
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: whiteTextColor,
          fontFamily: 'Poppins',
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: whiteTextColor,
          fontFamily: 'Poppins',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: whiteTextColor,
          fontFamily: 'Poppins',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: whiteTextColor,
          fontFamily: 'Poppins',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: pastelBrown,
          fontFamily: 'Poppins',
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: whiteTextColor,
          fontFamily: 'Poppins',
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: whiteTextColor,
          fontFamily: 'Poppins',
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: pastelBrown,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  // Glass Effect Widgets
  static Widget glassCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double borderRadius = 24,
    double blurSigma = 25.0,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: glassCardDecoration.copyWith(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  static Widget glassBackground({
    required Widget child,
    double blurSigma = 3.0,
  }) {
    return Container(
      decoration: backgroundDecoration,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                backgroundColor.withValues(alpha: 0.9),
                primaryColor.withValues(alpha: 0.3),
                backgroundColor.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

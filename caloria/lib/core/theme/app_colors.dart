import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42D6);

  // Accent
  static const Color accent = Color(0xFFFF6584);

  // Background
  static const Color backgroundLight = Color(0xFFF8F9FE);
  static const Color backgroundDark = Color(0xFF0F0F1A);

  // Surface
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1A2E);

  // Card
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF16213E);

  // Text
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textPrimaryDark = Color(0xFFF8F9FE);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // Macros
  static const Color protein = Color(0xFF6C63FF);
  static const Color carbs = Color(0xFFFFB347);
  static const Color fat = Color(0xFFFF6584);
  static const Color calories = Color(0xFF43E97B);

  // Water
  static const Color water = Color(0xFF43BFFF);

  // Success / Error
  static const Color success = Color(0xFF43E97B);
  static const Color error = Color(0xFFFF6584);
  static const Color warning = Color(0xFFFFB347);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9D97FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient calorieGradient = LinearGradient(
    colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient proteinGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9D97FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient carbsGradient = LinearGradient(
    colors: [Color(0xFFFFB347), Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fatGradient = LinearGradient(
    colors: [Color(0xFFFF6584), Color(0xFFFF8FA3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

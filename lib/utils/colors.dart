import 'package:flutter/material.dart';

/// AmritaULABS App Colors based on official Amrita University branding
class AppColors {
  // Primary Brand Colors (from official Amrita branding)
  static const Color primaryMaroon = Color(0xFFA4123F); // Pantone 7426C
  static const Color black90 = Color(0xFF1A1A1A); // Black 90%
  
  // Supporting Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color darkGray = Color(0xFF666666);
  static const Color mediumGray = Color(0xFF999999);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Input Field Colors
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFocusBorder = primaryMaroon;
  static const Color inputFill = Color(0xFFFAFAFA);
  
  // Button Colors
  static const Color buttonPrimary = primaryMaroon;
  static const Color buttonSecondary = Color(0xFFE8E8E8);
  static const Color buttonDisabled = Color(0xFFCCCCCC);
  
  // Text Colors
  static const Color textPrimary = black90;
  static const Color textSecondary = darkGray;
  static const Color textLight = mediumGray;
  static const Color textOnPrimary = white;
  
  // Background Colors
  static const Color background = white;
  static const Color cardBackground = white;
  static const Color divider = Color(0xFFE5E5E5);
}
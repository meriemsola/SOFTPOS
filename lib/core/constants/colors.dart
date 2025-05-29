import 'package:flutter/material.dart';

class TColors {
  // App theme colors
  static const Color primary = Color(0xFF0543E4); // Updated to #0543E4
  static const Color secondary = Color(0xFF03257E); // Updated to #03257E
  static const Color accent = Color(0xFF1A73E8); // Adjusted to complement new primary

  // Text colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textWhite = Colors.white;

  // Background colors
  static const Color light = Color(0xFFE8F0FE); // Adjusted to lighter version of primary
  static const Color dark = Color(0xFF03257E); // Updated to match secondary
  static const Color primaryBackground = Color(0xFFD2E3FC); // Adjusted to complement new palette

  // Background Container colors
  static const Color lightContainer = Color(0xFFF5F8FF); // Light blue tint
  static Color darkContainer = TColors.white.withValues(
    alpha: 0.1,
  ); // Fixed withValues to withOpacity

  // Button colors
  static const Color buttonPrimary = Color(0xFF2563EB); // Matches primary
  static const Color buttonSecondary = Color(0xFF3B82F6); // Vibrant secondary
  static const Color buttonDisabled = Color(0xFFD1D5DB); // Modern disabled

  // Border colors
  static const Color borderPrimary = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFE6E6E6);

  // Error and validation colors
  static const Color error = Color(0xFFDC2626); // Vibrant red
  static const Color success = Color(0xFF059669); // Fresh green
  static const Color warning = Color(0xFFD97706); // Bright amber
  static const Color info = Color(0xFF0284C7); // Vivid info blue

  // Neutral Shades
  static const Color black = Color(0xFF232323);
  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);
}

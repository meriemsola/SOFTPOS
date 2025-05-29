import 'package:hce_emv/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTextTheme {
  AppTextTheme._();
  static const String primaryFont = 'Poppins';
  static const String secondaryFont = 'Inter';

  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: AppColors.lightDarkText,
      fontFamily: primaryFont,
    ),
    headlineMedium: const TextStyle().copyWith(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      color: AppColors.lightDarkText,
      fontFamily: primaryFont,
    ),
    headlineSmall: const TextStyle().copyWith(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: AppColors.lightDarkText,
      fontFamily: primaryFont,
    ),

    titleLarge: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: AppColors.lightDarkText,
      fontFamily: primaryFont,
    ),
    titleMedium: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: AppColors.lightDarkText,
      fontFamily: primaryFont,
    ),
    titleSmall: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      color: AppColors.lightDarkText,
      fontFamily: primaryFont,
    ),

    bodyLarge: const TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: AppColors.lightDarkText,
      fontFamily: secondaryFont,
    ),
    bodyMedium: const TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: AppColors.lightDarkText,
      fontFamily: secondaryFont,
    ),
    bodySmall: const TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: AppColors.lightDarkText.withValues(alpha: 0.5),
      fontFamily: secondaryFont,
    ),

    labelLarge: const TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: AppColors.lightDarkText,
      fontFamily: secondaryFont,
    ),
    labelMedium: const TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: AppColors.lightDarkText.withValues(alpha: 0.5),
      fontFamily: secondaryFont,
    ),
  );

  /// Customizable Dark Text Theme
  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: AppColors.darkDarkText,
      fontFamily: primaryFont,
    ),
    headlineMedium: const TextStyle().copyWith(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      color: AppColors.darkDarkText,
      fontFamily: primaryFont,
    ),
    headlineSmall: const TextStyle().copyWith(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: AppColors.darkDarkText,
      fontFamily: primaryFont,
    ),

    titleLarge: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: AppColors.darkDarkText,
      fontFamily: primaryFont,
    ),
    titleMedium: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: AppColors.darkDarkText,
      fontFamily: primaryFont,
    ),
    titleSmall: const TextStyle().copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      color: AppColors.darkDarkText,
      fontFamily: primaryFont,
    ),

    bodyLarge: const TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: AppColors.darkDarkText,
      fontFamily: secondaryFont,
    ),
    bodyMedium: const TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: AppColors.darkDarkText,
      fontFamily: secondaryFont,
    ),
    bodySmall: const TextStyle().copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: AppColors.darkDarkText.withValues(alpha: 0.5),
      fontFamily: secondaryFont,
    ),

    labelLarge: const TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: AppColors.darkDarkText,
      fontFamily: secondaryFont,
    ),
    labelMedium: const TextStyle().copyWith(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: AppColors.darkDarkText.withValues(alpha: 0.5),
      fontFamily: secondaryFont,
    ),
  );
}

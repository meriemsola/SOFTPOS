import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/theme/widget_theme/bottom_sheet_theme.dart';
import 'package:hce_emv/theme/widget_theme/elevated_button_theme.dart';
import 'package:hce_emv/theme/widget_theme/outlined_button_theme.dart';
import 'package:hce_emv/theme/widget_theme/text_field_theme.dart';
import 'package:hce_emv/theme/widget_theme/text_theme.dart';
import 'package:hce_emv/theme/widget_theme/appbar_theme.dart';
import 'package:hce_emv/theme/widget_theme/chip_theme.dart'; // Add this import
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightCard,
    primaryColor: AppColors.primary,
    textTheme: AppTextTheme.lightTextTheme,
    useMaterial3: true,
    elevatedButtonTheme: AppElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: AppOutlinedButtonTheme.lightOutlinedButtonTheme,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    bottomSheetTheme: AppBottomSheetTheme.lightBottomSheetTheme,
    chipTheme: AppChipTheme.lightChipTheme, // Add chip theme
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primary.withValues(alpha: 0.2),
      onPrimaryContainer: AppColors.primary.withValues(alpha: 0.8),
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondary.withValues(alpha: 0.2),
      onSecondaryContainer: AppColors.secondary.withValues(alpha: 0.8),
      tertiary: AppColors.primaryDeepBlue,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.primaryDeepBlue.withValues(alpha: 0.2),
      onTertiaryContainer: AppColors.primaryDeepBlue.withValues(alpha: 0.8),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.error.withValues(alpha: 0.2),
      onErrorContainer: AppColors.error.withValues(alpha: 0.8),
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightDarkText,
      surfaceContainerHigh: AppColors.lightBackground.withValues(alpha: 0.7),
      onSurfaceVariant: AppColors.lightMediumText,
      outline: AppColors.lightMediumText.withValues(alpha: 0.5),
      outlineVariant: AppColors.lightMediumText.withValues(alpha: 0.3),
      shadow: Colors.black.withValues(alpha: 0.1),
      scrim: Colors.black.withValues(alpha: 0.3),
      inverseSurface: AppColors.darkCard,
      onInverseSurface: AppColors.darkDarkText,
      inversePrimary: AppColors.secondary,
      surfaceTint: Colors.transparent,
    ),
    inputDecorationTheme: AppTextFormFieldTheme.lightInputDecorationTheme,
    dividerTheme: DividerThemeData(
      color: AppColors.lightMediumText.withValues(alpha: 0.2),
      thickness: 1,
    ),
    iconTheme: IconThemeData(color: AppColors.primary, size: 24),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.lightDarkText.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: TextStyle(color: Colors.white, fontSize: 14),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCard,
    primaryColor:
        AppColors.secondary, // Switch to use secondary as primary in dark theme
    textTheme: AppTextTheme.darkTextTheme,
    useMaterial3: true,
    elevatedButtonTheme: AppElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: AppOutlinedButtonTheme.darkOutlinedButtonTheme,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    bottomSheetTheme: AppBottomSheetTheme.darkBottomSheetTheme,
    chipTheme: AppChipTheme.darkChipTheme, // Add chip theme
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.secondary, // Use secondary as primary in dark mode
      onPrimary: AppColors.darkBackground,
      primaryContainer: AppColors.secondary.withValues(alpha: 0.2),
      onPrimaryContainer: AppColors.secondary.withValues(alpha: 0.8),
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondary.withValues(alpha: 0.2),
      onSecondaryContainer: AppColors.secondary.withValues(alpha: 0.8),
      tertiary: AppColors.gold,
      onTertiary: Colors.black,
      tertiaryContainer: AppColors.gold.withValues(alpha: 0.2),
      onTertiaryContainer: AppColors.gold.withValues(alpha: 0.8),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.error.withValues(alpha: 0.2),
      onErrorContainer: AppColors.error.withValues(alpha: 0.8),
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkDarkText,
      surfaceContainerHighest: AppColors.darkBackground.withValues(alpha: 0.7),
      onSurfaceVariant: AppColors.darkMediumText,
      outline: AppColors.darkMediumText.withValues(alpha: 0.5),
      outlineVariant: AppColors.darkMediumText.withValues(alpha: 0.3),
      shadow: Colors.black.withValues(alpha: 0.3),
      scrim: Colors.black.withValues(alpha: 0.5),
      inverseSurface: AppColors.lightCard,
      onInverseSurface: AppColors.lightDarkText,
      inversePrimary: AppColors.primary,
      surfaceTint: Colors.transparent,
    ),
    inputDecorationTheme: AppTextFormFieldTheme.darkInputDecorationTheme,
    dividerTheme: DividerThemeData(
      color: AppColors.darkMediumText.withValues(alpha: 0.2),
      thickness: 1,
    ),
    iconTheme: IconThemeData(color: AppColors.secondary, size: 24),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.darkMediumText.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: TextStyle(color: AppColors.darkDarkText, fontSize: 14),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
    ),
  );
}

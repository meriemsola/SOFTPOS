import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/theme/app_sizes.dart';
import 'package:flutter/material.dart';

class AppChipTheme {
  AppChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: AppColors.lightBackground,
    selectedColor: AppColors.primary.withValues(alpha: 0.2),
    backgroundColor: AppColors.lightBackground,
    labelStyle: const TextStyle(
      color: AppColors.lightDarkText,
      fontSize: AppSizes.fontSizeSm,
    ),
    secondaryLabelStyle: const TextStyle(
      color: Colors.white,
      fontSize: AppSizes.fontSizeSm,
      fontWeight: FontWeight.w600,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    brightness: Brightness.light,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.fontSizeSm),
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
    ),
    secondarySelectedColor: AppColors.primary,
    checkmarkColor: AppColors.primary,
  );

  static ChipThemeData darkChipTheme = ChipThemeData(
    disabledColor: AppColors.darkBackground,
    selectedColor: AppColors.secondary.withValues(alpha: 0.2),
    backgroundColor: AppColors.darkBackground,
    labelStyle: const TextStyle(
      color: AppColors.darkDarkText,
      fontSize: AppSizes.fontSizeSm,
    ),
    secondaryLabelStyle: const TextStyle(
      color: AppColors.darkBackground,
      fontSize: AppSizes.fontSizeSm,
      fontWeight: FontWeight.w600,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    brightness: Brightness.dark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.fontSizeSm),
      side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.3)),
    ),
    secondarySelectedColor: AppColors.secondary,
    checkmarkColor: AppColors.darkBackground,
  );
}

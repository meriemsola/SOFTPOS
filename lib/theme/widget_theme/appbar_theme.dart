import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/theme/app_sizes.dart';
import 'package:flutter/material.dart';

class TAppBarTheme {
  TAppBarTheme._();

  static final lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 2,
    shadowColor: AppColors.lightMediumText.withValues(alpha: 0.1),
    backgroundColor: AppColors.lightBackground,
    foregroundColor: AppColors.lightDarkText,
    surfaceTintColor: Colors.transparent,
    iconTheme: const IconThemeData(
      color: AppColors.primary,
      size: AppSizes.iconMd,
    ),
    actionsIconTheme: const IconThemeData(
      color: AppColors.primary,
      size: AppSizes.iconMd,
    ),
    titleTextStyle: const TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: AppColors.lightDarkText,
    ),
    toolbarTextStyle: const TextStyle(color: AppColors.lightMediumText),
  );

  static final darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 2,
    shadowColor: Colors.black.withValues(alpha: 0.2),
    backgroundColor: AppColors.darkBackground,
    foregroundColor: AppColors.darkDarkText,
    surfaceTintColor: Colors.transparent,
    iconTheme: const IconThemeData(
      color: AppColors.secondary,
      size: AppSizes.iconMd,
    ),
    actionsIconTheme: const IconThemeData(
      color: AppColors.secondary,
      size: AppSizes.iconMd,
    ),
    titleTextStyle: const TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: AppColors.darkDarkText,
    ),
    toolbarTextStyle: const TextStyle(color: AppColors.darkMediumText),
  );
}

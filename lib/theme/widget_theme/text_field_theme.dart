import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/theme/app_sizes.dart';
import 'package:flutter/material.dart';

class AppTextFormFieldTheme {
  AppTextFormFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: AppColors.primary,
    suffixIconColor: AppColors.primary,
    fillColor: AppColors.lightCard,
    filled: true,
    contentPadding: EdgeInsets.symmetric(
      horizontal: AppSizes.inputFieldRadius,
      vertical: AppSizes.fontSizeMd,
    ),
    labelStyle: const TextStyle().copyWith(
      fontSize: AppSizes.fontSizeMd,
      color: AppColors.lightMediumText,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: const TextStyle().copyWith(
      fontSize: AppSizes.fontSizeSm,
      color: AppColors.lightMediumText.withValues(alpha: 0.7),
    ),
    errorStyle: const TextStyle().copyWith(
      fontStyle: FontStyle.normal,
      color: AppColors.error,
      fontSize: AppSizes.fontSizeSm,
    ),
    floatingLabelStyle: const TextStyle().copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(
        width: 0.5,
        color: AppColors.lightMediumText,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: AppColors.lightMediumText),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 2, color: AppColors.primary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 2, color: AppColors.error),
    ),
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: AppColors.secondary,
    suffixIconColor: AppColors.secondary,
    fillColor: AppColors.darkCard,
    filled: true,
    contentPadding: EdgeInsets.symmetric(
      horizontal: AppSizes.inputFieldRadius,
      vertical: AppSizes.fontSizeMd,
    ),
    labelStyle: const TextStyle().copyWith(
      fontSize: AppSizes.fontSizeMd,
      color: AppColors.darkMediumText,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: const TextStyle().copyWith(
      fontSize: AppSizes.fontSizeSm,
      color: AppColors.darkMediumText.withValues(alpha: 0.7),
    ),
    errorStyle: const TextStyle().copyWith(
      fontStyle: FontStyle.normal,
      color: AppColors.error,
      fontSize: AppSizes.fontSizeSm,
    ),
    floatingLabelStyle: const TextStyle().copyWith(
      color: AppColors.secondary,
      fontWeight: FontWeight.w600,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 0.5, color: AppColors.darkMediumText),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: AppColors.darkMediumText),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 2, color: AppColors.secondary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 2, color: AppColors.error),
    ),
  );
}

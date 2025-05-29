import 'package:hce_emv/theme/app_colors.dart';
import 'package:flutter/material.dart';

/* -- Light & Dark Outlined Button Themes -- */
class AppOutlinedButtonTheme {
  AppOutlinedButtonTheme._(); //To avoid creating instances

  /* -- Light Theme -- */
  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.darkMediumText, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.hovered)) {
          return AppColors.primary.withValues(alpha: 0.08);
        }
        if (states.contains(WidgetState.pressed)) {
          return AppColors.primary.withValues(alpha: 0.12);
        }
        return Colors.transparent;
      }),
    ),
  );

  /* -- Dark Theme -- */
  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      foregroundColor: AppColors.secondary,
      side: const BorderSide(color: AppColors.darkMediumText, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.hovered)) {
          return AppColors.secondary.withValues(alpha: 0.08);
        }
        if (states.contains(WidgetState.pressed)) {
          return AppColors.secondary.withValues(alpha: 0.12);
        }
        return Colors.transparent;
      }),
    ),
  );
}

import 'package:hce_emv/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppBottomSheetTheme {
  AppBottomSheetTheme._();

  static BottomSheetThemeData lightBottomSheetTheme = BottomSheetThemeData(
    showDragHandle: true,
    dragHandleColor: AppColors.primary.withValues(alpha: 0.5),
    backgroundColor: AppColors.lightCard,
    modalBackgroundColor: AppColors.lightCard,
    constraints: const BoxConstraints(minWidth: double.infinity),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 8,
    shadowColor: AppColors.lightMediumText.withValues(alpha: 0.1),
    clipBehavior: Clip.hardEdge,
  );

  static BottomSheetThemeData darkBottomSheetTheme = BottomSheetThemeData(
    showDragHandle: true,
    dragHandleColor: AppColors.secondary.withValues(alpha: 0.5),
    backgroundColor: AppColors.darkCard,
    modalBackgroundColor: AppColors.darkCard,
    constraints: const BoxConstraints(minWidth: double.infinity),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 8,
    shadowColor: Colors.black.withValues(alpha: 0.3),
    clipBehavior: Clip.hardEdge,
  );
}

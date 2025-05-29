// lib/common/widgets/card_container.dart (New Component)
import 'package:hce_emv/core/extensions/context_extensions.dart';
import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/theme/app_sizes.dart';
import 'package:flutter/material.dart';

class CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double elevation;
  final VoidCallback? onTap;
  final Color? color;
  final bool isInteractive;

  const CardContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.md),
    this.borderRadius = 16.0,
    this.elevation = 2.0,
    this.onTap,
    this.color,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: color ?? (isDark ? AppColors.darkCard : AppColors.lightCard),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: elevation * 4,
            offset: Offset(0, elevation),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor:
              isInteractive
                  ? (isDark
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.05))
                  : Colors.transparent,
          highlightColor:
              isInteractive
                  ? (isDark
                      ? AppColors.primary.withOpacity(0.05)
                      : AppColors.primary.withOpacity(0.03))
                  : Colors.transparent,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

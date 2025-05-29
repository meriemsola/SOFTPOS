import 'package:hce_emv/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? lightGradientColors;
  final List<Color>? darkGradientColors;

  const GradientBackground({
    super.key,
    required this.child,
    this.lightGradientColors,
    this.darkGradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final colors =
        isDark
            ? darkGradientColors ??
                [const Color(0xFF1A1F25), const Color(0xFF121418)]
            : lightGradientColors ??
                [const Color(0xFFE6F0FF), const Color(0xFFD1E3FF)];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: child,
    );
  }
}

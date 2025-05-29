import 'package:flutter/material.dart';

extension ThemeModeExtension on ThemeMode {
  bool get isDark => this == ThemeMode.dark;
}

import 'package:flutter/material.dart';

extension DarkModeExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
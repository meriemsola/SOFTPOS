// lib/features/profile/domain/models/app_settings.dart
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default('English') String language,
    @Default('Algeria') String region,
    @Default(true) bool pushNotifications,
    @Default(true) bool emailNotifications,
    @Default(false) bool smsNotifications,
    @Default(true) bool biometricAuth,
    @Default(false) bool twoFactorAuth,
    @Default(true) bool autoSync,
    @Default(false) bool wifiOnlyDownloads,
  }) = _AppSettings;
}

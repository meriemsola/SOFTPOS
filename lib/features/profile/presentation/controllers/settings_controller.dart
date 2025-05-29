// lib/features/profile/presentation/controllers/settings_controller.dart
import 'package:hce_emv/shared/models/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_controller.g.dart';

@riverpod
class SettingsController extends _$SettingsController {
  @override
  Future<AppSettings> build() async {
    // Load settings from storage
    final storage = ref.read(storageRepositoryProvider);

    // Get stored settings or use defaults
    final themeMode = await _getStoredThemeMode(storage);
    final language = await storage.getToken() ?? 'English'; // Placeholder
    final pushNotifications = true; // Default values
    final emailNotifications = true;
    final smsNotifications = false;

    return AppSettings(
      themeMode: themeMode,
      language: language,
      pushNotifications: pushNotifications,
      emailNotifications: emailNotifications,
      smsNotifications: smsNotifications,
    );
  }

  Future<ThemeMode> _getStoredThemeMode(storage) async {
    // For now, return system default. In a real app, you'd store this preference
    return ThemeMode.system;
  }

  Future<void> updateTheme(ThemeMode themeMode) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;

    state = AsyncValue.data(currentSettings.copyWith(themeMode: themeMode));

    // TODO: Store theme preference in storage
    // await ref.read(storageRepositoryProvider).storeThemeMode(themeMode);
  }

  Future<void> updateLanguage(String language) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;

    state = AsyncValue.data(currentSettings.copyWith(language: language));

    // TODO: Store language preference and update app locale
  }

  Future<void> updateRegion(String region) async {
    // TODO: Implement region update
  }

  Future<void> updateNotificationSettings({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
  }) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return;

    state = AsyncValue.data(
      currentSettings.copyWith(
        pushNotifications:
            pushNotifications ?? currentSettings.pushNotifications,
        emailNotifications:
            emailNotifications ?? currentSettings.emailNotifications,
        smsNotifications: smsNotifications ?? currentSettings.smsNotifications,
      ),
    );

    // TODO: Send notification preferences to backend
  }

  Future<void> clearCache() async {
    // TODO: Implement cache clearing logic
    await Future.delayed(const Duration(seconds: 1)); // Simulate work
  }

  Future<void> exportData() async {
    // TODO: Implement data export logic
    await Future.delayed(const Duration(seconds: 2)); // Simulate work
  }
}

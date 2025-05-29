// lib/features/profile/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hce_emv/core/extensions/context_extensions.dart';
import 'package:hce_emv/features/profile/presentation/controllers/settings_controller.dart';
import 'package:hce_emv/shared/presentation/widgets/gradient_background.dart';
import 'package:hce_emv/shared/presentation/widgets/card_container.dart';
import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/theme/app_sizes.dart';
import 'package:hce_emv/core/utils/helpers/toast_helper.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Appearance Section
                _buildSectionHeader('Appearance', context),
                const SizedBox(height: AppSizes.sm),
                _buildThemeSelector(context, ref),

                const SizedBox(height: AppSizes.lg),

                // Notifications Section
                _buildSectionHeader('Notifications', context),
                const SizedBox(height: AppSizes.sm),
                _buildNotificationSettings(context, ref, settingsAsync),

                const SizedBox(height: AppSizes.lg),

                // Privacy & Security Section
                _buildSectionHeader('Privacy & Security', context),
                const SizedBox(height: AppSizes.sm),
                _buildSecuritySettings(context, ref),

                const SizedBox(height: AppSizes.lg),

                // Language & Region Section
                _buildSectionHeader('Language & Region', context),
                const SizedBox(height: AppSizes.sm),
                _buildLanguageSettings(context, ref),

                const SizedBox(height: AppSizes.lg),

                // Data & Storage Section
                _buildSectionHeader('Data & Storage', context),
                const SizedBox(height: AppSizes.sm),
                _buildDataSettings(context, ref),

                const SizedBox(height: AppSizes.lg),

                // Support Section
                _buildSectionHeader('Support', context),
                const SizedBox(height: AppSizes.sm),
                _buildSupportSettings(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final currentTheme =
        settingsAsync.valueOrNull?.themeMode ?? ThemeMode.system;

    return CardContainer(
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.brightness_6_outlined,
            title: 'Theme',
            subtitle: _getThemeName(currentTheme),
            onTap: () => _showThemeSelector(context, ref, currentTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(
    BuildContext context,
    WidgetRef ref,
    AsyncValue settingsAsync,
  ) {
    final settings = settingsAsync.valueOrNull;

    return CardContainer(
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Receive notifications about rewards and updates',
            value: settings?.pushNotifications ?? true,
            onChanged:
                (value) => ref
                    .read(settingsControllerProvider.notifier)
                    .updateNotificationSettings(pushNotifications: value),
          ),
          const Divider(height: 1),
          _buildSwitchTile(
            icon: Icons.email_outlined,
            title: 'Email Notifications',
            subtitle: 'Receive email updates about your account',
            value: settings?.emailNotifications ?? true,
            onChanged:
                (value) => ref
                    .read(settingsControllerProvider.notifier)
                    .updateNotificationSettings(emailNotifications: value),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings(BuildContext context, WidgetRef ref) {
    return CardContainer(
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () => _navigateToChangePassword(context),
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.fingerprint,
            title: 'Biometric Authentication',
            subtitle: 'Use fingerprint or face ID to unlock',
            onTap: () => _showBiometricSettings(context, ref),
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.security_outlined,
            title: 'Two-Factor Authentication',
            subtitle: 'Add an extra layer of security',
            onTap: () => _navigateToTwoFactor(context),
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.devices_outlined,
            title: 'Manage Devices',
            subtitle: 'See where you\'re logged in',
            onTap: () => _navigateToDeviceManagement(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSettings(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final currentLanguage = settingsAsync.valueOrNull?.language ?? 'English';

    return CardContainer(
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: currentLanguage,
            onTap: () => _showLanguageSelector(context, ref),
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.public,
            title: 'Region',
            subtitle: 'Algeria',
            onTap: () => _showRegionSelector(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSettings(BuildContext context, WidgetRef ref) {
    return CardContainer(
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.cached,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            onTap: () => _showClearCacheDialog(context, ref),
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.download_outlined,
            title: 'Export Data',
            subtitle: 'Download a copy of your data',
            onTap: () => _showExportDataDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSettings(BuildContext context) {
    return CardContainer(
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.help_outline,
            title: 'Help Center',
            subtitle: 'Get help and support',
            onTap: () => _navigateToHelpCenter(context),
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.feedback_outlined,
            title: 'Send Feedback',
            subtitle: 'Help us improve the app',
            onTap: () => _showFeedbackDialog(context),
          ),
          const Divider(height: 1),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Version 1.0.0',
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
    );
  }

  String _getThemeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeSelector(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentTheme,
  ) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose Theme',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.lg),
                ...ThemeMode.values.map(
                  (theme) => RadioListTile<ThemeMode>(
                    title: Text(_getThemeName(theme)),
                    value: theme,
                    groupValue: currentTheme,
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(settingsControllerProvider.notifier)
                            .updateTheme(value);
                        context.pop();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    final languages = ['English', 'Arabic', 'French'];
    final settingsAsync = ref.watch(settingsControllerProvider);
    final currentLanguage = settingsAsync.valueOrNull?.language ?? 'English';

    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose Language',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.lg),
                ...languages.map(
                  (language) => RadioListTile<String>(
                    title: Text(language),
                    value: language,
                    groupValue: currentLanguage,
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(settingsControllerProvider.notifier)
                            .updateLanguage(value);
                        context.pop();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showRegionSelector(BuildContext context, WidgetRef ref) {
    final regions = ['Algeria', 'Morocco', 'Tunisia', 'Egypt'];

    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose Region',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.lg),
                ...regions.map(
                  (region) => ListTile(
                    title: Text(region),
                    onTap: () {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .updateRegion(region);
                      context.pop();
                      ToastHelper.showSuccess('Region updated to $region');
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showBiometricSettings(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Biometric Authentication'),
            content: const Text(
              'This feature will be available in a future update.',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showDataUsageSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Usage Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.lg),
                SwitchListTile(
                  title: const Text('Auto-sync data'),
                  subtitle: const Text('Automatically sync your data'),
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement auto-sync toggle
                    ToastHelper.showInfo(
                      'Auto-sync ${value ? 'enabled' : 'disabled'}',
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('Wi-Fi only downloads'),
                  subtitle: const Text('Download content only on Wi-Fi'),
                  value: false,
                  onChanged: (value) {
                    // TODO: Implement Wi-Fi only downloads
                    ToastHelper.showInfo(
                      'Wi-Fi only downloads ${value ? 'enabled' : 'disabled'}',
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showClearCacheDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Cache'),
            content: const Text(
              'This will clear all cached data and free up storage space. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.pop();
                  ref.read(settingsControllerProvider.notifier).clearCache();
                  ToastHelper.showSuccess('Cache cleared successfully');
                },
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }

  void _showExportDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Data'),
            content: const Text(
              'Your data will be exported and a download link will be sent to your email.',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.pop();
                  ref.read(settingsControllerProvider.notifier).exportData();
                  ToastHelper.showSuccess(
                    'Data export initiated. Check your email.',
                  );
                },
                child: const Text('Export'),
              ),
            ],
          ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Send Feedback'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Help us improve by sharing your feedback:'),
                const SizedBox(height: AppSizes.md),
                TextField(
                  controller: feedbackController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Enter your feedback here...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (feedbackController.text.trim().isNotEmpty) {
                    context.pop();
                    ToastHelper.showSuccess('Thank you for your feedback!');
                    // TODO: Send feedback to backend
                  } else {
                    ToastHelper.showError('Please enter your feedback');
                  }
                },
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Fideligo',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.loyalty, color: Colors.white, size: 32),
      ),
      children: [
        const Text(
          'A loyalty rewards application that helps you earn and redeem points.',
        ),
        const SizedBox(height: 16),
        const Text('© 2024 Fideligo. All rights reserved.'),
      ],
    );
  }

  void _navigateToChangePassword(BuildContext context) {
    context.push('/change-password');
  }

  void _navigateToTwoFactor(BuildContext context) {
    context.push('/two-factor-auth');
  }

  void _navigateToDeviceManagement(BuildContext context) {
    context.push('/device-management');
  }

  void _navigateToHelpCenter(BuildContext context) {
    context.push('/help-center');
  }
}

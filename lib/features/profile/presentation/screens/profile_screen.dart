import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hce_emv/core/extensions/context_extensions.dart';
import 'package:hce_emv/features/profile/domain/models/user.dart';
import 'package:hce_emv/features/authentication/presentation/controllers/signout_controller.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';
import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/theme/app_sizes.dart';
import 'package:go_router/go_router.dart';
import 'package:hce_emv/shared/presentation/widgets/skeletons.dart';
import 'package:hce_emv/shared/presentation/widgets/gradient_background.dart';
import 'package:hce_emv/shared/presentation/widgets/card_container.dart';
import 'package:hce_emv/shared/presentation/widgets/profile_shared_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDarkMode;
    AsyncValue<User?> userState = ref.watch(userProvider);
    final AsyncValue<void> signOutState = ref.watch(signOutControllerProvider);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.refresh(userProvider);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Profile',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // Profile header
                  Center(
                    child:
                        userState.isLoading
                            ? const SkeletonProfileHeader()
                            : Column(
                              children: [
                                // Profile avatar
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundColor: AppColors.primary
                                          .withValues(alpha: 0.2),
                                      child: Text(
                                        userState.when(
                                          data:
                                              (user) =>
                                                  user?.username.isNotEmpty ==
                                                          true
                                                      ? user!.username[0]
                                                          .toUpperCase()
                                                      : 'A',
                                          loading: () => 'A',
                                          error: (_, __) => 'A',
                                        ),
                                        style: TextStyle(
                                          fontSize: 32,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color:
                                                isDark
                                                    ? AppColors.darkCard
                                                    : AppColors.lightCard,
                                            width: 3,
                                          ),
                                        ),
                                        child: IconButton(
                                          onPressed:
                                              () => _navigateToEditProfile(
                                                context,
                                              ),
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 36,
                                            minHeight: 36,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.md),
                                // Username
                                Text(
                                  userState.when(
                                    data: (user) => user?.username ?? 'User',
                                    loading: () => 'Loading...',
                                    error: (_, __) => 'User',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Email
                                Text(
                                  userState.when(
                                    data:
                                        (user) =>
                                            user?.email ?? 'user@example.com',
                                    loading: () => 'Loading...',
                                    error: (_, __) => 'user@example.com',
                                  ),
                                  style: TextStyle(
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.md),
                              ],
                            ),
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Settings section
                  SectionHeader('Settings'),
                  const SizedBox(height: AppSizes.sm),
                  CardContainer(
                    child: Column(
                      children: [
                        SettingItemTile(
                          icon: Icons.edit_outlined,
                          title: 'Edit Profile',
                          onTap: () => _navigateToEditProfile(context),
                          subtitle: 'Edit your profile information',
                        ),
                        const Divider(height: 1),
                        SettingItemTile(
                          icon: Icons.settings_outlined,
                          title: 'App Settings',
                          subtitle: 'Notifications, theme, language',
                          onTap: () => _navigateToSettings(context),
                        ),
                        const Divider(height: 1),
                        SettingItemTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy & Security',
                          subtitle: 'Password, two-factor auth',
                          onTap: () => _navigateToChangePassword(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Support section
                  SectionHeader('Support'),
                  const SizedBox(height: AppSizes.sm),
                  CardContainer(
                    child: Column(
                      children: [
                        SettingItemTile(
                          icon: Icons.help_outline,
                          title: 'Help Center',
                          subtitle: 'FAQs and support articles',
                          onTap: () => _navigateToHelpCenter(context),
                        ),
                        const Divider(height: 1),
                        SettingItemTile(
                          icon: Icons.feedback_outlined,
                          title: 'Send Feedback',
                          subtitle: 'Help us improve the app',
                          onTap: () => _showFeedbackDialog(context),
                        ),
                        const Divider(height: 1),
                        SettingItemTile(
                          icon: Icons.contact_support_outlined,
                          title: 'Contact Support',
                          subtitle: 'Get help from our team',
                          onTap: () => _showContactSupportDialog(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Account Management
                  SectionHeader('Account'),
                  const SizedBox(height: AppSizes.sm),
                  CardContainer(
                    child: Column(
                      children: [
                        SettingItemTile(
                          icon: Icons.download_outlined,
                          title: 'Export Data',
                          subtitle: 'Download your account data',
                          onTap: () => _showExportDataDialog(context),
                        ),
                        const Divider(height: 1),
                        SettingItemTile(
                          icon: Icons.delete_forever_outlined,
                          title: 'Delete Account',
                          subtitle: 'Permanently delete your account',
                          onTap: () => _showDeleteAccountDialog(context, ref),
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Sign out button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed:
                          signOutState.isLoading
                              ? null
                              : () => _confirmSignOut(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.lg,
                          vertical: AppSizes.md,
                        ),
                      ),
                      icon:
                          signOutState.isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                    ),
                  ),

                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    context.push('/edit-profile');
  }

  void _navigateToSettings(BuildContext context) {
    context.push('/settings');
  }

  void _navigateToChangePassword(BuildContext context) {
    context.push('/change-password');
  }

  void _navigateToHelpCenter(BuildContext context) {
    context.push('/help-center');
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
                    // TODO: Send feedback to backend
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for your feedback!'),
                      ),
                    );
                  }
                },
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }

  void _showContactSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Contact Support'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Get in touch with our support team:'),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.email_outlined, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('support@HBTLitePay.com'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('+213 555 476 004'),
                  ],
                ),
                SizedBox(height: 16),
                Text('Available: Mon-Fri 9AM-6PM'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showExportDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Data'),
            content: const Text(
              'Your account data will be prepared and sent to your email address. This may take a few minutes.',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.pop();
                  // TODO: Implement data export
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data export initiated. Check your email.'),
                    ),
                  );
                },
                child: const Text('Export'),
              ),
            ],
          ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.pop();
                  _showFinalDeleteConfirmation(context, ref);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showFinalDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Final Confirmation'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Type "DELETE" to confirm account deletion:'),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmController,
                  decoration: const InputDecoration(
                    hintText: 'Type DELETE',
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
                  if (confirmController.text.trim() == 'DELETE') {
                    context.pop();
                    // TODO: Implement account deletion
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Account deletion initiated.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please type "DELETE" to confirm.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete Account'),
              ),
            ],
          ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => context.pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.pop(true);
                  ref.read(signOutControllerProvider.notifier).signOut();
                },
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}

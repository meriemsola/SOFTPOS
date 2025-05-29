// lib/features/profile/presentation/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hce_emv/core/extensions/context_extensions.dart';
import 'package:hce_emv/features/profile/domain/models/user.dart';
import 'package:hce_emv/features/profile/presentation/controllers/edit_profile_controller.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';
import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/theme/app_sizes.dart';
import 'package:hce_emv/core/utils/helpers/toast_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:hce_emv/shared/presentation/widgets/profile_shared_widgets.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final userAsync = ref.read(userProvider);
    userAsync.when(
      data: (user) {
        if (user != null) {
          _usernameController.text = user.username;
          _emailController.text = user.email;
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final userAsync = ref.watch(userProvider);
    final editProfileAsync = ref.watch(editProfileControllerProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:
              isDark
                  ? [const Color(0xFF1A1F25), const Color(0xFF121418)]
                  : [const Color(0xFFE6F0FF), const Color(0xFFD1E3FF)],
        ),
      ),
      child: PopScope(
        canPop: !_hasChanges,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && _hasChanges) {
            _showDiscardChangesDialog(context);
          }
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
          appBar: AppBar(
            title: const Text('Edit Profile'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SafeArea(
            child: userAsync.when(
              data:
                  (user) => _buildForm(
                    context,
                    user,
                    isDark,
                    editProfileAsync.isLoading,
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text('Error loading profile: $error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.refresh(userProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    User? user,
    bool isDark,
    bool isLoading,
  ) {
    if (user == null) {
      return const Center(child: Text('No user data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Avatar Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Text(
                      user.username.isNotEmpty
                          ? user.username[0].toUpperCase()
                          : 'A',
                      style: TextStyle(
                        fontSize: 40,
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
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isDark ? AppColors.darkCard : AppColors.lightCard,
                          width: 3,
                        ),
                      ),
                      child: IconButton(
                        onPressed: _showImagePicker,
                        icon: const Icon(
                          Icons.camera_alt,
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
            ),

            const SizedBox(height: AppSizes.xl),

            // Form Fields
            SectionHeader('Personal Information'),
            const SizedBox(height: AppSizes.md),

            _buildFormField(
              controller: _usernameController,
              label: 'Username',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Username is required';
                }
                if (value.trim().length < 3) {
                  return 'Username must be at least 3 characters';
                }
                return null;
              },
              onChanged: (_) => _onFieldChanged(),
            ),

            const SizedBox(height: AppSizes.md),

            _buildFormField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
              onChanged: (_) => _onFieldChanged(),
            ),

            const SizedBox(height: AppSizes.xl),

            // Account Information Section
            SectionHeader('Account Information'),
            const SizedBox(height: AppSizes.md),
            InfoCard(
              label: 'Auth Provider',
              value: user.authProvider.name,
              icon: Icons.security_outlined,
            ),

            const SizedBox(height: AppSizes.xl),

            // Loyalty Information Section
            SectionHeader('Loyalty Information'),
            const SizedBox(height: AppSizes.md),

            InfoCard(
              label: 'Loyalty Points',
              value: '${user.loyaltyPoints} pts',
              icon: Icons.stars_outlined,
            ),
            const SizedBox(height: AppSizes.sm),
            if (user.pointsExpirationDate != null)
              InfoCard(
                label: 'Points Expiration',
                value: _formatDate(user.pointsExpirationDate!),
                icon: Icons.schedule_outlined,
              ),

            const SizedBox(height: AppSizes.xl * 2),

            // Save Button at the bottom
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (!_hasChanges || isLoading)
                          ? null
                          : () => _saveProfile(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Save'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Change Profile Picture',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSizes.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        context.pop();
                        // TODO: Implement camera functionality
                        ToastHelper.showInfo(
                          'Camera functionality coming soon',
                        );
                      },
                    ),
                    _buildImageOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        context.pop();
                        // TODO: Implement gallery functionality
                        ToastHelper.showInfo(
                          'Gallery functionality coming soon',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(label),
          ],
        ),
      ),
    );
  }

  void _saveProfile(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();

    await ref
        .read(editProfileControllerProvider.notifier)
        .updateProfile(username: username, email: email);

    final state = ref.read(editProfileControllerProvider);
    if (state.hasError) {
      ToastHelper.showError(state.error.toString());
    } else {
      ToastHelper.showSuccess('Profile updated successfully');
      setState(() => _hasChanges = false);
      if (context.mounted) {
        context.pop();
      }
    }
  }

  void _showDiscardChangesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Discard Changes?'),
            content: const Text(
              'You have unsaved changes. Do you want to discard them?',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.pop(); // Close dialog
                  context.pop(); // Close screen
                },
                child: const Text(
                  'Discard',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

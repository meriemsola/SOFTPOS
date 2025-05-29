import 'package:hce_emv/core/extensions/context_extensions.dart';
import 'package:hce_emv/features/cards/presentation/controllers/create_card_controller.dart';
import 'package:hce_emv/features/cards/presentation/controllers/get_card_controller.dart';
import 'package:hce_emv/features/cards/presentation/widgets/loyalty_card_widget.dart';
import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hce_emv/core/utils/helpers/toast_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';
import 'package:hce_emv/shared/presentation/widgets/loyalty_status.dart';

class CardScreen extends ConsumerStatefulWidget {
  const CardScreen({super.key});

  @override
  ConsumerState<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends ConsumerState<CardScreen> {
  Future<void> _createNewCard() async {
    final cancelLoading = ToastHelper.showLoading(
      message: 'Creating your card...',
    );
    final result =
        await ref.read(createCardControllerProvider.notifier).createCard();
    cancelLoading();

    if (result) {
      ToastHelper.showSuccess('Card created successfully!');
      await ref.read(getCardControllerProvider.notifier).refresh();
    } else {
      final error = ref.read(createCardControllerProvider).error;
      ToastHelper.showError(error?.toString() ?? 'Failed to create card');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cardState = ref.watch(getCardControllerProvider);
    final hasCard = cardState.asData?.value != null;
    final userState = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF1A1F25) : const Color(0xFFE6F0FF),
        elevation: 0,
        title: const Text('My Card'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton:
          !hasCard
              ? FloatingActionButton.extended(
                onPressed: _createNewCard,
                icon: const Icon(Icons.add_card_rounded, color: Colors.white),
                label: const Text(
                  'Create Card',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: AppColors.primary,
              )
              : null,
      body: Container(
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
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(getCardControllerProvider.notifier).refresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    kToolbarHeight -
                    MediaQuery.of(context).padding.top,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Loyalty status section
                  userState.when(
                    data:
                        (user) =>
                            user == null
                                ? SizedBox.shrink()
                                : LoyaltyStatus(user: user),
                    loading: () => SizedBox.shrink(),
                    error: (_, __) => SizedBox.shrink(),
                  ),
                  // Card section with Hero
                  Center(
                    child: cardState.when(
                      data:
                          (card) => Hero(
                            tag: 'loyalty_card',
                            child: LoyaltyCardWidget(
                              card: card,
                              onTap: card == null ? _createNewCard : null,
                            ),
                          ),
                      loading:
                          () => const LoyaltyCardWidget(
                            card: null,
                            isLoading: true,
                          ),
                      error: (error, stackTrace) => _buildEmptyState(context),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  Divider(
                    color: isDark ? Colors.white12 : Colors.black12,
                    thickness: 1,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  // Card usage info
                  const Text(
                    'How to Use Your Card',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildInfoItem(
                    context,
                    icon: Icons.shopping_bag_outlined,
                    title: 'Show at Checkout',
                    description:
                        'Present your card when making purchases at partner stores.',
                    color: Colors.orange,
                  ),
                  _buildInfoItem(
                    context,
                    icon: Icons.qr_code_scanner,
                    title: 'Scan QR Code',
                    description:
                        'Let the cashier scan your card\'s QR code to earn points.',
                    color: Colors.green,
                  ),
                  _buildInfoItem(
                    context,
                    icon: Icons.smartphone,
                    title: 'Go Digital',
                    description:
                        'Use this app to scan partner QR codes and earn points instantly.',
                    color: Colors.blue,
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

  // Enhanced empty state with SVG illustration and CTA
  Widget _buildEmptyState(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 120,
            child: Image.asset(
              'assets/coffee.svg',
              package: null,
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) => const Icon(
                    Icons.credit_card_outlined,
                    size: 80,
                    color: Colors.white54,
                  ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            'No Card Found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Create a digital loyalty card to start earning points and rewards!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          ElevatedButton.icon(
            onPressed: _createNewCard,
            icon: const Icon(Icons.add_card_rounded),
            label: const Text('Create Card'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Improved info item with color and card
  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final isDark = context.isDarkMode;
    return Card(
      elevation: 3,
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.25 : 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:hce_emv/core/extensions/context_extensions.dart';
import 'package:hce_emv/core/routes/app_route.dart';
import 'package:hce_emv/features/cards/presentation/controllers/get_card_controller.dart';
import 'package:hce_emv/features/cards/presentation/widgets/loyalty_card_widget.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';
import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hce_emv/features/profile/domain/models/user.dart';
import 'package:hce_emv/shared/presentation/widgets/skeletons.dart';
import 'package:hce_emv/shared/presentation/widgets/loyalty_status.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<User?> userState = ref.watch(userProvider);
    final isDark = context.isDarkMode;
    final cardState = ref.watch(getCardControllerProvider);

    return Scaffold(
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
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(getCardControllerProvider.notifier).refresh();
              ref.invalidate(userProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User greeting
                    _buildGreetingSection(userState),
                    const SizedBox(height: AppSizes.lg),

                    // Loyalty card section
                    _buildLoyaltyCardSection(cardState, userState, context),
                    const SizedBox(height: AppSizes.xl),

                    // Quick actions
                    // _buildQuickActionsSection(context),
                    // const SizedBox(height: AppSizes.xl),

                    // Welcome message or tips
                    _buildWelcomeSection(context, userState),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(AsyncValue<User?> userState) {
    final timeOfDay = DateTime.now().hour;
    String greeting;

    if (timeOfDay < 12) {
      greeting = 'Good Morning';
    } else if (timeOfDay < 18) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                userState.when(
                  data:
                      (user) => Text(
                        user?.username ?? 'User',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  loading:
                      () => const Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  error:
                      (error, stackTrace) => Text(
                        'Welcome',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color:
                              context.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                        ),
                      ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        // Loyalty summary row (using shared widget)
        userState.when(
          data:
              (user) =>
                  user == null
                      ? const SizedBox.shrink()
                      : LoyaltyStatus(user: user),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildLoyaltyCardSection(
    AsyncValue<dynamic> cardState,
    AsyncValue<User?> userState,
    BuildContext context,
  ) {
    return cardState.when(
      data:
          (card) => Hero(
            tag: 'loyalty_card',
            child: LoyaltyCardWidget(
              card: card,
              onTap: () => context.push(AppRoutes.card.path),
            ),
          ),
      loading: () => const SkeletonLoyaltyCard(),
      error:
          (error, stackTrace) => Hero(
            tag: 'loyalty_card',
            child: LoyaltyCardWidget(
              card: null,
              showEmptyState: true,
              onTap: () => context.push(AppRoutes.card.path),
            ),
          ),
    );
  }

  // Widget _buildQuickActionsSection(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Quick Actions',
  //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //       ),
  //       const SizedBox(height: AppSizes.md),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: [
  //           _buildQuickActionItem(
  //             context,
  //             icon: Icons.card_giftcard,
  //             title: 'Rewards',
  //             color: AppColors.primary,
  //             onTap: () => context.go(AppRoutes.rewards.path),
  //           ),
  //           _buildQuickActionItem(
  //             context,
  //             icon: Icons.shopping_bag_outlined,
  //             title: 'Shop',
  //             color: Colors.orange,
  //             onTap: () => context.push(AppRoutes.articles.path),
  //           ),
  //           _buildQuickActionItem(
  //             context,
  //             icon: Icons.credit_card,
  //             title: 'My Card',
  //             color: Colors.purple,
  //             onTap: () => context.push(AppRoutes.card.path),
  //           ),
  //           _buildQuickActionItem(
  //             context,
  //             icon: Icons.history,
  //             title: 'History',
  //             color: Colors.teal,
  //             onTap: () => context.go(AppRoutes.transactions.path),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildQuickActionItem(
  //   BuildContext context, {
  //   required IconData icon,
  //   required String title,
  //   required Color color,
  //   required VoidCallback onTap,
  // }) {
  //   final isDark = context.isDarkMode;

  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       width: 80,
  //       padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
  //       child: Column(
  //         children: [
  //           Container(
  //             width: 56,
  //             height: 56,
  //             decoration: BoxDecoration(
  //               color: isDark ? color.withAlpha(51) : color.withAlpha(26),
  //               borderRadius: BorderRadius.circular(16),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: color.withAlpha(26),
  //                   blurRadius: 8,
  //                   offset: const Offset(0, 2),
  //                 ),
  //               ],
  //             ),
  //             child: Icon(icon, color: color, size: 28),
  //           ),
  //           const SizedBox(height: 12),
  //           Text(
  //             title,
  //             style: TextStyle(
  //               fontSize: 13,
  //               fontWeight: FontWeight.w600,
  //               color: isDark ? Colors.white : Colors.black87,
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildWelcomeSection(
    BuildContext context,
    AsyncValue<User?> userState,
  ) {
    final isDark = context.isDarkMode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              const Expanded(
                child: Text(
                  'Getting Started',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'Welcome to Fideligo! Here are some ways to earn more points:',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          _buildTipItem(
            context,
            icon: Icons.shopping_cart_outlined,
            title: 'Shop Articles',
            description: 'Browse and purchase items to earn points',
            onTap: () => context.go(AppRoutes.articles.path),
          ),
          const SizedBox(height: AppSizes.sm),
          _buildTipItem(
            context,
            icon: Icons.card_giftcard,
            title: 'Redeem Rewards',
            description: 'Use your points to get amazing rewards',
            onTap: () => context.go(AppRoutes.rewards.path),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:hce_emv/core/extensions/context_extensions.dart';
import 'package:hce_emv/core/utils/helpers/toast_helper.dart';
import 'package:hce_emv/features/profile/domain/models/user.dart';
import 'package:hce_emv/features/rewards/domain/models/reward.dart';
import 'package:hce_emv/features/rewards/presentation/controllers/redeem_reward_controller.dart';
import 'package:hce_emv/features/rewards/presentation/controllers/rewards_controller.dart';
import 'package:hce_emv/features/rewards/presentation/controllers/user_rewards_controller.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';
import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hce_emv/shared/presentation/widgets/skeletons.dart';
import 'package:flutter/services.dart';

final selectedCategoryProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
final viewTypeProvider = StateProvider<bool>((ref) => true);
final categoriesProvider = Provider<List<String>>((ref) {
  final rewardsAsync = ref.watch(rewardsControllerProvider);
  return rewardsAsync.maybeWhen(
    data: (rewards) {
      final categories =
          rewards?.map((reward) => reward.category).toSet().toList() ?? [];
      categories.sort();
      return categories;
    },
    orElse: () => [],
  );
});

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late AnimationController _fabAnimationController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isScrolled = false;
  // bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _searchController.addListener(() {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });

    _scrollController.addListener(_onScroll);
    _headerAnimationController.forward();
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 50;
    if (_isScrolled != isScrolled) {
      setState(() => _isScrolled = isScrolled);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    _fabAnimationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _redeemReward(BuildContext context, Reward reward, User? user) async {
    if (user == null) {
      HapticFeedback.mediumImpact();
      ToastHelper.showError("User not found. Please log in.");
      return;
    }

    if (user.loyaltyPoints < reward.pointsRequired) {
      HapticFeedback.mediumImpact();
      _showInsufficientPointsDialog(context, reward, user.loyaltyPoints);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => EnhancedRedemptionDialog(reward: reward, user: user),
    );

    if (confirmed ?? false) {
      final cancelLoading = ToastHelper.showLoading();

      try {
        final success = await ref
            .read(redeemRewardControllerProvider.notifier)
            .redeemReward(reward.id.toString(), reward.pointsRequired);

        cancelLoading();

        if (success) {
          HapticFeedback.heavyImpact();
          ToastHelper.showSuccess('🎉 Reward redeemed successfully!');

          await ref.read(rewardsControllerProvider.notifier).refresh();
          await ref.read(userRewardsControllerProvider.notifier).refresh();

          if (!context.mounted) return;
          _showRedemptionSuccessDialog(context, reward);
        } else {
          HapticFeedback.mediumImpact();
          final error = ref.read(redeemRewardControllerProvider).error;
          ToastHelper.showFriendlyError(
            error ?? 'Unknown error',
            fallbackMessage: 'Failed to redeem reward',
          );
        }
      } catch (error) {
        cancelLoading();
        HapticFeedback.mediumImpact();
        ToastHelper.showFriendlyError(
          error,
          fallbackMessage: 'Failed to redeem reward',
        );
      }
    }
  }

  void _showInsufficientPointsDialog(
    BuildContext context,
    Reward reward,
    int userPoints,
  ) {
    final pointsNeeded = reward.pointsRequired - userPoints;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: AppColors.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Flexible(child: Text('Not Enough Points')),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Required:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${reward.pointsRequired} pts',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your points:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '$userPoints pts',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Need:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '$pointsNeeded more pts',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '💡 Ways to earn more points:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildEarnPointsTip(
                  Icons.shopping_bag,
                  'Make purchases at partner stores',
                ),
                _buildEarnPointsTip(
                  Icons.quiz,
                  'Complete surveys and challenges',
                ),
                _buildEarnPointsTip(Icons.people, 'Refer friends to the app'),
                _buildEarnPointsTip(
                  Icons.event,
                  'Participate in special events',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Maybe Later'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  context.pop();
                  // Navigate to earn points section
                },
                icon: const Icon(Icons.trending_up),
                label: const Text('Earn Points'),
              ),
            ],
          ),
    );
  }

  Widget _buildEarnPointsTip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _showRedemptionSuccessDialog(BuildContext context, Reward reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => SuccessRedemptionDialog(
            reward: reward,
            onViewRewards: () {
              Navigator.of(context).pop();
              _tabController.animateTo(1);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final AsyncValue<User?> userState = ref.watch(userProvider);
    final rewardsState = ref.watch(rewardsControllerProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [
                      const Color(0xFF1A1F25),
                      const Color(0xFF121418),
                      const Color(0xFF0A0E12),
                    ]
                    : [
                      const Color(0xFFE6F0FF),
                      const Color(0xFFD1E3FF),
                      const Color(0xFFBDD4FF),
                    ],
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(userState, isDark),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  children: [
                    // Enhanced Tabs
                    _buildEnhancedTabs(isDark),
                  ],
                ),
              ),
            ),
            // Tab content
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBrowseRewardsTab(rewardsState),
                  _buildMyRewardsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isScrolled ? 1.0 : 0.0,
            child: FloatingActionButton.extended(
              onPressed: () async {
                await ref.read(rewardsControllerProvider.notifier).refresh();
                await ref
                    .read(userRewardsControllerProvider.notifier)
                    .refresh();
                HapticFeedback.lightImpact();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(AsyncValue<User?> userState, bool isDark) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                (isDark ? Colors.black : Colors.white).withValues(alpha: 0.1),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      // Animated title
                      AnimatedBuilder(
                        animation: _headerAnimationController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-0.5, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _headerAnimationController,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                            child: FadeTransition(
                              opacity: _headerAnimationController,
                              child: Text(
                                'Rewards',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      _buildPointsDisplay(userState, isDark),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildEnhancedSearchBar(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPointsDisplay(AsyncValue<User?> userState, bool isDark) {
    return AnimatedBuilder(
      animation: _headerAnimationController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.5, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _headerAnimationController,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: FadeTransition(
            opacity: _headerAnimationController,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Points',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        userState.when(
                          data: (user) => user?.loyaltyPoints.toString() ?? '0',
                          loading: () => '...',
                          error: (_, __) => '0',
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedSearchBar(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 50,
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            autofocus: false,
            decoration: InputDecoration(
              hintText: 'Search rewards, categories...',
              prefixIcon: Icon(Icons.search, color: AppColors.primary),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTabs(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(0),
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.explore, size: 18),
                SizedBox(width: 8),
                Text('Browse'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.card_giftcard, size: 18),
                SizedBox(width: 8),
                Text('My Rewards'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseRewardsTab(AsyncValue<List<Reward>?> rewardsState) {
    final viewType = ref.watch(viewTypeProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final categories = ref.watch(categoriesProvider);

    return Column(
      children: [
        // Enhanced filters
        _buildEnhancedFilters(categories, viewType),
        const SizedBox(height: AppSizes.sm),

        // Rewards list
        Expanded(
          child: _buildRewardsList(
            rewardsState,
            viewType,
            selectedCategory,
            searchQuery,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedFilters(List<String> categories, bool viewType) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildEnhancedCategoryChip(null, 'All', Icons.apps),
                  ...categories.map(
                    (category) => _buildEnhancedCategoryChip(
                      category,
                      category,
                      _getCategoryIcon(category),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color:
                  context.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  viewType ? Icons.view_list : Icons.grid_view,
                  key: ValueKey(viewType),
                  color: AppColors.primary,
                ),
              ),
              onPressed: () {
                ref.read(viewTypeProvider.notifier).state = !viewType;
                HapticFeedback.lightImpact();
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'travel':
        return Icons.flight;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.health_and_safety;
      default:
        return Icons.card_giftcard;
    }
  }

  Widget _buildEnhancedCategoryChip(
    String? category,
    String label,
    IconData icon,
  ) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final isSelected = selectedCategory == category;
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 6),
              Text(label),
            ],
          ),
          selected: isSelected,
          onSelected: (value) {
            ref.read(selectedCategoryProvider.notifier).state =
                value ? category : null;
            HapticFeedback.lightImpact();
          },
          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          selectedColor: AppColors.primary.withValues(alpha: 0.2),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
          elevation: isSelected ? 4 : 0,
          pressElevation: 2,
        ),
      ),
    );
  }

  Widget _buildRewardsList(
    AsyncValue<List<Reward>?> rewardsState,
    bool isGrid,
    String? categoryFilter,
    String searchQuery,
  ) {
    return rewardsState.when(
      data: (rewards) {
        final filteredRewards =
            rewards?.where((reward) {
              final matchesCategory =
                  categoryFilter == null || reward.category == categoryFilter;
              final matchesSearch =
                  searchQuery.isEmpty ||
                  reward.name.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  reward.description.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  );
              return matchesCategory && matchesSearch;
            }).toList() ??
            [];

        if (filteredRewards.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh:
              () => ref.read(rewardsControllerProvider.notifier).refresh(),
          child:
              isGrid
                  ? _buildGridView(filteredRewards)
                  : _buildListView(filteredRewards),
        );
      },
      loading: () => _buildLoadingState(isGrid),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No rewards found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: context.isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              color: context.isDarkMode ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isGrid) {
    return isGrid
        ? GridView.builder(
          padding: const EdgeInsets.all(AppSizes.md),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: AppSizes.md,
            mainAxisSpacing: AppSizes.md,
          ),
          itemCount: 6,
          itemBuilder: (context, index) => const SkeletonRewardCard(),
        )
        : ListView.builder(
          padding: const EdgeInsets.all(AppSizes.md),
          itemCount: 6,
          itemBuilder:
              (context, index) => const Padding(
                padding: EdgeInsets.only(bottom: AppSizes.sm),
                child: SkeletonRewardListItem(),
              ),
        );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.error_outline, size: 64, color: AppColors.error),
          ),
          const SizedBox(height: 20),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: context.isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(
              color: context.isDarkMode ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed:
                () => ref.read(rewardsControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Reward> rewards) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: AppSizes.md,
        mainAxisSpacing: AppSizes.md,
      ),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 50)),
          curve: Curves.easeOutCubic,
          child: EnhancedRewardGridCard(
            reward: rewards[index],
            onTap:
                () => _redeemReward(
                  context,
                  rewards[index],
                  ref.read(userProvider).value,
                ),
          ),
        );
      },
    );
  }

  Widget _buildListView(List<Reward> rewards) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 50)),
          curve: Curves.easeOutCubic,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: EnhancedRewardListCard(
              reward: rewards[index],
              onTap:
                  () => _redeemReward(
                    context,
                    rewards[index],
                    ref.read(userProvider).value,
                  ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyRewardsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final userRewardsAsync = ref.watch(userRewardsControllerProvider);

        return userRewardsAsync.when(
          data: (rewards) {
            if (rewards.isEmpty) {
              return _buildMyRewardsEmptyState();
            }

            // Group rewards by category
            final groupedRewards = <String, List<Reward>>{};
            for (final reward in rewards) {
              if (groupedRewards.containsKey(reward.category)) {
                groupedRewards[reward.category]!.add(reward);
              } else {
                groupedRewards[reward.category] = [reward];
              }
            }

            final categories = groupedRewards.keys.toList()..sort();

            return RefreshIndicator(
              onRefresh:
                  () =>
                      ref
                          .read(userRewardsControllerProvider.notifier)
                          .refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSizes.md),
                itemCount: categories.length,
                itemBuilder: (context, categoryIndex) {
                  final category = categories[categoryIndex];
                  final categoryRewards = groupedRewards[category]!;

                  return AnimatedContainer(
                    duration: Duration(
                      milliseconds: 200 + (categoryIndex * 100),
                    ),
                    curve: Curves.easeOutCubic,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (categoryIndex > 0)
                          const SizedBox(height: AppSizes.lg),
                        _buildCategoryHeader(category, categoryRewards.length),
                        const SizedBox(height: AppSizes.sm),
                        ...categoryRewards.map(
                          (reward) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSizes.sm),
                            child: EnhancedRewardListCard(
                              reward: reward,
                              isRedeemed: true,
                              onTap: () => _showRewardDetails(context, reward),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
          loading: () => _buildLoadingState(false),
          error: (error, stack) => _buildErrorState(error),
        );
      },
    );
  }

  Widget _buildMyRewardsEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.card_giftcard_outlined,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No rewards yet! 🎁',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Browse rewards and start earning\nsome amazing prizes!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: context.isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _tabController.animateTo(0),
            icon: const Icon(Icons.explore),
            label: const Text('Browse Rewards'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String category, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getCategoryIcon(category), color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            category,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRewardDetails(BuildContext context, Reward reward) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => EnhancedRewardDetailsSheet(reward: reward),
    );
  }
}

// Enhanced Reward Grid Card
class EnhancedRewardGridCard extends StatefulWidget {
  final Reward reward;
  final VoidCallback onTap;

  const EnhancedRewardGridCard({
    super.key,
    required this.reward,
    required this.onTap,
  });

  @override
  State<EnhancedRewardGridCard> createState() => _EnhancedRewardGridCardState();
}

class _EnhancedRewardGridCardState extends State<EnhancedRewardGridCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDark
                          ? [
                            AppColors.darkCard,
                            AppColors.darkCard.withValues(alpha: 0.8),
                          ]
                          : [
                            AppColors.lightCard,
                            AppColors.lightCard.withValues(alpha: 0.9),
                          ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:
                        _isPressed
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.1),
                    blurRadius: _isPressed ? 15 : 8,
                    offset: Offset(0, _isPressed ? 8 : 4),
                  ),
                ],
                border: Border.all(
                  color:
                      _isPressed
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section with gradient overlay
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.1),
                            AppColors.primary.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              _getCategoryIcon(widget.reward.category),
                              size: 48,
                              color: AppColors.primary.withValues(alpha: 0.7),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                widget.reward.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Content section
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.reward.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              widget.reward.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.1),
                                  AppColors.primary.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.stars_rounded,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.reward.pointsRequired}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'travel':
        return Icons.flight;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.health_and_safety;
      default:
        return Icons.card_giftcard;
    }
  }
}

// Enhanced Reward List Card
class EnhancedRewardListCard extends StatefulWidget {
  final Reward reward;
  final VoidCallback onTap;
  final bool isRedeemed;

  const EnhancedRewardListCard({
    super.key,
    required this.reward,
    required this.onTap,
    this.isRedeemed = false,
  });

  @override
  State<EnhancedRewardListCard> createState() => _EnhancedRewardListCardState();
}

class _EnhancedRewardListCardState extends State<EnhancedRewardListCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors:
                      isDark
                          ? [
                            AppColors.darkCard,
                            AppColors.darkCard.withValues(alpha: 0.8),
                          ]
                          : [
                            AppColors.lightCard,
                            AppColors.lightCard.withValues(alpha: 0.9),
                          ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        _isPressed
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.05),
                    blurRadius: _isPressed ? 12 : 6,
                    offset: Offset(0, _isPressed ? 6 : 3),
                  ),
                ],
                border: Border.all(
                  color:
                      _isPressed
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Icon section
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.2),
                          AppColors.primary.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            _getCategoryIcon(widget.reward.category),
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        if (widget.isRedeemed)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Content section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.reward.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.reward.category,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.reward.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.stars_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.reward.pointsRequired} points',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                            ),
                            if (widget.isRedeemed) ...[
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 14,
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Redeemed',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'travel':
        return Icons.flight;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.health_and_safety;
      default:
        return Icons.card_giftcard;
    }
  }
}

// Enhanced Redemption Dialog
class EnhancedRedemptionDialog extends StatefulWidget {
  final Reward reward;
  final User user;

  const EnhancedRedemptionDialog({
    super.key,
    required this.reward,
    required this.user,
  });

  @override
  State<EnhancedRedemptionDialog> createState() =>
      _EnhancedRedemptionDialogState();
}

class _EnhancedRedemptionDialogState extends State<EnhancedRedemptionDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remainingPoints =
        widget.user.loyaltyPoints - widget.reward.pointsRequired;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Flexible(
                child: Text(
                  'Confirm Redemption',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Reward preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getCategoryIcon(widget.reward.category),
                      color: AppColors.primary,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.reward.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.reward.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Points breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? AppColors.darkBackground.withValues(alpha: 0.5)
                          : AppColors.lightBackground.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildPointRow(
                      'Cost:',
                      '${widget.reward.pointsRequired} pts',
                      AppColors.error,
                    ),
                    const SizedBox(height: 8),
                    _buildPointRow(
                      'Your points:',
                      '${widget.user.loyaltyPoints} pts',
                      null,
                    ),
                    const Divider(height: 20),
                    _buildPointRow(
                      'Remaining:',
                      '$remainingPoints pts',
                      remainingPoints >= 0
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Terms notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.alert.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.alert.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.alert, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Redemption is final and cannot be undone.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.alert,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () => context.pop(true),
              icon: const Icon(Icons.redeem),
              label: const Text('Redeem Now'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointRow(String label, String value, Color? valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'travel':
        return Icons.flight;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.health_and_safety;
      default:
        return Icons.card_giftcard;
    }
  }
}

// Success Dialog
class SuccessRedemptionDialog extends StatefulWidget {
  final Reward reward;
  final VoidCallback onViewRewards;

  const SuccessRedemptionDialog({
    super.key,
    required this.reward,
    required this.onViewRewards,
  });

  @override
  State<SuccessRedemptionDialog> createState() =>
      _SuccessRedemptionDialogState();
}

class _SuccessRedemptionDialogState extends State<SuccessRedemptionDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
    _confettiController.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Animated success icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.success,
                          AppColors.success.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.celebration,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  // Confetti animation placeholder
                  AnimatedBuilder(
                    animation: _confettiController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _confettiController.value * 6.28,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '🎉 Success!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Your reward has been redeemed',
                style: TextStyle(
                  fontSize: 16,
                  color: context.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.1),
                  AppColors.success.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.card_giftcard, color: AppColors.success, size: 32),
                const SizedBox(height: 12),
                Text(
                  widget.reward.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Check "My Rewards" tab for redemption details',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: widget.onViewRewards,
              icon: const Icon(Icons.card_giftcard),
              label: const Text('View My Rewards'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Reward Details Sheet
class EnhancedRewardDetailsSheet extends StatelessWidget {
  final Reward reward;

  const EnhancedRewardDetailsSheet({super.key, required this.reward});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getCategoryIcon(reward.category),
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reward.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Details
          _buildDetailItem('Description', reward.description),
          _buildDetailItem('Points Required', '${reward.pointsRequired}'),
          _buildDetailItem('Reward ID', reward.id.toString()),
          _buildDetailItem(
            'Status',
            reward.available ? 'Available' : 'Unavailable',
          ),

          const SizedBox(height: 24),

          // Terms
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? AppColors.darkBackground.withValues(alpha: 0.5)
                      : AppColors.lightBackground.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• This reward has been successfully redeemed\n'
                  '• Please keep this information for your records\n'
                  '• Contact support for any redemption issues',
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
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'travel':
        return Icons.flight;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.health_and_safety;
      default:
        return Icons.card_giftcard;
    }
  }
}

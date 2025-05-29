// lib/features/articles/presentation/screens/articles_screen.dart
import 'dart:ui';
import 'package:hce_emv/core/extensions/context_extensions.dart';
import 'package:hce_emv/features/articles/domain/models/article.dart';
import 'package:hce_emv/features/articles/presentation/controllers/articles_controller.dart';
import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hce_emv/shared/presentation/widgets/skeletons.dart';
import 'package:hce_emv/features/articles/presentation/controllers/cart_controller.dart';
import 'package:hce_emv/features/articles/presentation/widgets/article_details_modal.dart';
import 'package:hce_emv/features/articles/presentation/widgets/cart_drawer_widget.dart';
import 'package:hce_emv/core/utils/helpers/currency_helper.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';
import 'package:hce_emv/shared/presentation/widgets/animated_list_item.dart';

class ArticlesScreen extends ConsumerStatefulWidget {
  const ArticlesScreen({super.key});

  @override
  ConsumerState<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends ConsumerState<ArticlesScreen>
    with TickerProviderStateMixin {
  late AnimationController _searchController;
  late AnimationController _fabController;
  late Animation<double> _searchAnimation;
  // late Animation<double> _fabAnimation;

  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;

  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _gridScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _searchAnimation = CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeInOut,
    );
    // _fabAnimation = CurvedAnimation(
    //   parent: _fabController,
    //   curve: Curves.easeInOut,
    // );

    _gridScrollController.addListener(_onScroll);
    _fabController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabController.dispose();
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    _categoryScrollController.dispose();
    _gridScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_gridScrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_fabController.isCompleted) _fabController.reverse();
    } else {
      if (_fabController.isDismissed) _fabController.forward();
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });

    if (_isSearchExpanded) {
      _searchController.forward();
      _searchFocusNode.requestFocus();
    } else {
      _searchController.reverse();
      _searchFocusNode.unfocus();
      _searchTextController.clear();
      _searchQuery = '';
    }
  }

  List<Article> _filterArticles(
    List<Article> articles,
    List<String> categories,
  ) {
    var filtered = articles;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (article) => article.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();
    }

    if (_selectedCategoryIndex > 0 &&
        categories.length > _selectedCategoryIndex) {
      final selectedCategory = categories[_selectedCategoryIndex];
      filtered =
          filtered
              .where((a) => (a.category ?? 'Other') == selectedCategory)
              .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final articlesAsync = ref.watch(articlesControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAnimatedAppBar(context, isDark),
      endDrawer: const CartDrawerWidget(),
      // floatingActionButton: _buildFloatingActionButton(context, isDark),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDark
                    ? [
                      const Color(0xFF1A1F25),
                      const Color(0xFF121418),
                      const Color(0xFF0A0C0F),
                    ]
                    : [
                      const Color(0xFFE6F0FF),
                      const Color(0xFFD1E3FF),
                      const Color(0xFFBDD7FF),
                    ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh:
                () => ref.read(articlesControllerProvider.notifier).refresh(),
            color: AppColors.primary,
            backgroundColor: isDark ? AppColors.darkCard : Colors.white,
            child: CustomScrollView(
              controller: _gridScrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top spacing
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Categories
                articlesAsync.when(
                  data: (articles) {
                    final Set<String> categorySet =
                        articles
                            .map((a) => a.category ?? 'Other')
                            .where((c) => c.isNotEmpty)
                            .toSet();
                    final List<String> categories = ['All', ...categorySet];
                    return _buildCategoriesSection(isDark, categories);
                  },
                  loading: () => _buildCategoriesSection(isDark, const ['All']),
                  error:
                      (_, __) => _buildCategoriesSection(isDark, const ['All']),
                ),

                // Articles Grid
                articlesAsync.when(
                  data: (articles) {
                    final Set<String> categorySet =
                        articles
                            .map((a) => a.category ?? 'Other')
                            .where((c) => c.isNotEmpty)
                            .toSet();
                    final List<String> categories = ['All', ...categorySet];
                    return _buildArticlesGrid(
                      _filterArticles(articles, categories),
                      isDark,
                    );
                  },
                  loading: () => _buildLoadingGrid(),
                  error: (error, stack) => _buildErrorSection(error),
                ),

                // Bottom spacing for FAB
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAnimatedAppBar(BuildContext context, bool isDark) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AnimatedBuilder(
        animation: _searchAnimation,
        builder: (context, child) {
          return AppBar(
            backgroundColor:
                isDark ? const Color(0xFF1A1F25) : const Color(0xFFE6F0FF),
            elevation: 0,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          isDark
                              ? [
                                const Color(0xFF1A1F25).withValues(alpha: 0.8),
                                const Color(0xFF2A2F35).withValues(alpha: 0.8),
                              ]
                              : [
                                const Color(0xFFE6F0FF).withValues(alpha: 0.8),
                                const Color(0xFFD1E3FF).withValues(alpha: 0.8),
                              ],
                    ),
                  ),
                ),
              ),
            ),
            title: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  _isSearchExpanded ? _buildSearchField(isDark) : _buildTitle(),
            ),
            actions: [
              _buildCartButton(),
              _buildSearchButton(),
              _buildRefreshButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Shop Articles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField(bool isDark) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchTextController,
        focusNode: _searchFocusNode,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search articles...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _searchTextController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildCartButton() {
    return Consumer(
      builder: (context, ref, _) {
        final cart = ref.watch(cartControllerProvider);
        final itemCount = cart.when(
          data:
              (value) =>
                  value.items.fold<int>(0, (sum, item) => sum + item.quantity),
          loading: () => 0,
          error: (e, s) => 0,
        );

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          child: Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  color: itemCount > 0 ? AppColors.primary : null,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Scaffold.of(context).openEndDrawer();
                },
              ),
              if (itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: AnimatedScale(
                    scale: itemCount > 0 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$itemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchButton() {
    return IconButton(
      icon: AnimatedRotation(
        turns: _isSearchExpanded ? 0.125 : 0,
        duration: const Duration(milliseconds: 300),
        child: Icon(_isSearchExpanded ? Icons.close : Icons.search),
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        _toggleSearch();
      },
    );
  }

  Widget _buildRefreshButton() {
    return IconButton(
      icon: const Icon(Icons.refresh_rounded),
      onPressed: () {
        HapticFeedback.mediumImpact();
        ref.read(articlesControllerProvider.notifier).refresh();
      },
    );
  }

  Widget _buildCategoriesSection(bool isDark, List<String> categories) {
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(bottom: 20),
        child: ListView.builder(
          controller: _categoryScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final isSelected = index == _selectedCategoryIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedCategoryIndex = index);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient:
                        isSelected
                            ? const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            )
                            : null,
                    color:
                        isSelected
                            ? null
                            : isDark
                            ? AppColors.darkCard.withOpacity(0.6)
                            : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color:
                          isSelected
                              ? Colors.transparent
                              : AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : [],
                  ),
                  child: Center(
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        color:
                            isSelected
                                ? Colors.white
                                : isDark
                                ? Colors.white70
                                : AppColors.primary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget _buildFloatingActionButton(BuildContext context, bool isDark) {
  //   return ScaleTransition(
  //     scale: _fabAnimation,
  //     child: FloatingActionButton.extended(
  //       onPressed: () {
  //         HapticFeedback.mediumImpact();
  //         // Navigate to add article or special offers
  //         _showSpecialOffersModal(context);
  //       },
  //       backgroundColor: AppColors.primary,
  //       foregroundColor: Colors.white,
  //       elevation: 6,
  //       icon: const Icon(Icons.local_offer_outlined),
  //       label: const Text(
  //         'Special Offers',
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildArticlesGrid(List<Article> articles, bool isDark) {
    if (articles.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _searchQuery.isNotEmpty
                    ? Icons.search_off
                    : Icons.shopping_bag_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No articles found for "$_searchQuery"'
                    : 'No articles available',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    _searchTextController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Text('Clear search'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: AppSizes.md,
          mainAxisSpacing: AppSizes.md,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          return AnimatedListItem(
            index: index,
            delay: const Duration(milliseconds: 100),
            child: EnhancedArticleCard(article: articles[index]),
          );
        }, childCount: articles.length),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: AppSizes.md,
          mainAxisSpacing: AppSizes.md,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const SkeletonArticleCard(),
          childCount: 6,
        ),
      ),
    );
  }

  Widget _buildErrorSection(Object error) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load articles',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed:
                  () => ref.read(articlesControllerProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EnhancedArticleCard extends ConsumerStatefulWidget {
  final Article article;

  const EnhancedArticleCard({super.key, required this.article});

  @override
  ConsumerState<EnhancedArticleCard> createState() =>
      _EnhancedArticleCardState();
}

class _EnhancedArticleCardState extends ConsumerState<EnhancedArticleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cart = ref.watch(cartControllerProvider);
    final inCart = cart.when(
      data:
          (value) =>
              value.items.any((item) => item.article.id == widget.article.id),
      loading: () => false,
      error: (e, s) => false,
    );

    final userAsync = ref.watch(userProvider);
    String? locale;
    String currency = 'USD';
    userAsync.whenData((user) {
      // If you add locale/currency to user, use them here
    });
    locale ??= Localizations.localeOf(context).toString();

    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              _hoverController.forward();
            },
            onTapUp: (_) {
              _hoverController.reverse();
              HapticFeedback.selectionClick();
              ArticleDetailsModal.show(context, ref, widget.article);
            },
            onTapCancel: () {
              _hoverController.reverse();
            },
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
                          : [Colors.white, Colors.white.withValues(alpha: 0.9)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : AppColors.primary)
                        .withValues(alpha: 0.1),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image section (reduced vertical space)
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.1),
                            AppColors.secondary.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: Hero(
                        tag: 'article_${widget.article.id}',
                        child: Icon(
                          Icons.shopping_bag,
                          size: 40,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    // Content section
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            widget.article.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Price (now below title, smaller font)
                          Text(
                            CurrencyHelper.format(
                              widget.article.price,
                              currencyCode: currency,
                              locale: locale,
                            ),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Points info and action
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withValues(alpha: 0.1),
                                      AppColors.secondary.withValues(
                                        alpha: 0.1,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 13,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${(widget.article.price / 0.1).ceil()} pts',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quick add button
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                child: GestureDetector(
                                  onTap:
                                      inCart
                                          ? null
                                          : () async {
                                            HapticFeedback.mediumImpact();
                                            await ref
                                                .read(
                                                  cartControllerProvider
                                                      .notifier,
                                                )
                                                .addToCart(widget.article, 1);
                                          },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient:
                                          inCart
                                              ? LinearGradient(
                                                colors: [
                                                  Colors.grey.withValues(
                                                    alpha: 0.3,
                                                  ),
                                                  Colors.grey.withValues(
                                                    alpha: 0.2,
                                                  ),
                                                ],
                                              )
                                              : const LinearGradient(
                                                colors: [
                                                  AppColors.primary,
                                                  AppColors.secondary,
                                                ],
                                              ),
                                      shape: BoxShape.circle,
                                      boxShadow:
                                          inCart
                                              ? []
                                              : [
                                                BoxShadow(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                    ),
                                    child: Icon(
                                      inCart ? Icons.check : Icons.add,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:hce_emv/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Enhanced navigation item model
class NavigationItem {
  final IconData outlinedIcon;
  final IconData filledIcon;
  final String label;
  final String route;
  final String semanticLabel;

  const NavigationItem({
    required this.outlinedIcon,
    required this.filledIcon,
    required this.label,
    required this.route,
    required this.semanticLabel,
  });
}

// Navigation state provider for better state management
final navigationStateProvider =
    StateNotifierProvider<NavigationStateNotifier, NavigationState>((ref) {
      return NavigationStateNotifier();
    });

class NavigationState {
  final int selectedIndex;
  final int previousIndex;
  final bool isAnimating;

  const NavigationState({
    required this.selectedIndex,
    required this.previousIndex,
    this.isAnimating = false,
  });

  NavigationState copyWith({
    int? selectedIndex,
    int? previousIndex,
    bool? isAnimating,
  }) {
    return NavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      previousIndex: previousIndex ?? this.previousIndex,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }
}

class NavigationStateNotifier extends StateNotifier<NavigationState> {
  NavigationStateNotifier()
    : super(const NavigationState(selectedIndex: 0, previousIndex: 0));

  void updateIndex(int newIndex) {
    if (newIndex != state.selectedIndex) {
      state = state.copyWith(
        previousIndex: state.selectedIndex,
        selectedIndex: newIndex,
        isAnimating: true,
      );
    }
  }

  void completeAnimation() {
    state = state.copyWith(isAnimating: false);
  }
}

class ScaffoldNavigation extends ConsumerStatefulWidget {
  final Widget child;
  final String location;

  const ScaffoldNavigation({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  ConsumerState<ScaffoldNavigation> createState() => _ScaffoldNavigationState();
}

class _ScaffoldNavigationState extends ConsumerState<ScaffoldNavigation>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;

  // Animations
  late Animation<double> _fadeAnimation;

  // Navigation items configuration
  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      outlinedIcon: Icons.home_outlined,
      filledIcon: Icons.home_rounded,
      label: 'Home',
      route: '/home',
      semanticLabel: 'Navigate to Home tab',
    ),
    NavigationItem(
      outlinedIcon: Icons.credit_card_outlined, // Icône pour "Mes Cartes"
      filledIcon: Icons.credit_card_rounded, // Icône pour "Mes Cartes"
      label: 'Cards', // Nouveau label pour "Cards"
      route: '/mycards', // La route vers ta nouvelle page "MyCards"
      semanticLabel: 'Navigate to Cards tab',
    ),
    NavigationItem(
      outlinedIcon: Icons.history_outlined,
      filledIcon: Icons.history_rounded,
      label: 'History',
      route: '/transactions', // Si tu veux garder "History"
      semanticLabel: 'Navigate to Transaction History tab',
    ),
    NavigationItem(
      outlinedIcon: Icons.person_outline_rounded,
      filledIcon: Icons.person_rounded,
      label: 'Profile',
      route: '/profile',
      semanticLabel: 'Navigate to Profile tab',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOutCubic,
    );

    _fadeController.value = 1.0;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ScaffoldNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.location != widget.location) {
      final newIndex = _calculateSelectedIndex(widget.location);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(navigationStateProvider.notifier).updateIndex(newIndex);
        _triggerPageTransition();
      });
    }
  }

  int _calculateSelectedIndex(String location) {
    for (int i = 0; i < _navigationItems.length; i++) {
      if (location.startsWith(_navigationItems[i].route)) {
        return i;
      }
    }
    return 0; // Default to home
  }

  void _triggerPageTransition() async {
    _fadeController.reset();

    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 50));

    ref.read(navigationStateProvider.notifier).completeAnimation();
  }

  Future<void> _onItemTapped(int index, BuildContext context) async {
    final currentIndex = _calculateSelectedIndex(widget.location);

    if (currentIndex != index) {
      await HapticFeedback.lightImpact();

      ref.read(navigationStateProvider.notifier).updateIndex(index);

      final route = _navigationItems[index].route;
      if (context.mounted) {
        context.go(route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(widget.location);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: _buildAnimatedBody(),
      bottomNavigationBar: _buildEnhancedBottomNavigationBar(
        context,
        selectedIndex,
        isDark,
        theme,
      ),
      extendBody: false,
    );
  }

  Widget _buildAnimatedBody() {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeController]),
      builder: (context, child) {
        return FadeTransition(opacity: _fadeAnimation, child: child);
      },
      child: widget.child,
    );
  }

  Widget _buildEnhancedBottomNavigationBar(
    BuildContext context,
    int selectedIndex,
    bool isDark,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
            spreadRadius: 0,
          ),
          BoxShadow(
            color:
                isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.8),
            blurRadius: 0,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                isDark
                    ? AppColors.darkCard.withOpacity(0.95)
                    : AppColors.lightCard.withOpacity(0.95),
                isDark ? AppColors.darkCard : AppColors.lightCard,
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    _navigationItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isSelected = selectedIndex == index;

                      return _buildEnhancedNavItem(
                        context,
                        item,
                        isSelected,
                        index,
                        isDark,
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedNavItem(
    BuildContext context,
    NavigationItem item,
    bool isSelected,
    int index,
    bool isDark,
  ) {
    return Expanded(
      child: Semantics(
        label: item.semanticLabel,
        selected: isSelected,
        child: InkWell(
          onTap: () => _onItemTapped(index, context),
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnimatedIcon(item, isSelected, isDark),
                const SizedBox(height: 4),
                _buildAnimatedLabel(item.label, isSelected, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(NavigationItem item, bool isSelected, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.all(isSelected ? 8 : 4),
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppColors.primary.withOpacity(0.15)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Icon(
          isSelected ? item.filledIcon : item.outlinedIcon,
          key: ValueKey(isSelected),
          size: 24,
          color:
              isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildAnimatedLabel(String label, bool isSelected, bool isDark) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        fontSize: isSelected ? 12 : 11,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color:
            isSelected
                ? AppColors.primary
                : (isDark ? Colors.grey[400] : Colors.grey[600]),
        letterSpacing: 0.5,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

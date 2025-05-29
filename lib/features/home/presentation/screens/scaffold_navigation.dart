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
      outlinedIcon: Icons.shopping_bag_outlined,
      filledIcon: Icons.shopping_bag_rounded,
      label: 'Shop',
      route: '/articles',
      semanticLabel: 'Navigate to Shop tab',
    ),
    NavigationItem(
      outlinedIcon: Icons.card_giftcard_outlined,
      filledIcon: Icons.card_giftcard_rounded,
      label: 'Rewards',
      route: '/rewards',
      semanticLabel: 'Navigate to Rewards tab',
    ),
    NavigationItem(
      outlinedIcon: Icons.history_outlined,
      filledIcon: Icons.history_rounded,
      label: 'History',
      route: '/transactions',
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
    // final navigationState = ref.watch(navigationStateProvider);
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
        return FadeTransition(
          opacity: _fadeAnimation,
          child: child,
          // child: SlideTransition(
          //   position: _slideAnimation,
          //   child: ScaleTransition(scale: _scaleAnimation, child: child),
          // ),
        );
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
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
            spreadRadius: 0,
          ),
          BoxShadow(
            color:
                isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.8),
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
                    ? AppColors.darkCard.withValues(alpha: 0.95)
                    : AppColors.lightCard.withValues(alpha: 0.95),
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
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
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
                ? AppColors.primary.withValues(alpha: 0.15)
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

extension NavigationRouteExtension on BuildContext {
  void navigateToTab(int index) {
    if (index >= 0 &&
        index < _ScaffoldNavigationState._navigationItems.length) {
      final route = _ScaffoldNavigationState._navigationItems[index].route;
      go(route);
    }
  }
}

class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  SmoothPageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionDuration: duration,
         reverseTransitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           const begin = Offset(1.0, 0.0);
           const end = Offset.zero;
           const curve = Curves.easeInOutCubic;

           var tween = Tween(
             begin: begin,
             end: end,
           ).chain(CurveTween(curve: curve));

           return SlideTransition(
             position: animation.drive(tween),
             child: FadeTransition(opacity: animation, child: child),
           );
         },
       );
}


//old code
// import 'package:hce_emv/core/routes/app_route.dart';
// import 'package:hce_emv/theme/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';

// class ScaffoldNavigation extends ConsumerStatefulWidget {
//   final Widget child;
//   final String location;

//   const ScaffoldNavigation({
//     super.key,
//     required this.child,
//     required this.location,
//   });

//   @override
//   ConsumerState<ScaffoldNavigation> createState() => _ScaffoldNavigationState();
// }

// class _ScaffoldNavigationState extends ConsumerState<ScaffoldNavigation>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   int _previousIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );

//     // Initialize animation controller to completed state for initial page load
//     _animationController.value = 1.0;
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   int _calculateSelectedIndex(String location) {
//     if (location.startsWith(AppRoutes.home.path)) {
//       return 0;
//     }
//     if (location.startsWith(AppRoutes.articles.path)) {
//       return 1;
//     }
//     if (location.startsWith(AppRoutes.rewards.path)) {
//       return 2;
//     }
//     if (location.startsWith(AppRoutes.transactions.path)) {
//       return 3;
//     }
//     if (location.startsWith(AppRoutes.profile.path)) {
//       return 4;
//     }
//     return 0; // Default to home
//   }

//   void _onItemTapped(int index, BuildContext context) {
//     if (_calculateSelectedIndex(widget.location) != index) {
//       _previousIndex = _calculateSelectedIndex(widget.location);
//       _animationController.forward(from: 0.0);

//       switch (index) {
//         case 0:
//           context.go(AppRoutes.home.path);
//           break;
//         case 1:
//           context.go(AppRoutes.articles.path);
//           break;
//         case 2: 
//           context.go(AppRoutes.rewards.path);
//           break;
//         case 3:
//           context.go(AppRoutes.transactions.path);
//           break;
//         case 4:
//           context.go(AppRoutes.profile.path);
//           break;
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final selectedIndex = _calculateSelectedIndex(widget.location);
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     // When tab changes, reset animation
//     if (_previousIndex != selectedIndex) {
//       _previousIndex = selectedIndex;
//       _animationController.value = 1.0;
//     }

//     return Scaffold(
//       body: AnimatedBuilder(
//         animation: _animationController,
//         builder: (context, child) {
//           return FadeTransition(
//             opacity: CurvedAnimation(
//               parent: _animationController,
//               curve: Curves.easeInOut,
//             ),
//             child: child,
//           );
//         },
//         child: widget.child,
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.1),
//               blurRadius: 8,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
//           child: BottomNavigationBar(
//             currentIndex: selectedIndex,
//             onTap: (index) => _onItemTapped(index, context),
//             type: BottomNavigationBarType.fixed,
//             selectedItemColor: AppColors.primary,
//             unselectedItemColor: isDark ? Colors.grey[600] : Colors.grey[400],
//             backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
//             elevation: 8,
//             showSelectedLabels: true,
//             showUnselectedLabels: true,
//             selectedLabelStyle: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 12,
//             ),
//             unselectedLabelStyle: const TextStyle(fontSize: 11),
//             items: [
//               _buildNavItem(
//                 Icons.home_outlined,
//                 Icons.home,
//                 'Home',
//                 selectedIndex == 0,
//               ),
//               _buildNavItem(
//                 Icons.shopping_cart_outlined,
//                 Icons.shopping_cart,
//                 'Shop',
//                 selectedIndex == 1,
//               ),
//               _buildNavItem(
//                 Icons.card_giftcard_outlined,
//                 Icons.card_giftcard,
//                 'Rewards',
//                 selectedIndex == 2,
//               ),
//               _buildNavItem(
//                 Icons.history_outlined,
//                 Icons.history,
//                 'History',
//                 selectedIndex == 3,
//               ),
//               _buildNavItem(
//                 Icons.person_outline,
//                 Icons.person,
//                 'Profile',
//                 selectedIndex == 4,
//               ),
//             ],
//           ),
//         ),
//       ),
//       // floatingActionButton: _buildFloatingActionButton(context),
//       // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
//     BottomNavigationBarItem _buildNavItem(
//     IconData outlinedIcon,
//     IconData filledIcon,
//     String label,
//     bool isSelected,
//   ) {
//     return BottomNavigationBarItem(
//       icon: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.only(bottom: 4),
//         child: Icon(isSelected ? filledIcon : outlinedIcon),
//       ),
//       label: label,
//     );
//   }

//   // Widget? _buildFloatingActionButton(BuildContext context) {
//   //   if (widget.location.startsWith(AppRoutes.home.path)) {
//   //     return Container(
//   //       margin: const EdgeInsets.only(bottom: 20),
//   //       child: FloatingActionButton.extended(
//   //         backgroundColor: AppColors.primary,
//   //         foregroundColor: Colors.white,
//   //         elevation: 6,
//   //         onPressed: () {
//   //           _showScanDialog(context);
//   //         },
//   //         icon: const Icon(Icons.qr_code_scanner, size: 24),
//   //         label: const Text(
//   //           'Scan',
//   //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//   //         ),
//   //       ),
//   //     );
//   //   }
//   //   return null;
//   // }

//   // void _showScanDialog(BuildContext context) {
//   //   showModalBottomSheet(
//   //     context: context,
//   //     shape: const RoundedRectangleBorder(
//   //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//   //     ),
//   //     builder:
//   //         (context) => Container(
//   //           padding: const EdgeInsets.all(AppSizes.lg),
//   //           child: Column(
//   //             mainAxisSize: MainAxisSize.min,
//   //             children: [
//   //               const Row(
//   //                 children: [
//   //                   Text(
//   //                     'Scan Options',
//   //                     style: TextStyle(
//   //                       fontSize: 22,
//   //                       fontWeight: FontWeight.bold,
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //               const SizedBox(height: AppSizes.xl),
//   //               Row(
//   //                 children: [
//   //                   Expanded(
//   //                     child: _buildScanOption(
//   //                       context,
//   //                       icon: Icons.qr_code_scanner,
//   //                       title: 'Scan QR Code',
//   //                       description: 'Scan a merchant QR code to earn points',
//   //                       color: Colors.blue,
//   //                       onTap: () {
//   //                         context.pop();
//   //                         // TODO: Navigate to QR scanner page
//   //                       },
//   //                     ),
//   //                   ),
//   //                   const SizedBox(width: AppSizes.md),
//   //                   Expanded(
//   //                     child: _buildScanOption(
//   //                       context,
//   //                       icon: Icons.credit_card,
//   //                       title: 'Show My Card',
//   //                       description: 'Show your QR code to the merchant',
//   //                       color: Colors.purple,
//   //                       onTap: () {
//   //                         context.pop();
//   //                         context.push(AppRoutes.card.path);
//   //                       },
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //               const SizedBox(height: AppSizes.lg),
//   //             ],
//   //           ),
//   //         ),
//   //   );
//   // }

//   // Widget _buildScanOption(
//   //   BuildContext context, {
//   //   required IconData icon,
//   //   required String title,
//   //   required String description,
//   //   required Color color,
//   //   required VoidCallback onTap,
//   // }) {
//   //   final isDark = Theme.of(context).brightness == Brightness.dark;

//   //   return TweenAnimationBuilder<double>(
//   //     tween: Tween(begin: 0.8, end: 1.0),
//   //     duration: const Duration(milliseconds: 300),
//   //     curve: Curves.easeOutCubic,
//   //     builder: (context, value, child) {
//   //       return Transform.scale(scale: value, child: child);
//   //     },
//   //     child: InkWell(
//   //       onTap: onTap,
//   //       borderRadius: BorderRadius.circular(16),
//   //       child: Container(
//   //         padding: const EdgeInsets.all(AppSizes.lg),
//   //         decoration: BoxDecoration(
//   //           color: isDark ? AppColors.darkCard : AppColors.lightCard,
//   //           borderRadius: BorderRadius.circular(16),
//   //           border: Border.all(color: color.withAlpha(51), width: 1),
//   //           boxShadow: [
//   //             BoxShadow(
//   //               color: color.withAlpha(26),
//   //               blurRadius: 8,
//   //               offset: const Offset(0, 4),
//   //             ),
//   //           ],
//   //         ),
//   //         child: Column(
//   //           mainAxisSize: MainAxisSize.min,
//   //           children: [
//   //             Container(
//   //               width: 60,
//   //               height: 60,
//   //               decoration: BoxDecoration(
//   //                 color: color.withAlpha(26),
//   //                 borderRadius: BorderRadius.circular(16),
//   //               ),
//   //               child: Icon(icon, size: 32, color: color),
//   //             ),
//   //             const SizedBox(height: AppSizes.md),
//   //             Text(
//   //               title,
//   //               style: const TextStyle(
//   //                 fontWeight: FontWeight.bold,
//   //                 fontSize: 16,
//   //               ),
//   //               textAlign: TextAlign.center,
//   //             ),
//   //             const SizedBox(height: 4),
//   //             Text(
//   //               description,
//   //               style: TextStyle(
//   //                 fontSize: 12,
//   //                 color: isDark ? Colors.white70 : Colors.black54,
//   //                 height: 1.3,
//   //               ),
//   //               textAlign: TextAlign.center,
//   //               maxLines: 2,
//   //               overflow: TextOverflow.ellipsis,
//   //             ),
//   //           ],
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }


// }

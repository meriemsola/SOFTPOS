// lib/core/routes/go_router_provider.dart
import 'package:hce_emv/core/routes/app_route.dart';
import 'package:hce_emv/core/routes/page_transitions.dart';
import 'package:hce_emv/features/articles/presentation/screens/articles_screen.dart';
import 'package:hce_emv/features/cards/presentation/screens/card_screen.dart';
import 'package:hce_emv/features/authentication/presentation/screens/signin_screen.dart';
import 'package:hce_emv/features/authentication/presentation/screens/signup_screen.dart';
import 'package:hce_emv/features/authentication/presentation/screens/verification_screen.dart';
import 'package:hce_emv/features/authentication/presentation/states/auth_state.dart';
import 'package:hce_emv/features/home/presentation/screens/scaffold_navigation.dart';
import 'package:hce_emv/features/home/presentation/screens/splash_screen.dart';
import 'package:hce_emv/features/profile/presentation/screens/profile_screen.dart';
import 'package:hce_emv/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:hce_emv/features/profile/presentation/screens/settings_screen.dart';
import 'package:hce_emv/features/profile/presentation/screens/change_password_screen.dart';
import 'package:hce_emv/features/profile/presentation/screens/help_center_screen.dart';
import 'package:hce_emv/features/rewards/presentation/screens/rewards_screen.dart';
import 'package:hce_emv/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hce_emv/presentation/screens/card_result_screen.dart';
import 'package:hce_emv/presentation/screens/card_validation_screen.dart';
import 'package:hce_emv/presentation/screens/my_cards_screen.dart'
    hide CardScreen;

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final authInitializer = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(ref, authStateProvider),

    redirect: (context, state) {
      if (authInitializer.isLoading) {
        return '/splash';
      }

      final isAuthenticated = authState.valueOrNull ?? false;

      final isAuthRoute =
          state.matchedLocation.startsWith('/signin') ||
          state.matchedLocation.startsWith('/signup') ||
          state.matchedLocation.contains('/verification');

      final isSplashRoute = state.matchedLocation == '/splash';

      if (!isAuthenticated && !isAuthRoute && !isSplashRoute) {
        return '/signin';
      }

      if (isAuthenticated && (isAuthRoute || isSplashRoute)) {
        return '/home';
      }

      return null;
    },

    routes: [
      // Splash Route
      GoRoute(
        path: '/splash',
        pageBuilder:
            (context, state) => FadeTransitionPage(child: const SplashScreen()),
      ),

      // Root route (redirects based on auth state)
      GoRoute(path: '/', redirect: (_, __) => '/splash'),

      // Auth Routes
      GoRoute(
        path: AppRoutes.signin.path,
        name: AppRoutes.signin.name,
        pageBuilder:
            (context, state) => FadeTransitionPage(child: const SignInScreen()),
      ),
      GoRoute(
        path: AppRoutes.signup.path,
        name: AppRoutes.signup.name,
        pageBuilder:
            (context, state) => FadeTransitionPage(child: const SignUpScreen()),
      ),
      GoRoute(
        path: '${AppRoutes.verification.path}/:email',
        name: AppRoutes.verification.name,
        pageBuilder: (context, state) {
          final email = state.pathParameters['email'] ?? '';
          return SlideRightTransitionPage(
            child: VerificationScreen(email: email),
          );
        },
      ),

      // Non-tabbed Routes (no bottom navigation)
      GoRoute(
        path: AppRoutes.card.path,
        name: AppRoutes.card.name,
        pageBuilder:
            (context, state) =>
                SlideUpTransitionPage(child: const CardScreen()),
      ),

      // Profile related routes (non-tabbed)
      GoRoute(
        path: AppRoutes.editProfile.path,
        name: AppRoutes.editProfile.name,
        pageBuilder:
            (context, state) =>
                SlideRightTransitionPage(child: const EditProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.settings.path,
        name: AppRoutes.settings.name,
        pageBuilder:
            (context, state) =>
                SlideRightTransitionPage(child: const SettingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.changePassword.path,
        name: AppRoutes.changePassword.name,
        pageBuilder:
            (context, state) =>
                SlideRightTransitionPage(child: const ChangePasswordScreen()),
      ),
      GoRoute(
        path: AppRoutes.helpCenter.path,
        name: AppRoutes.helpCenter.name,
        pageBuilder:
            (context, state) =>
                SlideRightTransitionPage(child: const HelpCenterScreen()),
      ),
      GoRoute(
        path: AppRoutes.CardValidation.path,
        name: AppRoutes.CardValidation.name,
        pageBuilder:
            (context, state) =>
                SlideRightTransitionPage(child: const CardValidationScreen()),
      ),

      // Tabbed Routes (with bottom navigation)
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldNavigation(
            location: state.uri.toString(),
            child: child,
          );
        },
        routes: [
          // Home Tab
          GoRoute(
            path: AppRoutes.home.path,
            name: AppRoutes.home.name,
            builder: (context, state) => const MyHomePage(),
          ),
          // Articles Tab
          GoRoute(
            path: AppRoutes.articles.path,
            name: AppRoutes.articles.name,
            builder: (context, state) => const ArticlesScreen(),
          ),
          // Rewards Tab
          GoRoute(
            path: AppRoutes.rewards.path,
            name: AppRoutes.rewards.name,
            builder: (context, state) => const RewardsScreen(),
          ),

          // Transactions Tab
          GoRoute(
            path: AppRoutes.transactions.path,
            name: AppRoutes.transactions.name,
            builder: (context, state) => const TransactionsScreen(),
          ),

          // Profile Tab
          GoRoute(
            path: AppRoutes.profile.path,
            name: AppRoutes.profile.name,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/mycards',
            name: 'mycards',
            pageBuilder:
                (context, state) =>
                    FadeTransitionPage(child: const MyCardsScreen()),
          ),
        ],
      ),
    ],

    // Error handling
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Route not found: ${state.uri}'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => GoRouter.of(context).go(AppRoutes.home.path),
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
  );
});

// Updated GoRouterRefreshStream
class GoRouterRefreshStream extends ChangeNotifier {
  final Ref _ref;
  late final ProviderSubscription<AsyncValue<bool>> _subscription;

  GoRouterRefreshStream(
    this._ref,
    ProviderListenable<AsyncValue<bool>> provider,
  ) {
    _subscription = _ref.listen(provider, (_, __) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

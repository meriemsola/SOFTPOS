// lib/core/routes/app_route.dart
import 'package:hce_emv/core/routes/route.dart';

class AppRoutes {
  AppRoutes._(); // Private constructor to prevent instantiation

  // Auth routes
  static const signin = Route(name: 'signin', path: '/signin');
  static const signup = Route(name: 'signup', path: '/signup');
  static const verification = Route(
    name: 'verification',
    path: '/verification',
  );

  // Main routes
  static const home = Route(name: 'home', path: '/home');
  static const rewards = Route(name: 'rewards', path: '/rewards');
  static const profile = Route(name: 'profile', path: '/profile');
  static const articles = Route(name: 'articles', path: '/articles');
  static const transactions = Route(
    name: 'transactions',
    path: '/transactions',
  );
  static const card = Route(name: 'card', path: '/card');

  // Profile related routes
  static const editProfile = Route(name: 'edit-profile', path: '/edit-profile');
  static const settings = Route(name: 'settings', path: '/settings');
  static const changePassword = Route(
    name: 'change-password',
    path: '/change-password',
  );
  static const notificationSettings = Route(
    name: 'notification-settings',
    path: '/notification-settings',
  );
  static const helpCenter = Route(name: 'help-center', path: '/help-center');
  static const twoFactorAuth = Route(
    name: 'two-factor-auth',
    path: '/two-factor-auth',
  );
  static const deviceManagement = Route(
    name: 'device-management',
    path: '/device-management',
  );

  static const CardValidation = Route(
    name: 'card-validation',
    path: '/card-validation',
  );
}

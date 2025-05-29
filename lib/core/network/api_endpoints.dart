// lib/core/network/api_endpoints.dart
class ApiEndpoints {
  // Auth related endpoints
  static const String signIn = '/auth/login';
  static const String signUp = '/auth/signup';
  static const String verify = '/auth/verify';
  static const String refreshToken = '/auth/refresh-token';
  static const String resendVerification = '/auth/resend';

  // User/Profile related endpoints
  static const String getUser = '/user/me';
  static String updateUser(String userId) => '/user/update/$userId';
  static const String updateProfile = '/user/profile';
  static const String changePassword = '/user/password';
  static const String deleteAccount = '/user/account';
  static const String uploadProfileImage = '/user/profile-image';
  static const String updateNotificationPreferences =
      '/user/notification-preferences';

  // Card related endpoints
  static const String createCard = '/cards/create';
  static const String getCard = '/cards/my';
  static const String validateCard = '/cards/validate';

  // Rewards related endpoints
  static const String availableRewards = '/api/rewards/available';
  static const String claimedRewards = '/api/rewards/claimed';
  static String claimReward(String rewardId) => '/api/rewards/$rewardId/claim';

  // Articles related endpoints
  static const String getArticles = '/articles';
  static const String purchaseArticle = '/articles/{articleId}/buy';

  // Cart related endpoints
  static const String checkoutCart = '/articles/cart/checkout';

  // Transaction related endpoints
  static const String getTransactions = '/transactions/me';
  static String getTransactionArticles(String transactionId) =>
      '/api/transactions/$transactionId/articles';

  // Support related endpoints
  static const String sendFeedback = '/support/feedback';
  static const String getFAQs = '/support/faqs';
  static const String contactSupport = '/support/contact';
  static const String exportUserData = '/user/export-data';
}

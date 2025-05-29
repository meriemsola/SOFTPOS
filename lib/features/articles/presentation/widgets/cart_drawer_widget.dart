import 'package:hce_emv/core/utils/helpers/toast_helper.dart';
import 'package:hce_emv/features/articles/domain/models/checkout_request.dart';
import 'package:hce_emv/features/cards/presentation/controllers/get_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hce_emv/features/articles/presentation/controllers/cart_controller.dart';
import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/theme/app_sizes.dart';
import 'package:go_router/go_router.dart';
import 'package:hce_emv/core/utils/helpers/currency_helper.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';
import 'package:hce_emv/core/utils/helpers/points_helper.dart';

class CartDrawerWidget extends ConsumerStatefulWidget {
  const CartDrawerWidget({super.key});

  @override
  ConsumerState<CartDrawerWidget> createState() => _CartDrawerWidgetState();
}

class _CartDrawerWidgetState extends ConsumerState<CartDrawerWidget> {
  bool usePoints = false;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    final cartNotifier = ref.read(cartControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String? locale;
    String currency = 'USD';
    locale ??= Localizations.localeOf(context).toString();
    final total = cart.when(
      data: (value) => value.totalAmount,
      loading: () => 0.0,
      error: (e, s) => 0.0,
    );
    final userAsync = ref.watch(userProvider);
    int userPoints = 0;
    userAsync.whenData((user) {
      userPoints = user?.loyaltyPoints ?? 0;
    });
    // Conversion: 1 point = $0.1
    final pointsNeeded = PointsHelper.pointsNeeded(total);
    final canUsePoints = userPoints >= pointsNeeded && pointsNeeded > 0;

    return Drawer(
      child: SafeArea(
        child: Container(
          color: isDark ? AppColors.darkCard : Colors.white,
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            children: [
              const Text(
                'Your Cart',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.md),

              // User Points Display
              userAsync.when(
                data:
                    (user) =>
                        user == null
                            ? const SizedBox.shrink()
                            : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Available Points: ${user.loyaltyPoints}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
              ),

              const SizedBox(height: AppSizes.md),

              // Main scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (cart.when(
                        data: (value) => value.items.isEmpty,
                        loading: () => false,
                        error: (e, s) => false,
                      ))
                        const Text('Your cart is empty.'),
                      if (cart.when(
                        data: (value) => value.items.isNotEmpty,
                        loading: () => false,
                        error: (e, s) => false,
                      ))
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cart.when(
                            data: (value) => value.items.length,
                            loading: () => 0,
                            error: (e, s) => 0,
                          ),
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = cart.when(
                              data: (value) => value.items[index],
                              loading: () => null,
                              error: (e, s) => null,
                            );
                            if (item == null) {
                              return const SizedBox.shrink();
                            }
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(item.article.name)),
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed:
                                          () => cartNotifier.updateQuantity(
                                            item.article,
                                            item.quantity - 1,
                                          ),
                                    ),
                                    Text('${item.quantity}'),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed:
                                          () => cartNotifier.updateQuantity(
                                            item.article,
                                            item.quantity + 1,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => cartNotifier.removeFromCart(
                                            item.article,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      // Total Card
                      Card(
                        margin: const EdgeInsets.only(top: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                CurrencyHelper.format(
                                  total,
                                  currencyCode: currency,
                                  locale: locale,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                    ],
                  ),
                ),
              ),

              // Payment Method Selection (only show if cart has items)
              if (cart.when(
                data: (value) => value.items.isNotEmpty,
                loading: () => false,
                error: (e, s) => false,
              )) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[600]! : Colors.grey[200]!,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Card Payment Option
                      GestureDetector(
                        onTap: () => setState(() => usePoints = false),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                !usePoints
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  !usePoints
                                      ? AppColors.primary
                                      : Colors.grey.withValues(alpha: 0.3),
                              width: !usePoints ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                !usePoints
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color:
                                    !usePoints
                                        ? AppColors.primary
                                        : Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.credit_card, size: 20),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Pay with Card',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Points Payment Option
                      GestureDetector(
                        onTap:
                            canUsePoints
                                ? () => setState(() => usePoints = true)
                                : null,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                usePoints
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  usePoints
                                      ? AppColors.primary
                                      : canUsePoints
                                      ? Colors.grey.withValues(alpha: 0.3)
                                      : Colors.grey.withValues(alpha: 0.2),
                              width: usePoints ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    usePoints
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color:
                                        canUsePoints
                                            ? (usePoints
                                                ? AppColors.primary
                                                : Colors.grey)
                                            : Colors.grey[400],
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.star,
                                    size: 20,
                                    color:
                                        canUsePoints
                                            ? AppColors.primary
                                            : Colors.grey[400],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Pay with Points',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color:
                                            canUsePoints
                                                ? null
                                                : Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Points needed:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          canUsePoints
                                              ? Colors.grey[600]
                                              : Colors.grey[400],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          canUsePoints
                                              ? AppColors.primary.withValues(
                                                alpha: 0.1,
                                              )
                                              : Colors.grey.withValues(
                                                alpha: 0.1,
                                              ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$pointsNeeded',
                                      style: TextStyle(
                                        color:
                                            canUsePoints
                                                ? AppColors.primary
                                                : Colors.grey[400],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (!canUsePoints && pointsNeeded > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: Colors.orange[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Need ${pointsNeeded - userPoints} more points',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.orange[600],
                                            fontWeight: FontWeight.w500,
                                          ),
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
                const SizedBox(height: AppSizes.md),
              ],

              // Checkout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed:
                      (usePoints && !canUsePoints) ||
                              cart.when(
                                data: (value) => value.items.isEmpty,
                                loading: () => true,
                                error: (e, s) => true,
                              )
                          ? null
                          : () async {
                            await _checkoutCart(context, ref);
                          },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        usePoints ? Icons.star : Icons.credit_card,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        usePoints
                            ? 'Checkout with Points'
                            : 'Checkout with Card',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkoutCart(BuildContext context, WidgetRef ref) async {
    final cartAsync = ref.read(cartControllerProvider).valueOrNull;
    if (cartAsync == null || cartAsync.items.isEmpty) {
      ToastHelper.showError('Your cart is empty.');
      return;
    }
    final user = await ref.read(userProvider.future);
    final total = cartAsync.totalAmount;
    final canUsePoints = (user?.loyaltyPoints ?? 0) >= total && total > 0;
    // If using points, skip card
    if (usePoints) {
      if (!canUsePoints) {
        ToastHelper.showError('Not enough points.');
        return;
      }
      final checkoutRequest = CheckoutRequest(
        items:
            cartAsync.items
                .map(
                  (item) => CartItemRequest(
                    articleId: item.article.id,
                    quantity: item.quantity,
                  ),
                )
                .toList(),
        usePoints: true,
      );
      final purchaseController = ref.read(cartControllerProvider.notifier);
      final pointsResult = await purchaseController.checkoutCart(
        checkoutRequest,
      );
      if (!context.mounted) return;
      await _showResultDialog(
        context,
        ref,
        pointsResult,
        cartAsync,
        user,
        true,
        total,
      );
      return;
    }
    // Card payment (existing logic)
    final cardAsync = await ref.read(getCardControllerProvider.future);
    if (cardAsync == null) {
      HapticFeedback.mediumImpact();
      ToastHelper.showError('No card found. Please add a card first.');
      return;
    }
    final expiryDate =
        '${cardAsync.expiryDate.month.toString().padLeft(2, '0')}${cardAsync.expiryDate.year.toString().substring(2)}';
    final validCartItems =
        cartAsync.items.where((item) => item.article.id > 0).toList();
    if (validCartItems.isEmpty) {
      ToastHelper.showError('No valid items in cart.');
      return;
    }
    final checkoutRequest = CheckoutRequest(
      items:
          validCartItems
              .map(
                (item) => CartItemRequest(
                  articleId: item.article.id,
                  quantity: item.quantity,
                ),
              )
              .toList(),
      pan: cardAsync.pan,
      cvv: cardAsync.cvv,
      expiryDate: expiryDate,
      usePoints: false,
    );
    final purchaseController = ref.read(cartControllerProvider.notifier);
    final pointsResult = await purchaseController.checkoutCart(checkoutRequest);
    if (!context.mounted) return;
    await _showResultDialog(
      context,
      ref,
      pointsResult,
      cartAsync,
      user,
      false,
      total,
    );
  }

  Future<void> _showResultDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic pointsResult,
    dynamic cartAsync,
    dynamic user,
    bool usedPoints,
    double total,
  ) async {
    final userAsync = ref.read(userProvider);
    String? locale;
    String currency = 'USD';
    userAsync.whenData((user) {
      // If you add locale/currency to user, use them here
      // locale = user?.locale;
      // currency = user?.currencyCode ?? 'USD';
    });
    locale ??= Localizations.localeOf(context).toString();
    if (!context.mounted) return;
    if (pointsResult != null) {
      final (earnedPoints, deductedPoints, totalPoints) = pointsResult;
      HapticFeedback.heavyImpact();
      context.pop();
      ToastHelper.showSuccess('Purchase successful!');
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.celebration,
                    color: AppColors.success,
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  const Text('Purchase Successful'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 64,
                  ),
                  const SizedBox(height: AppSizes.md),
                  const Text('You have successfully purchased:'),
                  const SizedBox(height: AppSizes.md),
                  ...cartAsync.items.map(
                    (item) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text('${item.article.name} x${item.quantity}'),
                        ),
                        Text(
                          CurrencyHelper.format(
                            item.article.price * item.quantity,
                            currencyCode: currency,
                            locale: locale,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  if (!usedPoints) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          CurrencyHelper.format(
                            cartAsync.totalAmount,
                            currencyCode: currency,
                            locale: locale,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                  if (usedPoints) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Points spent:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '-${PointsHelper.pointsNeeded(total)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Points left:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${(user?.loyaltyPoints ?? 0) - PointsHelper.pointsNeeded(total)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSizes.md),
                  // Points Summary Section
                  if (earnedPoints > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.success,
                          size: 24,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'You earned: +$earnedPoints points',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                  ],
                  if (deductedPoints > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.remove_circle,
                          color: AppColors.error,
                          size: 24,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Points deducted: -$deductedPoints points',
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                  ],
                  // Net points change (optional - only show if there's both earning and deduction)
                  if (earnedPoints > 0 && deductedPoints > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          (earnedPoints - deductedPoints) >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color:
                              (earnedPoints - deductedPoints) >= 0
                                  ? AppColors.success
                                  : AppColors.error,
                          size: 24,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Net change: ${(earnedPoints - deductedPoints) >= 0 ? '+' : ''}${earnedPoints - deductedPoints} points',
                          style: TextStyle(
                            color:
                                (earnedPoints - deductedPoints) >= 0
                                    ? AppColors.success
                                    : AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Your new total: $totalPoints points',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
      );
    } else {
      HapticFeedback.mediumImpact();
      final error = ref.read(cartControllerProvider).error;
      ToastHelper.showFriendlyError(
        error ?? 'Unknown error',
        fallbackMessage: 'Failed to complete purchase',
      );
    }
  }
}

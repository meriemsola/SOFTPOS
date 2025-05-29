import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hce_emv/features/articles/domain/models/article.dart';
import 'package:hce_emv/features/articles/presentation/controllers/cart_controller.dart';
import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/theme/app_sizes.dart';
import 'package:hce_emv/core/utils/helpers/currency_helper.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';
import 'package:hce_emv/core/utils/helpers/points_helper.dart';

class ArticleDetailsModal extends ConsumerStatefulWidget {
  final Article article;

  const ArticleDetailsModal({super.key, required this.article});

  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    Article article,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (context) => ArticleDetailsModal(article: article),
    );
  }

  @override
  ConsumerState<ArticleDetailsModal> createState() =>
      _ArticleDetailsModalState();
}

class _ArticleDetailsModalState extends ConsumerState<ArticleDetailsModal> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartAsync = ref.watch(cartControllerProvider);
    final inCart = cartAsync.when(
      data:
          (cart) =>
              cart.items.any((item) => item.article.id == widget.article.id),
      loading: () => false,
      error: (e, s) => false,
    );
    final userAsync = ref.watch(userProvider);
    String? locale;
    String currency = 'USD';
    userAsync.whenData((user) {
      // If you add locale/currency to user, use them here
      // locale = user?.locale;
      // currency = user?.currencyCode ?? 'USD';
    });
    locale ??= Localizations.localeOf(context).toString();
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 32,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.shopping_bag,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(width: AppSizes.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.article.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        CurrencyHelper.format(
                          widget.article.price * quantity,
                          currencyCode: currency,
                          locale: locale,
                        ),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'or ${PointsHelper.pointsNeeded(widget.article.price * quantity)} points',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            const Text(
              'Product Details',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              widget.article.description?.isNotEmpty == true
                  ? widget.article.description!
                  : 'No description available for this product.',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: AppSizes.xl),
            // Quantity selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed:
                      quantity > 1 ? () => setState(() => quantity--) : null,
                ),
                Text(
                  '$quantity',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => quantity++),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: inCart ? Colors.grey : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed:
                    inCart
                        ? null
                        : () async {
                          await ref
                              .read(cartControllerProvider.notifier)
                              .addToCart(widget.article, quantity);
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        },
                child: Text(
                  inCart ? 'Already in Cart' : 'Add to Cart',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

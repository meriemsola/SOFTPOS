// lib/features/transactions/presentation/widgets/transaction_card.dart
import 'package:flutter/material.dart';
import 'package:hce_emv/features/transactions/domain/models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:hce_emv/core/utils/helpers/currency_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';
import 'package:hce_emv/theme/app_colors.dart';

class TransactionCard extends ConsumerStatefulWidget {
  final Transaction transaction;
  final VoidCallback onTap;
  final bool showDate;
  final int? animationIndex;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onTap,
    this.showDate = true,
    this.animationIndex,
  });

  @override
  ConsumerState<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends ConsumerState<TransactionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    // Only run the animation for the first 10 items
    if (widget.animationIndex != null && widget.animationIndex! < 10) {
      final delay = Duration(milliseconds: widget.animationIndex! * 100);
      Future.delayed(delay, () {
        if (mounted) {
          _animationController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getTransactionStatus() {
    // You can implement status logic based on response code
    if (widget.transaction.responseCode == '00') {
      return 'Success';
    } else if (widget.transaction.responseCode == '05') {
      return 'Declined';
    } else {
      return 'Pending';
    }
  }

  Color _getStatusColor() {
    final status = _getTransactionStatus();
    switch (status) {
      case 'Success':
        return Colors.green;
      case 'Declined':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionIcon() {
    // You can customize based on transaction type or amount
    return widget.transaction.amount < 0
        ? Icons.arrow_upward
        : Icons.arrow_downward;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userAsync = ref.watch(userProvider);
    String? locale;
    String currency = 'USD';

    userAsync.whenData((user) {
      // If you add locale/currency to user, use them here
    });
    locale ??= Localizations.localeOf(context).toString();

    // Only animate the first 10 items
    if (widget.animationIndex != null && widget.animationIndex! < 10) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _TransactionCardContent(
                  transaction: widget.transaction,
                  onTap: widget.onTap,
                  isPressed: _isPressed,
                  setPressed: (pressed) => setState(() => _isPressed = pressed),
                  showDate: widget.showDate,
                  locale: locale,
                  currency: currency,
                ),
              ),
            ),
          );
        },
      );
    } else {
      // Use a lighter-weight widget for the rest (no animation)
      return _TransactionCardContent(
        transaction: widget.transaction,
        onTap: widget.onTap,
        isPressed: _isPressed,
        setPressed: (pressed) => setState(() => _isPressed = pressed),
        showDate: widget.showDate,
        locale: locale,
        currency: currency,
      );
    }
  }
}

class _TransactionCardContent extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;
  final bool isPressed;
  final ValueChanged<bool> setPressed;
  final bool showDate;
  final String? locale;
  final String currency;

  const _TransactionCardContent({
    required this.transaction,
    required this.onTap,
    required this.isPressed,
    required this.setPressed,
    required this.showDate,
    required this.locale,
    required this.currency,
  });

  String _getTransactionStatus() {
    if (transaction.responseCode == '00') {
      return 'Success';
    } else if (transaction.responseCode == '05') {
      return 'Declined';
    } else {
      return 'Pending';
    }
  }

  Color _getStatusColor() {
    final status = _getTransactionStatus();
    switch (status) {
      case 'Success':
        return Colors.green;
      case 'Declined':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionIcon() {
    return transaction.amount < 0 ? Icons.arrow_upward : Icons.arrow_downward;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTapDown: (_) => setPressed(true),
        onTapUp: (_) {
          setPressed(false);
          onTap();
        },
        onTapCancel: () => setPressed(false),
        child: AnimatedScale(
          scale: isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: isPressed ? 8 : 12,
                  offset: Offset(0, isPressed ? 2 : 4),
                ),
              ],
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.transparent,
                            (isDark
                                    ? AppColors.primary
                                    : AppColors.primary.withOpacity(0.03))
                                .withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Transaction Icon
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            _getTransactionIcon(),
                            color: Colors.red,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Transaction Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      transaction.referenceNumber,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Status Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor().withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _getStatusColor().withOpacity(
                                          0.3,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      _getTransactionStatus(),
                                      style: TextStyle(
                                        color: _getStatusColor(),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    showDate
                                        ? DateFormat(
                                          'MMM d, yyyy • HH:mm',
                                        ).format(transaction.timestamp)
                                        : _formatTime(transaction.timestamp),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Card info
                              Row(
                                children: [
                                  const Icon(
                                    Icons.credit_card,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '****${transaction.pan?.substring(transaction.pan!.length - 4) ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Amount
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '-${CurrencyHelper.format(transaction.amount.abs(), currencyCode: currency, locale: locale)}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                transaction.authorizationCode ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Ripple effect overlay
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: onTap,
                        splashColor: AppColors.primary.withOpacity(0.1),
                        highlightColor: AppColors.primary.withOpacity(0.05),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

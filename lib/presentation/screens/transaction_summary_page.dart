// lib/presentation/screens/transaction_summary_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hce_emv/presentation/screens/receipt_screen.dart';
import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/theme/app_sizes.dart';

class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const _AnimatedButton({required this.child, this.onPressed});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onPressed != null ? (_) => _controller.reverse() : null,
      onTapCancel:
          widget.onPressed != null ? () => _controller.reverse() : null,
      onTap: widget.onPressed,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

class TransactionSummaryPage extends StatefulWidget {
  const TransactionSummaryPage({super.key});

  @override
  State<TransactionSummaryPage> createState() => _TransactionSummaryPageState();
}

class _TransactionSummaryPageState extends State<TransactionSummaryPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildCardIcon() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: Container(
          width: AppSizes.productImageSize, // 120.0
          height: AppSizes.productImageSize, // 120.0
          decoration: BoxDecoration(
            color: Colors.white, // Carré blanc
            borderRadius: BorderRadius.circular(
              AppSizes.cardRadiusSm,
            ), // Coins légèrement arrondis (8.0)
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 60,
            color: AppColors.primary,
          ), // Icône en violet
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Align(
        alignment: Alignment.topLeft,
        child: _AnimatedButton(
          onPressed: () {
            context.go('/home');
          },
          child: Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Icon(Icons.arrow_back, size: AppSizes.iconMd),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label :',
          style: TextStyle(
            fontSize: AppSizes.fontSizeMd,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: AppColors.lightMediumText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: AppSizes.fontSizeMd,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: AppColors.lightDarkText,
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptButton() {
    final args = GoRouterState.of(context).extra as Map<String, dynamic>?;

    final amount = args?['amount'] ?? '0.00';
    final date =
        args?['date'] != null
            ? DateTime.parse(
              args?['date']?.toString() ?? DateTime.now().toIso8601String(),
            ).toIso8601String().split('T')[0]
            : DateTime.now().toIso8601String().split('T')[0];
    final status = args?['status'] ?? 'Inconnu';
    final pan = args?['pan'] ?? '**** **** **** ****';
    final expiration = args?['expiration'] ?? '??/??';
    final name = args?['name'] ?? 'Client';
    final atc = args?['atc'] ?? '0000';
    final transactionReference = args?['transactionReference'] ?? 'TRX000000';
    final authorizationCode = args?['authorizationCode'] ?? 'AUTH000';

    return _AnimatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ReceiptScreen(
                  pan: pan,
                  expiration: expiration,
                  name: name,
                  atc: atc,
                  status: status,
                  amount: amount,
                  transactionReference: transactionReference,
                  authorizationCode: authorizationCode,
                  dateTime: date,
                ),
          ),
        );
      },
      child: Container(
        height: AppSizes.buttonHeight + 30, // Hauteur à 48.0
        width:
            MediaQuery.of(context).size.width *
            0.7, // 70% de la largeur de l'écran
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.receipt, size: AppSizes.iconLg, color: Colors.white),
              SizedBox(width: AppSizes.sm),
              Text(
                'Voir le reçu',
                style: TextStyle(
                  fontSize:
                      20.0, // Remplace AppSizes.fontSizeXl par une valeur fixe
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = GoRouterState.of(context).extra as Map<String, dynamic>?;

    final amount = args?['amount'] ?? '0.00';
    final date =
        args?['date'] != null
            ? DateTime.parse(
              args?['date']?.toString() ?? DateTime.now().toIso8601String(),
            ).toIso8601String().split('T')[0]
            : DateTime.now().toIso8601String().split('T')[0];
    final status = args?['status'] ?? 'Inconnu';
    final statusLower = status.toString().toLowerCase();

    final isSuccess =
        statusLower.contains('approuvée') ||
        statusLower.contains('acceptée') ||
        statusLower.contains('approved');

    final isRefused =
        statusLower.contains('refusée') ||
        statusLower.contains('refused') ||
        statusLower.contains('rejected');

    final labelStatus =
        isSuccess
            ? 'Transaction approuvée'
            : isRefused
            ? 'Transaction refusée'
            : 'Statut inconnu';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.lightBackground],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              children: [
                _buildBackButton(),
                const SizedBox(height: AppSizes.spaceBtwItems),
                _buildCardIcon(),
                const SizedBox(height: AppSizes.spaceBtwItems),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        elevation: AppSizes.cardElevation,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.cardRadiusLg,
                          ),
                        ),
                        color: AppColors.lightCard,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                'Montant',
                                '$amount DA',
                                isBold: true,
                              ),
                              SizedBox(height: AppSizes.spaceBtwItems),
                              _buildInfoRow('Date', date),
                              SizedBox(height: AppSizes.spaceBtwItems),
                              _buildInfoRow('Statut', labelStatus),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: AppSizes.sm,
                ), // Réduit l'espacement à 8.0 pour faire monter le bouton
                _buildReceiptButton(), // Bouton monte davantage
              ],
            ),
          ),
        ),
      ),
    );
  }
}

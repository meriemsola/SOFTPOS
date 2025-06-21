import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hce_emv/features/Softpos/emv_processor.dart';
import 'package:hce_emv/features/Softpos/transaction_storage.dart';
import 'package:hce_emv/theme/app_colors.dart';

class NfcWaitingPage extends StatefulWidget {
  final String initialAmount;

  const NfcWaitingPage({super.key, required this.initialAmount});

  @override
  State<NfcWaitingPage> createState() => _NfcWaitingPageState();
}

class _NfcWaitingPageState extends State<NfcWaitingPage> {
  String _statusMessage = 'Hold your card near the device';
  bool _isProcessing = true;
  late String amount;
  bool _hasStartedNfcSession = false;

  @override
  void initState() {
    super.initState();
    amount = widget.initialAmount;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasStartedNfcSession) {
      amount =
          ModalRoute.of(context)?.settings.arguments as String? ??
          widget.initialAmount;
      _startNfcSession();
      _hasStartedNfcSession = true;
    }
  }

  void _startNfcSession() async {
    final emvProcessor = EmvProcessor(
      context: context,
      setResult: (result) {
        if (mounted) {
          setState(() {
            _statusMessage = result;
            _isProcessing = false;
          });
        }
      },
      setTransactionData: (ac, atc, cid, expiration, status) {},
      addTransactionLog: (log) async {
        // La sauvegarde est maintenant gérée par EmvProcessor, donc rien à faire ici
        print(
          '📌 Transaction signalée via NfcWaitingPage: ${log.amount} (sauvegardée par EmvProcessor)',
        );
      },
    );

    await emvProcessor.startEMVSession(amount: amount, skipReset: false);

    if (!mounted) return;
    if (_statusMessage.contains('❌')) {
      setState(() => _isProcessing = false);
    }
  }

  Widget _styledRetryButton({required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        height: 60,
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.refresh, size: 26, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Retry',
                style: TextStyle(
                  fontSize: 20,
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

  Widget _buildAmountDisplay() {
    return Text(
      '$amount DA',
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  void _navigateBack() {
    context.goNamed('home'); // adapte ce nom à ta route si différent
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // Main UI
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 48.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.nfc_rounded,
                    size: 100,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _statusMessage,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildAmountDisplay(),
                  const SizedBox(height: 32),
                  if (_isProcessing)
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  if (!_isProcessing && _statusMessage.contains('❌')) ...[
                    const SizedBox(height: 30),
                    _styledRetryButton(
                      onPressed: () {
                        setState(() {
                          _statusMessage = 'Hold your card near the device';
                          _isProcessing = true;
                        });
                        _startNfcSession();
                      },
                    ),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Retour flèche
          Positioned(
            top: 70,
            left: 20,
            child: _AnimatedButton(
              onPressed: _navigateBack,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

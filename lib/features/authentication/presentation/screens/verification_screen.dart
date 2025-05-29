import 'dart:async';

import 'package:hce_emv/core/utils/helpers/toast_helper.dart';
import 'package:hce_emv/features/authentication/presentation/controllers/verify_controller.dart';
import 'package:hce_emv/features/authentication/presentation/states/auth_state.dart';
import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const VerificationScreen({super.key, required this.email});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _resendTimer;
  int _remainingTime = 0;
  static const int _resendDelay = 60;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startIntroAnimation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _startResendTimer();
    });
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startIntroAnimation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _scaleController.forward();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _resendTimer?.cancel();
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _remainingTime = _resendDelay;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendVerificationCode() async {
    HapticFeedback.lightImpact();
    _pinController.clear();
    await ref
        .read(verifyControllerProvider.notifier)
        .resendVerificationCode(email: widget.email);
    setState(() {
      _focusNode.requestFocus();
    });
    _startResendTimer();
  }

  Future<void> _verifyAccount() async {
    _focusNode.unfocus();
    HapticFeedback.mediumImpact();

    if (_formKey.currentState?.validate() ?? false) {
      await ref
          .read(verifyControllerProvider.notifier)
          .verifyAccount(
            email: widget.email,
            verificationCode: _pinController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<void> state = ref.watch(verifyControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    ref.listen<AsyncValue>(verifyControllerProvider, (previous, current) {
      current.whenOrNull(
        error: (error, _) {
          HapticFeedback.heavyImpact();
          ToastHelper.showError(error.toString());
        },
        data: (_) {
          if (previous is AsyncLoading &&
              ref.read(verifyControllerProvider.notifier).isResendOperation) {
            ToastHelper.showInfo("Verification code resent successfully");
          }
        },
      );
    });

    ref.listen<AsyncValue<bool>>(authStateProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) {
          HapticFeedback.heavyImpact();
          ToastHelper.showError(error.toString());
        },
        data: (isAuthenticated) {
          if (isAuthenticated) {
            HapticFeedback.mediumImpact();
            ToastHelper.showSuccess('Account verified successfully!');
          }
        },
      );
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [
                      const Color(0xFF0F1419),
                      const Color(0xFF1A1F25),
                      const Color(0xFF121418),
                    ]
                    : [
                      const Color(0xFFE3F2FD),
                      const Color(0xFFBBDEFB),
                      const Color(0xFF90CAF9),
                    ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              height: size.height - MediaQuery.of(context).padding.top,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildBackButton(),
                  const Spacer(),
                  _buildEmailIcon(isDark),
                  const SizedBox(height: 32),
                  _buildHeader(),
                  const SizedBox(height: 48),
                  _buildMainContent(isDark, state),
                  const SizedBox(height: 24),
                  _buildFooter(),
                  const Spacer(),
                ],
              ),
            ),
          ),
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
            HapticFeedback.lightImpact();
            context.pop();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Icon(Icons.arrow_back, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailIcon(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 50,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Text(
              'Verify Your Email',
              style: context.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: context.textTheme.bodyLarge?.copyWith(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : const Color(0xFF64748B),
                  fontSize: 16,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'We\'ve sent a 6-digit code to\n'),
                  TextSpan(
                    text: widget.email,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isDark, AsyncValue<void> state) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: BoxDecoration(
          color:
              isDark
                  ? const Color(0xFF1E2328).withOpacity(0.8)
                  : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color:
                isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(isDark ? 0.05 : 0.8),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(32),
            child: _buildVerificationForm(isDark, state),
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationForm(bool isDark, AsyncValue<void> state) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter Verification Code',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildPinInput(state),
          const SizedBox(height: 32),
          _buildVerifyButton(state),
          const SizedBox(height: 24),
          _buildResendButton(state),
        ],
      ),
    );
  }

  Widget _buildPinInput(AsyncValue<void> state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 64,
      textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2D32) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppColors.primary.withOpacity(0.1),
        border: Border.all(color: AppColors.primary),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Pinput(
        length: 6,
        controller: _pinController,
        focusNode: _focusNode,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        hapticFeedbackType: HapticFeedbackType.lightImpact,
        cursor: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: 2,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: submittedPinTheme,
        errorPinTheme: errorPinTheme,
        forceErrorState: state.hasError,
        errorText: state.hasError ? state.error.toString() : null,
        errorTextStyle: TextStyle(
          fontSize: 14,
          color: Colors.red,
          fontWeight: FontWeight.w600,
        ),
        validator: (pin) {
          if (pin == null || pin.isEmpty) {
            return 'Please enter the verification code';
          }
          if (pin.length != 6) {
            return 'Code must be exactly 6 digits';
          }
          return null;
        },
        onCompleted: (pin) {
          HapticFeedback.lightImpact();
          _focusNode.unfocus();
          _verifyAccount();
        },
        onChanged: (value) {
          if (value.length == 6) {
            HapticFeedback.selectionClick();
          }
        },
      ),
    );
  }

  Widget _buildVerifyButton(AsyncValue<void> state) {
    return state.maybeWhen(
      loading: () => _buildLoadingButton(),
      orElse:
          () => _AnimatedButton(
            onPressed: _verifyAccount,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'VERIFY ACCOUNT',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildLoadingButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.7),
            AppColors.secondary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildResendButton(AsyncValue<void> state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canResend = _remainingTime <= 0 && !state.isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: TextButton.icon(
        onPressed: canResend ? _resendVerificationCode : null,
        icon: Icon(
          Icons.refresh,
          size: 20,
          color:
              canResend
                  ? AppColors.primary
                  : (isDark ? Colors.white38 : Colors.black38),
        ),
        label: Text(
          _remainingTime > 0
              ? 'Resend code in ${_remainingTime}s'
              : 'Didn\'t receive the code? Resend',
          style: TextStyle(
            color:
                canResend
                    ? AppColors.primary
                    : (isDark ? Colors.white38 : Colors.black38),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white38
                      : const Color(0xFF94A3B8),
              fontSize: 12,
              height: 1.4,
            ),
            children: [
              const TextSpan(
                text: 'Check your spam folder if you don\'t see the email.\n',
              ),
              const TextSpan(text: 'The code expires in 10 minutes.'),
            ],
          ),
        ),
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

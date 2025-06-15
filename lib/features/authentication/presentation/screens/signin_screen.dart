import 'package:go_router/go_router.dart';
import 'package:hce_emv/core/extensions/context_extensions.dart';
import 'package:hce_emv/core/routes/app_route.dart';
import 'package:hce_emv/core/utils/helpers/toast_helper.dart';
import 'package:hce_emv/features/authentication/presentation/controllers/signin_controller.dart';
import 'package:hce_emv/features/authentication/presentation/states/auth_state.dart';
import 'package:hce_emv/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final bool _obscurePassword = true;
  bool _showEmailForm = false;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startIntroAnimation();
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
  }

  void _startIntroAnimation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _scaleController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    if (_formKey.currentState?.validate() ?? false) {
      await ref
          .read(signinControllerProvider.notifier)
          .signIn(
            email: _emailController.text,
            password: _passwordController.text,
            context: context,
          );
    }
  }

  void _toggleEmailForm() {
    HapticFeedback.selectionClick();
    setState(() {
      _showEmailForm = !_showEmailForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final size = MediaQuery.of(context).size;

    ref.listen<AsyncValue<bool>>(authStateProvider, (_, state) {
      state.whenOrNull(
        data: (isAuthenticated) {
          if (isAuthenticated) {
            ToastHelper.showSuccess('Welcome back!');
          }
        },
      );
    });

    ref.listen<AsyncValue<void>>(signinControllerProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) {
          HapticFeedback.heavyImpact();
          ToastHelper.showError(error.toString());
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                _buildHeader(),
                const SizedBox(height: 48),
                _buildSignInForm(isDark),
                const Spacer(),
                _buildSignUpLink(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback:
              (bounds) => LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ).createShader(bounds),
          child: Text(
            'HBT Lite Pay',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue',
          style: TextStyle(color: Colors.white60, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignInForm(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(_emailController, 'Email', Icons.email_outlined),
          const SizedBox(height: 16),
          _buildTextField(
            _passwordController,
            'Password',
            Icons.lock_outline,
            obscureText: _obscurePassword,
          ),
          const SizedBox(height: 24),
          _buildSignInButton(),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText,
    IconData prefixIcon, {
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Please enter $hintText';
        }
        return null;
      },
    );
  }

  Widget _buildSignInButton() {
    return ElevatedButton(
      onPressed: _signIn,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSignUpLink(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: isDark ? Colors.white60 : Color(0xFF64748B)),
        ),
        GestureDetector(
          onTap: () {
            context.goNamed(AppRoutes.signup.name);
          },
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

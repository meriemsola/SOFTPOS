import 'package:hce_emv/core/routes/app_route.dart';
import 'package:hce_emv/core/utils/helpers/toast_helper.dart';
import 'package:hce_emv/features/authentication/application/auth_service.dart';
import 'package:hce_emv/features/authentication/domain/models/signin_request.dart';
import 'package:hce_emv/features/profile/domain/models/user.dart';
import 'package:hce_emv/features/authentication/presentation/states/auth_state.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'signin_controller.g.dart';

@riverpod
class SigninController extends _$SigninController {
  @override
  FutureOr<void> build() {
    // Initial state
    return null;
  }

  Future<void> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();

    final request = SignInRequest(email: email, password: password);

    state = await AsyncValue.guard(() async {
      final result = await ref.read(authServiceProvider).signIn(request);
      return result.fold(
        (error) async {
          if (error == 'Account not verified. Please verify your account.') {
            await ref.read(authServiceProvider).resendVerificationCode(email);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.goNamed(
                AppRoutes.verification.name,
                pathParameters: {'email': email},
              );
              ToastHelper.showInfo(
                "Please check your email for verification code",
              );
            });
            return;
          }
          throw error;
        },
        (authResponse) async {
          if (authResponse.user.role == Role.ADMIN) {
            ToastHelper.showError('User not found');
            throw 'User not found';
          }

          await ref
              .read(storageRepositoryProvider)
              .storeToken(authResponse.token);
          await ref
              .read(storageRepositoryProvider)
              .storeRefreshToken(authResponse.refreshToken);

          // Store token expiration
          await ref
              .read(storageRepositoryProvider)
              .storeTokenExpiration(authResponse.tokenExpiration);

          await ref.read(userRepositoryProvider).saveUser(authResponse.user);

          await ref.read(authStateProvider.notifier).setAuthenticated();
          return;
        },
      );
    });
  }
}

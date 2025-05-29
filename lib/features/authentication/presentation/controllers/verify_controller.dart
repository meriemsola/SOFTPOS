import 'package:hce_emv/features/authentication/application/auth_service.dart';
import 'package:hce_emv/features/authentication/domain/models/verification_request.dart';
import 'package:hce_emv/features/authentication/presentation/states/auth_state.dart';
import 'package:hce_emv/features/cards/presentation/controllers/create_card_controller.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verify_controller.g.dart';

@riverpod
class VerifyController extends _$VerifyController {
  bool isResendOperation = false;

  @override
  FutureOr<void> build() {
    // Initial state
    return null;
  }

  Future<void> verifyAccount({
    required String email,
    required String verificationCode,
  }) async {
    isResendOperation = false;
    state = const AsyncLoading();

    final request = VerificationRequest(
      email: email,
      verificationCode: verificationCode,
    );

    state = await AsyncValue.guard(() async {
      final result = await ref.read(authServiceProvider).verifyAccount(request);
      return result.fold((error) => throw error, (authResponse) async {
        await ref
            .read(storageRepositoryProvider)
            .storeToken(authResponse.token);
        await ref
            .read(storageRepositoryProvider)
            .storeRefreshToken(authResponse.refreshToken);

        await ref
            .read(storageRepositoryProvider)
            .storeTokenExpiration(authResponse.tokenExpiration);

        await ref.read(userRepositoryProvider).saveUser(authResponse.user);

        await ref.read(createCardControllerProvider.notifier).createCard();

        await ref.read(authStateProvider.notifier).setAuthenticated();
        return;
      });
    });
  }

  Future<void> resendVerificationCode({required String email}) async {
    isResendOperation = true;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(authServiceProvider)
          .resendVerificationCode(email);
      return result.fold((error) => throw error, (user) => null);
    });
  }
}

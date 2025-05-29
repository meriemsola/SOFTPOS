import 'package:hce_emv/features/authentication/application/auth_service.dart';
import 'package:hce_emv/features/authentication/domain/models/signup_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'signup_controller.g.dart';

@riverpod
class SignupController extends _$SignupController {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    final request = SignUpRequest(
      email: email,
      password: password,
      username: username,
    );

    state = await AsyncValue.guard(() async {
      final result = await ref.read(authServiceProvider).signUp(request);
      return result.fold((error) => throw error, (user) => null);
    });
  }
}

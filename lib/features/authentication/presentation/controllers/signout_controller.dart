import 'package:hce_emv/features/authentication/presentation/states/auth_state.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'signout_controller.g.dart';

@riverpod
class SignOutController extends _$SignOutController {
  @override
  FutureOr<void> build() {
    // Initial state
    return null;
  }

  Future<void> signOut() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final storageRepository = ref.read(storageRepositoryProvider);
      await storageRepository.deleteToken();
      await storageRepository.deleteRefreshToken();

      await ref.read(userRepositoryProvider).deleteUser();

      await ref.read(authStateProvider.notifier).setUnauthenticated();
      return;
    });
  }
}

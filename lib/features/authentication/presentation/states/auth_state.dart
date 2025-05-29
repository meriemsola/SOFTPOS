import 'package:hce_emv/shared/providers/global_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_state.g.dart';

@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override
  FutureOr<bool> build() async {
    final storageRepository = ref.watch(storageRepositoryProvider);

    // Check if tokens exist
    final token = await storageRepository.getToken();
    final refreshToken = await storageRepository.getRefreshToken();

    final isAuthenticated = token != null && refreshToken != null;
    // Set the auth state based on the token check
    if (isAuthenticated) {
      ref.read(authStateProvider.notifier).setAuthenticated();
    } else {
      ref.read(authStateProvider.notifier).setUnauthenticated();
    }
    return isAuthenticated;
  }

  Future<void> setAuthenticated() async {
    state = const AsyncValue.data(true);
  }

  Future<void> setUnauthenticated() async {
    await ref.read(storageRepositoryProvider).deleteToken();
    await ref.read(storageRepositoryProvider).deleteRefreshToken();
    state = const AsyncValue.data(false);
  }
}

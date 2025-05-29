import 'package:hce_emv/features/profile/application/profile_service.dart';
import 'package:hce_emv/features/profile/domain/models/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';

part 'user_controller.g.dart';

@riverpod
class UserController extends _$UserController {
  @override
  Future<User?> build() async {
    state = const AsyncLoading();
    final user = await AsyncValue.guard(() async {
      final result = await ref.read(profileServiceProvider).getUser();
      return result.fold((error) => throw error, (user) async {
        // Save user locally
        await ref.read(userRepositoryProvider).saveUser(user);
        return user;
      });
    });
    // If user.value is a Future<User>, await it
    final value = user.value;
    state = AsyncValue.data(value);
    return value;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(profileServiceProvider).getUser();
      return result.fold((error) => throw error, (user) async {
        // Save user locally
        await ref.read(userRepositoryProvider).saveUser(user);
        return user;
      });
    });
  }
}

// lib/features/profile/presentation/controllers/edit_profile_controller.dart
import 'package:hce_emv/features/profile/application/profile_service.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_profile_controller.g.dart';

@riverpod
class EditProfileController extends _$EditProfileController {
  @override
  FutureOr<void> build() {
    // Initial state is nothing/void
  }

  Future<void> updateProfile({
    required String username,
    required String email,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(profileServiceProvider)
          .updateProfile(username: username, email: email);

      return result.fold((error) => throw error, (user) async {
        // Update the user in local storage
        await ref.read(userRepositoryProvider).saveUser(user);
        // Refresh the user provider to reflect changes
        ref.invalidate(userProvider);
        return;
      });
    });
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncLoading();

    // state = await AsyncValue.guard(() async {
    //   final result = await ref
    //       .read(profileServiceProvider)
    //       .changePassword(
    //         currentPassword: currentPassword,
    //         newPassword: newPassword,
    //       );

    //   return result.fold((error) => throw error, (_) => null);
    // });
  }

  Future<void> deleteAccount() async {
    state = const AsyncLoading();

    // state = await AsyncValue.guard(() async {
    //   final result = await ref.read(profileServiceProvider).deleteAccount();

    //   return result.fold((error) => throw error, (_) async {
    //     // Clear all local data
    //     await ref.read(storageRepositoryProvider).deleteToken();
    //     await ref.read(storageRepositoryProvider).deleteRefreshToken();
    //     await ref.read(userRepositoryProvider).deleteUser();
    //     return;
    //   });
    // });
  }
}

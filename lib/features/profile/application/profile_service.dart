// lib/features/profile/application/profile_service.dart
import 'package:hce_emv/features/profile/domain/models/user.dart';
import 'package:hce_emv/features/profile/domain/repository/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_service.g.dart';

@riverpod
ProfileService profileService(Ref ref) =>
    ProfileService(ref.watch(profileRepositoryProvider));

class ProfileService {
  final ProfileRepository _repository;

  ProfileService(this._repository);

  Future<Either<String, User>> getUser() {
    return _repository.getUser();
  }

  Future<Either<String, User>> updateProfile({
    required String username,
    required String email,
  }) {
    return _repository.updateProfile(username: username, email: email);
  }

  Future<Either<String, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<Either<String, void>> deleteAccount() {
    return _repository.deleteAccount();
  }

  Future<Either<String, String>> uploadProfileImage(String imagePath) {
    return _repository.uploadProfileImage(imagePath);
  }

  Future<Either<String, void>> updateNotificationPreferences({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
  }) {
    return _repository.updateNotificationPreferences(
      pushNotifications: pushNotifications,
      emailNotifications: emailNotifications,
      smsNotifications: smsNotifications,
    );
  }
}

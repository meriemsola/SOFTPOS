// lib/features/profile/domain/repository/profile_repository.dart
import 'package:hce_emv/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:hce_emv/features/profile/data/sources/profile_client.dart';
import 'package:hce_emv/features/profile/domain/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) =>
    ProfileRepositoryImpl(ref.watch(profileClientProvider));

abstract class ProfileRepository {
  Future<Either<String, User>> getUser();

  Future<Either<String, User>> updateProfile({
    required String username,
    required String email,
  });

  Future<Either<String, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<String, void>> deleteAccount();

  Future<Either<String, String>> uploadProfileImage(String imagePath);

  Future<Either<String, void>> updateNotificationPreferences({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
  });
}

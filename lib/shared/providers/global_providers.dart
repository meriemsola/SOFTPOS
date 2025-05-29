import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hce_emv/features/profile/domain/models/user.dart';
import 'package:hce_emv/shared/repository/storage_repository.dart';
import 'package:hce_emv/shared/repository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hce_emv/features/profile/application/profile_service.dart';

part 'global_providers.g.dart';

@riverpod
FlutterSecureStorage flutterSecureStorage(Ref ref) =>
    const FlutterSecureStorage();

@riverpod
StorageRepository storageRepository(Ref ref) =>
    SecureStorageRepository(storage: ref.watch(flutterSecureStorageProvider));

@riverpod
UserRepository userRepository(Ref ref) =>
    UserRepositoryImpl(storage: ref.watch(flutterSecureStorageProvider));

@riverpod
Future<User?> user(Ref ref) async {
  final profileService = ref.watch(profileServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final result = await profileService.getUser();
  return result.fold((error) => null, (user) async {
    await userRepository.saveUser(user);
    return user;
  });
}

@riverpod
Future<bool> isConnected(Ref ref) async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult.any((result) => result != ConnectivityResult.none);
}

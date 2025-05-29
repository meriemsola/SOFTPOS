// lib/features/profile/data/repositories/profile_repository_impl.dart
import 'package:hce_emv/core/network/network_interceptor.dart';
import 'package:hce_emv/features/profile/data/sources/profile_client.dart';
import 'package:hce_emv/features/profile/domain/models/user.dart';
import 'package:hce_emv/features/profile/domain/repository/profile_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileClient _profileClient;

  ProfileRepositoryImpl(this._profileClient);

  @override
  Future<Either<String, User>> getUser() async {
    try {
      final response = await _profileClient.getUser();
      if (response.status == 'success' && response.data != null) {
        return right(response.data!);
      }
      return left(response.message);
    } on DioException catch (e) {
      final errorMessage = DioErrorHandler.handleError(e);
      return left(errorMessage);
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, User>> updateProfile({
    required String username,
    required String email,
  }) async {
    try {
      final response = await _profileClient.updateProfile(
        username: username,
        email: email,
      );
      if (response.status == 'success' && response.data != null) {
        return right(response.data!);
      }
      return left(response.message);
    } on DioException catch (e) {
      final errorMessage = DioErrorHandler.handleError(e);
      return left(errorMessage);
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _profileClient.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      if (response.status == 'success') {
        return right(null);
      }
      return left(response.message);
    } on DioException catch (e) {
      final errorMessage = DioErrorHandler.handleError(e);
      return left(errorMessage);
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteAccount() async {
    try {
      final response = await _profileClient.deleteAccount();
      if (response.status == 'success') {
        return right(null);
      }
      return left(response.message);
    } on DioException catch (e) {
      final errorMessage = DioErrorHandler.handleError(e);
      return left(errorMessage);
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> uploadProfileImage(String imagePath) async {
    try {
      final response = await _profileClient.uploadProfileImage(imagePath);
      if (response.status == 'success' && response.data != null) {
        return right(response.data!);
      }
      return left(response.message);
    } on DioException catch (e) {
      final errorMessage = DioErrorHandler.handleError(e);
      return left(errorMessage);
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateNotificationPreferences({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
  }) async {
    try {
      final response = await _profileClient.updateNotificationPreferences(
        pushNotifications: pushNotifications,
        emailNotifications: emailNotifications,
        smsNotifications: smsNotifications,
      );
      if (response.status == 'success') {
        return right(null);
      }
      return left(response.message);
    } on DioException catch (e) {
      final errorMessage = DioErrorHandler.handleError(e);
      return left(errorMessage);
    } catch (e) {
      return left(e.toString());
    }
  }
}

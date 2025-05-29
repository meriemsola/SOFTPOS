// lib/features/profile/data/sources/profile_client.dart
import 'package:dio/dio.dart';
import 'package:hce_emv/core/network/api_client.dart';
import 'package:hce_emv/core/network/api_endpoints.dart';
import 'package:hce_emv/core/network/api_response.dart';
import 'package:hce_emv/features/profile/domain/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_client.g.dart';

@riverpod
ProfileClient profileClient(Ref ref) =>
    ProfileClient(ref.watch(apiClientProvider));

class ProfileClient {
  final ApiClient _apiClient;

  ProfileClient(this._apiClient);

  Future<ApiResponse<User>> getUser() async {
    return _apiClient.get<User>(
      ApiEndpoints.getUser,
      fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<User>> updateProfile({
    required String username,
    required String email,
  }) async {
    return _apiClient.put<User>(
      '/user/profile',
      data: {'username': username, 'email': email},
      fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return _apiClient.put<void>(
      '/user/password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  Future<ApiResponse<void>> deleteAccount() async {
    return _apiClient.delete<void>('/user/account');
  }

  Future<ApiResponse<String>> uploadProfileImage(String imagePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
    });

    return _apiClient.post<String>(
      '/user/profile-image',
      data: formData,
      fromJson: (json) => json as String,
    );
  }

  Future<ApiResponse<void>> updateNotificationPreferences({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
  }) async {
    final data = <String, dynamic>{};

    if (pushNotifications != null) {
      data['pushNotifications'] = pushNotifications;
    }
    if (emailNotifications != null) {
      data['emailNotifications'] = emailNotifications;
    }
    if (smsNotifications != null) {
      data['smsNotifications'] = smsNotifications;
    }

    return _apiClient.put<void>('/user/notification-preferences', data: data);
  }
}

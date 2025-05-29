// auth_client.dart
import 'package:hce_emv/core/network/api_client.dart';
import 'package:hce_emv/core/network/api_endpoints.dart';
import 'package:hce_emv/core/network/api_response.dart';
import 'package:hce_emv/features/authentication/domain/models/auth_response.dart';
import 'package:hce_emv/features/authentication/domain/models/signin_request.dart';
import 'package:hce_emv/features/authentication/domain/models/signup_request.dart';
import 'package:hce_emv/features/profile/domain/models/user.dart';
import 'package:hce_emv/features/authentication/domain/models/verification_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_client.g.dart';

@riverpod
AuthClient authClient(Ref ref) => AuthClient(ref.watch(apiClientProvider));

class AuthClient {
  final ApiClient _apiClient;

  AuthClient(this._apiClient);

  Future<ApiResponse<User>> signUp(SignUpRequest request) async {
    return _apiClient.post<User>(
      ApiEndpoints.signUp,
      data: request.toJson(),
      fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<AuthResponse>> verifyAccount(
    VerificationRequest request,
  ) async {
    return _apiClient.post<AuthResponse>(
      ApiEndpoints.verify,
      data: request.toJson(),
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<AuthResponse>> signIn(SignInRequest request) async {
    return _apiClient.post<AuthResponse>(
      ApiEndpoints.signIn,
      data: request.toJson(),
      fromJson: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<String>> resendVerificationCode(String email) async {
    return _apiClient.post<String>(
      ApiEndpoints.resendVerification,
      queryParameters: {'email': email},
      fromJson: (json) {
        if (json is String) {
          return json;
        } else if (json is Map && json['message'] != null) {
          return json['message'] as String;
        }
        return 'Verification code sent';
      },
    );
  }
}

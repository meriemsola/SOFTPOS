// auth_repository_implementation.dart
import 'package:dio/dio.dart';
import 'package:hce_emv/core/network/network_interceptor.dart';
import 'package:hce_emv/features/authentication/data/sources/auth_client.dart';
import 'package:hce_emv/features/authentication/domain/models/auth_response.dart';
import 'package:hce_emv/features/authentication/domain/models/signin_request.dart';
import 'package:hce_emv/features/authentication/domain/models/signup_request.dart';
import 'package:hce_emv/features/profile/domain/models/user.dart';
import 'package:hce_emv/features/authentication/domain/models/verification_request.dart';
import 'package:hce_emv/features/authentication/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthClient _authClient;

  AuthRepositoryImpl(this._authClient);

  @override
  Future<Either<String, User>> signUp(SignUpRequest request) async {
    try {
      final response = await _authClient.signUp(request);
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
  Future<Either<String, AuthResponse>> verifyAccount(
    VerificationRequest request,
  ) async {
    try {
      final response = await _authClient.verifyAccount(request);
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
  Future<Either<String, String>> resendVerificationCode(String email) async {
    try {
      final response = await _authClient.resendVerificationCode(email);
      if (response.status == 'success') {
        return right(response.data ?? response.message);
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
  Future<Either<String, AuthResponse>> signIn(SignInRequest request) async {
    try {
      final response = await _authClient.signIn(request);
      if (response.status == 'success' && response.data != null) {
        return right(response.data!);
      }
      // Use the message from the API response itself
      return left(response.message);
    } on DioException catch (e) {
      final errorMessage = DioErrorHandler.handleError(e);
      // Check if this is a credentials error
      if (e.response?.statusCode == 400 &&
          e.response?.data is Map &&
          (e.response?.data as Map)['message'] == 'Bad credentials') {
        return left('Invalid email or password, please try again.');
      }
      return left(errorMessage);
    } catch (e) {
      return left(e.toString());
    }
  }
}

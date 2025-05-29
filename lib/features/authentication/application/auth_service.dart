import 'package:hce_emv/features/authentication/domain/models/auth_response.dart';
import 'package:hce_emv/features/authentication/domain/models/signin_request.dart';
import 'package:hce_emv/features/authentication/domain/models/signup_request.dart';
import 'package:hce_emv/features/profile/domain/models/user.dart';
import 'package:hce_emv/features/authentication/domain/models/verification_request.dart';
import 'package:hce_emv/features/authentication/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

@riverpod
AuthService authService(Ref ref) =>
    AuthService(ref.watch(authRepositoryProvider));

class AuthService {
  final AuthRepository _repository;

  AuthService(this._repository);

  Future<Either<String, AuthResponse>> signIn(SignInRequest request) {
    return _repository.signIn(request);
  }

  Future<Either<String, AuthResponse>> verifyAccount(
    VerificationRequest request,
  ) {
    return _repository.verifyAccount(request);
  }

  Future<Either<String, String>> resendVerificationCode(String email) async {
    return await _repository.resendVerificationCode(email);
  }

  Future<Either<String, User>> signUp(SignUpRequest request) {
    return _repository.signUp(request);
  }

  // Future<Either<String, User>> getCurrentUser() async {
  //   return await _repository.getCurrentUser();
  // }
}

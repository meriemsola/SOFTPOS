import 'package:hce_emv/features/authentication/data/sources/auth_client.dart';
import 'package:hce_emv/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:hce_emv/features/authentication/domain/models/auth_response.dart';
import 'package:hce_emv/features/authentication/domain/models/signin_request.dart';
import 'package:hce_emv/features/authentication/domain/models/signup_request.dart';
import 'package:hce_emv/features/profile/domain/models/user.dart';
import 'package:hce_emv/features/authentication/domain/models/verification_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) =>
    AuthRepositoryImpl(ref.watch(authClientProvider));

abstract class AuthRepository {
  Future<Either<String, AuthResponse>> signIn(SignInRequest request);
  Future<Either<String, AuthResponse>> verifyAccount(
    VerificationRequest request,
  );
  Future<Either<String, String>> resendVerificationCode(String email);
  Future<Either<String, User>> signUp(SignUpRequest request);
}

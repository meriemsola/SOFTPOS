import 'dart:convert';

import 'package:hce_emv/features/profile/domain/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class UserRepository {
  Future<void> saveUser(User user);
  Future<User?> getUser();
  Future<void> deleteUser();
}

class UserRepositoryImpl implements UserRepository {
  static const String _keyUser = 'user';
  final FlutterSecureStorage storage;

  UserRepositoryImpl({required this.storage});

  @override
  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await storage.write(key: _keyUser, value: userJson);
  }

  @override
  Future<User?> getUser() async {
    final userJson = await storage.read(key: _keyUser);
    if (userJson == null) return null;

    try {
      return User.fromJson(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteUser() => storage.delete(key: _keyUser);
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';



abstract interface class StorageRepository {
  Future<void> storeToken(String token);

  Future<void> storeRefreshToken(String token);

  Future<String?> getToken();

  Future<String?> getRefreshToken();

  Future<void> deleteToken();

  Future<void> deleteRefreshToken();

  // New method to store token expiration
  Future<void> storeTokenExpiration(int expiresAt);

  // New method to get token expiration
  Future<int?> getTokenExpiration();
}

class SecureStorageRepository implements StorageRepository {
  static const String _keyToken = 'token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyTokenExpiration = 'token_expiration';

  final FlutterSecureStorage storage;

  const SecureStorageRepository({required this.storage});

  // Token
  @override
  Future<String?> getToken() => storage.read(key: _keyToken);

  @override
  Future<void> storeToken(String token) =>
      storage.write(key: _keyToken, value: token);

  @override
  Future<void> deleteToken() => storage.delete(key: _keyToken);

  // Refresh Token
  @override
  Future<String?> getRefreshToken() => storage.read(key: _keyRefreshToken);

  @override
  Future<void> storeRefreshToken(String token) =>
      storage.write(key: _keyRefreshToken, value: token);

  @override
  Future<void> deleteRefreshToken() => storage.delete(key: _keyRefreshToken);

  @override
  Future<void> storeTokenExpiration(int expiresAt) =>
      storage.write(key: _keyTokenExpiration, value: expiresAt.toString());

  @override
  Future<int?> getTokenExpiration() async {
    final expirationStr = await storage.read(key: _keyTokenExpiration);
    if (expirationStr == null) return null;
    try {
      return int.parse(expirationStr);
    } catch (_) {
      return null;
    }
  }
}

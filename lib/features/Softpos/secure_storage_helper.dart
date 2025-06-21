import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SecureStorageHelper {
  static const _storage = FlutterSecureStorage();
  static const _keyKey = 'encryption_key';
  static const _ivKey = 'encryption_iv';

  static Future<encrypt.Key> getOrCreateKey() async {
    String? keyString = await _storage.read(key: _keyKey);
    if (keyString == null) {
      final key = encrypt.Key.fromSecureRandom(32);
      await _storage.write(key: _keyKey, value: key.base64);
      return key;
    }
    return encrypt.Key.fromBase64(keyString);
  }

  static Future<encrypt.IV> getOrCreateIv() async {
    String? ivString = await _storage.read(key: _ivKey);
    if (ivString == null) {
      final iv = encrypt.IV.fromSecureRandom(16);
      await _storage.write(key: _ivKey, value: iv.base64);
      return iv;
    }
    return encrypt.IV.fromBase64(ivString);
  }
}
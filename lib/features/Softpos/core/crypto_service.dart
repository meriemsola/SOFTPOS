import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:hce_emv/features/Softpos/secure_storage_helper.dart';



class CryptoService {
  /// Chiffre une donnée sensible avec la clé AES et l’IV de SecureStorageHelper
  Future<String> encryptData(String plainText) async {
    try {
      if (plainText.isEmpty) return '';
      final key =
          SecureStorageHelper.getOrCreateKey()
              .then((key) => key)
              .asStream()
              .first;
      final iv =
          SecureStorageHelper.getOrCreateIv().then((iv) => iv).asStream().first;
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key as encrypt.Key, mode: encrypt.AESMode.cbc),
      );
      final encrypted = encrypter.encrypt(plainText, iv: await iv);
      print('📌 Donnée chiffrée : ${encrypted.base64}');
      return encrypted.base64;
    } catch (e) {
      print('❌ Erreur chiffrement : $e');
      return '';
    }
  }

  /// Déchiffre une donnée sensible
  Future<String> decryptData(String encryptedData) async {
    try {
      if (encryptedData.isEmpty || !_isValidBase64(encryptedData)) {
        print('❌ Données Base64 invalides : $encryptedData');
        return '';
      }
      final key =
          SecureStorageHelper.getOrCreateKey()
              .then((key) => key)
              .asStream()
              .first;
      final iv =
          SecureStorageHelper.getOrCreateIv().then((iv) => iv).asStream().first;
      final encryptedBytes = encrypt.Encrypted.fromBase64(encryptedData);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key as encrypt.Key, mode: encrypt.AESMode.cbc),
      );
      final decrypted = encrypter.decrypt(encryptedBytes, iv: await iv);
      print('📌 Donnée déchiffrée');
      return decrypted;
    } catch (e) {
      print('❌ Erreur déchiffrement : $e');
      return '';
    }
  }

  /// Valide une chaîne Base64
  bool _isValidBase64(String input) {
    try {
      base64Decode(input.trim());
      return true;
    } catch (e) {
      return false;
    }
  }
}

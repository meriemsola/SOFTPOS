import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

class CardEncryptionService {
  // Clé de 16 caractères pour AES-128
  static final String secretKey = '1234567890abcdef'; // Clé de 16 caractères
  static final encrypt.Key key = encrypt.Key.fromUtf8(secretKey);
  static final encrypt.IV iv = encrypt.IV.fromLength(16); // IV de 16 octets

  // Fonction de chiffrement pour PAN
  static String encryptPan(String pan) {
    // Créer un encrypteur AES en mode CBC avec padding PKCS7
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );

    // Chiffrer les données
    final encrypted = encrypter.encrypt(pan, iv: iv);

    // Retourner les données chiffrées en base64
    return encrypted.base64;
  }

  // Fonction de chiffrement pour CVV
  static String encryptCvv(String cvv) {
    // Créer un encrypteur AES en mode CBC avec padding PKCS7
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );

    // Chiffrer les données
    final encrypted = encrypter.encrypt(cvv, iv: iv);

    // Retourner les données chiffrées en base64
    return encrypted.base64;
  }
}

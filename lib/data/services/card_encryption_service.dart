import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

class CardEncryptionService {
  // Clé de 16 caractères pour AES-128
  static final String secretKey = '16byteslongkey'; // Clé de 16 caractères
  static final encrypt.Key key = encrypt.Key.fromUtf8(secretKey);
  static final encrypt.IV iv = encrypt.IV.fromLength(16); // IV de 16 octets

  // Fonction de chiffrement
  static String encryptCardData({
    required String pan,
    required String expiry,
    required String cvv,
  }) {
    // Créer les données à chiffrer sous forme de JSON
    final plainText = jsonEncode({'pan': pan, 'expiry': expiry, 'cvv': cvv});

    // Créer un encrypteur AES en mode CBC avec padding PKCS7
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );

    // Chiffrer les données
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Retourner les données chiffrées en base64
    return encrypted.base64;
  }
}

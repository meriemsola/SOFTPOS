import 'dart:convert';
import 'package:hce_emv/features/Softpos/models/transaction_log_model.dart';
import 'package:hce_emv/features/Softpos/secure_storage_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;


class TransactionStorage {
  static const String _key = 'transaction_logs';

  static Future<void> saveTransaction(TransactionLog transaction) async {
    try {
      print('📌 Début sauvegarde transaction: ${transaction.amount}');
      final prefs = await SharedPreferences.getInstance();
      final key = await SecureStorageHelper.getOrCreateKey();
      final iv = await SecureStorageHelper.getOrCreateIv();

      final transactions = await loadTransactions();
      print('📌 Transactions existantes: ${transactions.length}');
      transactions.add(transaction);

      final encoded = jsonEncode(transactions.map((t) => t.toMap()).toList());
      print('📌 Données JSON encodées: ${encoded.length} caractères');
      final encrypted = _encryptData(encoded, key, iv);
      if (encrypted.isNotEmpty) {
        await prefs.setString(_key, encrypted);
        print('📌 Transaction sauvegardée avec succès: ${transaction.amount}');
      } else {
        print('❌ Échec chiffrement transaction');
        throw Exception('Échec du chiffrement des données');
      }
    } catch (e, stackTrace) {
      print('❌ Erreur sauvegarde transaction: $e\n$stackTrace');
      rethrow;
    }
  }

  static Future<void> saveTransactions(List<TransactionLog> transactions) async {
    try {
      print('📌 Début sauvegarde ${transactions.length} transactions');
      final prefs = await SharedPreferences.getInstance();
      final key = await SecureStorageHelper.getOrCreateKey();
      final iv = await SecureStorageHelper.getOrCreateIv();

      final encoded = jsonEncode(transactions.map((t) => t.toMap()).toList());
      print('📌 Données JSON encodées: ${encoded.length} caractères');
      final encrypted = _encryptData(encoded, key, iv);
      if (encrypted.isNotEmpty) {
        await prefs.setString(_key, encrypted);
        print('📌 ${transactions.length} transactions sauvegardées avec succès');
      } else {
        print('❌ Échec chiffrement transactions');
        throw Exception('Échec du chiffrement des données');
      }
    } catch (e, stackTrace) {
      print('❌ Erreur sauvegarde transactions: $e\n$stackTrace');
      rethrow;
    }
  }

  static Future<List<TransactionLog>> loadTransactions() async {
    try {
      print('📌 Début chargement transactions');
      final prefs = await SharedPreferences.getInstance();
      final key = await SecureStorageHelper.getOrCreateKey();
      final iv = await SecureStorageHelper.getOrCreateIv();

      final encrypted = prefs.getString(_key);
      if (encrypted == null || encrypted.isEmpty) {
        print('⚠️ Aucun journal trouvé dans SharedPreferences');
        return [];
      }
      print('📌 Données chiffrées trouvées: ${encrypted.length} caractères');
      final decrypted = _decryptData(encrypted, key, iv);
      if (decrypted.isEmpty) {
        print('❌ Échec déchiffrement transactions');
        await cleanTransactions();
        return [];
      }
      print('📌 Données déchiffrées: ${decrypted.length} caractères');
      final decoded = jsonDecode(decrypted) as List;
      final logs = decoded.map((e) => TransactionLog.fromMap(e)).toList();
      print('📌 ${logs.length} transactions chargées avec succès');
      return logs;
    } catch (e, stackTrace) {
      print('❌ Erreur chargement transactions: $e\n$stackTrace');
      await cleanTransactions();
      return [];
    }
  }

  static Future<void> clearTransactions() async {
    try {
      print('📌 Début suppression historique');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      print('📌 Historique vidé avec succès');
    } catch (e, stackTrace) {
      print('❌ Erreur suppression transactions: $e\n$stackTrace');
      rethrow;
    }
  }

  static Future<void> cleanTransactions() async {
    SharedPreferences? prefs;
    try {
      print('📌 Début nettoyage transactions');
      prefs = await SharedPreferences.getInstance();
      final encrypted = prefs.getString(_key);
      if (encrypted == null || encrypted.isEmpty) {
        print('📌 Aucun journal à nettoyer');
        return;
      }
      if (!_isValidBase64(encrypted)) {
        await prefs.remove(_key);
        print('❌ Données Base64 invalides supprimées');
        return;
      }
      final key = await SecureStorageHelper.getOrCreateKey();
      final iv = await SecureStorageHelper.getOrCreateIv();
      final decrypted = _decryptData(encrypted, key, iv);
      if (decrypted.isEmpty) {
        await prefs.remove(_key);
        print('❌ Données corrompues supprimées');
        return;
      }
      final decoded = jsonDecode(decrypted) as List;
      final logs = decoded.map((e) => TransactionLog.fromMap(e)).toList();
      await saveTransactions(logs);
      print('📌 Journaux nettoyés: ${logs.length} entrées');
    } catch (e, stackTrace) {
      print('❌ Erreur nettoyage transactions: $e\n$stackTrace');
      if (prefs != null) {
        await prefs.remove(_key);
        print('❌ Clé $_key supprimée en raison d\'erreur');
      } else {
        print('⚠️ Impossible de supprimer la clé: SharedPreferences non initialisé');
      }
    }
  }

  static String _encryptData(String plainText, encrypt.Key key, encrypt.IV iv) {
    try {
      if (plainText.isEmpty) {
        print('⚠️ Données à chiffrer vides');
        return '';
      }
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      print('📌 Données chiffrées: ${encrypted.base64.length} caractères');
      return encrypted.base64;
    } catch (e, stackTrace) {
      print('❌ Erreur chiffrement: $e\n$stackTrace');
      return '';
    }
  }

  static String _decryptData(String encryptedData, encrypt.Key key, encrypt.IV iv) {
    try {
      if (encryptedData.isEmpty || !_isValidBase64(encryptedData)) {
        print('❌ Données Base64 invalides: $encryptedData');
        return '';
      }
      final encryptedBytes = encrypt.Encrypted.fromBase64(encryptedData);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final decrypted = encrypter.decrypt(encryptedBytes, iv: iv);
      print('📌 Données déchiffrées avec succès');
      return decrypted;
    } catch (e, stackTrace) {
      print('❌ Erreur déchiffrement: $e\n$stackTrace');
      return '';
    }
  }

  static bool _isValidBase64(String input) {
    try {
      base64Decode(input.trim());
      print('📌 Données Base64 valides');
      return true;
    } catch (e) {
      print('❌ Données Base64 invalides: $e');
      return false;
    }
  }
}
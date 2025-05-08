import 'dart:convert';
import 'package:http/http.dart' as http; // Import du package HTTP
import 'package:hce_emv/data/services/card_encryption_service.dart'; // Import du service de cryptage

class BackendService {
  static Future<Map<String, dynamic>> verifyCard({
    required String pan,
    required String expiry,
    required String cvv,
  }) async {
    try {
      // Crypter le PAN et le CVV séparément
      String encryptedPan = CardEncryptionService.encryptPan(
        pan,
      ); // Crypter le PAN
      String encryptedCvv = CardEncryptionService.encryptCvv(
        cvv,
      ); // Crypter le CVV

      // Remplacez par l'URL de ton API backend
      final Uri apiUrl = Uri.parse('http://localhost:9000/api/cards');

      // Envoie des données cryptées au backend (en tant que POST)
      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pan': encryptedPan, // PAN crypté
          'expiryDate': expiry, // Expiry en clair
          'cvv': encryptedCvv, // CVV crypté
        }),
      );

      // Vérifie si la réponse est un succès
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Traite les données et renvoie la réponse
        return {
          'status': responseData['status'],
          'first_name': responseData['first_name'],
          'last_name': responseData['last_name'],
          'pan': responseData['pan'],
          'expiry': responseData['expiry'],
          'cvv': responseData['cvv'],
        };
      } else {
        // Si la réponse est une erreur
        throw Exception('Erreur du serveur : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la communication avec le backend : $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }
}

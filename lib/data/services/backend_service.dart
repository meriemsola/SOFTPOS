import 'dart:convert';
import 'package:http/http.dart' as http; // Import du package HTTP

class BackendService {
  static Future<Map<String, dynamic>> verifyCard(String encryptedData) async {
    try {
      // Remplacez par l'URL de ton API backend
      final Uri apiUrl = Uri.parse('https://ton-backend.com/api/verify-card');

      // Envoie des données au backend (en tant que POST)
      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'encryptedData': encryptedData}),
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

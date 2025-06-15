import 'package:http/http.dart' as http;
import 'dart:convert';

class BackendService {
  static Future<String> validateCard({
    required String pan,
    required String cvv,
    required String expiryDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://hb-backend-kmns.onrender.com:9000/cards/validate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'pan': pan, 'cvv': cvv, 'expiryDate': expiryDate}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] ?? "Réponse vide";
      } else {
        return "Carte not valide ";
      }
    } catch (e) {
      return "Erreur de connexion au serveur.";
    }
  }
}

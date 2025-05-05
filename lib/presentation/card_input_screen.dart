import 'package:flutter/material.dart';
import 'package:hce_emv/data/services/card_encryption_service.dart'; // Ajout de l'import du cryptage
import 'package:hce_emv/presentation/screens/card_result_screen.dart'; // Ajout de l'import de l'écran de résultat

class CardInputScreen extends StatefulWidget {
  const CardInputScreen({super.key});

  @override
  State<CardInputScreen> createState() => _CardInputScreenState();
}

class _CardInputScreenState extends State<CardInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _panController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _panController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _validateAndProceed() {
    if (_formKey.currentState?.validate() ?? false) {
      String pan = _panController.text;
      String expiry = _expiryController.text;
      String cvv = _cvvController.text;

      // 1. Crypter les données
      String encryptedData = CardEncryptionService.encryptCardData(
        pan: pan,
        expiry: expiry,
        cvv: cvv,
      );

      // 2. Naviguer vers l'écran de résultat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => CardResultScreen(encryptedCardData: encryptedData),
        ),
      );
    }
  }

  String? _validatePan(String? value) {
    if (value == null || value.isEmpty) return 'Entrez un numéro de carte';
    if (!RegExp(r'^\d{13,19}$').hasMatch(value)) {
      return 'Le PAN doit contenir 13 à 19 chiffres';
    }
    return null;
  }

  String? _validateExpiry(String? value) {
    if (value == null || value.isEmpty) return 'Entrez la date d\'expiration';
    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(value)) {
      return 'Format invalide (MM/YY)';
    }
    return null;
  }

  String? _validateCvv(String? value) {
    if (value == null || value.isEmpty) return 'Entrez le CVV';
    if (!RegExp(r'^\d{3}$').hasMatch(value)) {
      return 'Le CVV doit contenir 3 chiffres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrer les infos de carte')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _panController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Numéro de carte (PAN)',
                  border: OutlineInputBorder(),
                ),
                validator: _validatePan,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expiryController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: 'Date d\'expiration (MM/YY)',
                  border: OutlineInputBorder(),
                ),
                validator: _validateExpiry,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(),
                ),
                validator: _validateCvv,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _validateAndProceed,
                child: const Text('Valider'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

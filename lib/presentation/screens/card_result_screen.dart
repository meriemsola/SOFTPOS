import 'package:flutter/material.dart';
import 'package:hce_emv/data/services/backend_service.dart'; // Import du backend pour envoyer les données
import 'package:hce_emv/presentation/widgets/credit_card_widget.dart';
import 'package:hce_emv/presentation/widgets/loader_widget.dart';

class CardResultScreen extends StatefulWidget {
  final String pan;
  final String expiry;
  final String cvv;

  const CardResultScreen({
    super.key,
    required this.pan,
    required this.expiry,
    required this.cvv,
  });

  @override
  State<CardResultScreen> createState() => _CardResultScreenState();
}

class _CardResultScreenState extends State<CardResultScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _cardInfo;

  @override
  void initState() {
    super.initState();
    _simulateBackendCall();
  }

  // Fonction pour simuler l'appel au backend avec les données en clair
  Future<void> _simulateBackendCall() async {
    try {
      final response = await BackendService.verifyCard(
        pan: widget.pan,
        expiry: widget.expiry,
        cvv: widget.cvv,
      );
      if (mounted) {
        setState(() {
          _cardInfo = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur backend: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Masquage du PAN pour l'affichage
  String _maskPan(String pan) {
    if (pan.length < 16) return pan;
    return '${pan.substring(0, 6)}•• •••• ${pan.substring(12)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Votre carte bancaire')),
      body:
          _isLoading
              ? const LoaderWidget()
              : _cardInfo == null
              ? const Center(child: Text('Erreur de chargement'))
              : Center(
                child: CreditCardWidget(
                  maskedPan: _maskPan(_cardInfo!['pan']),
                  expiryDate: _cardInfo!['expiry'],
                  cvv: _cardInfo!['cvv'],
                  cardHolderName:
                      '${_cardInfo!['first_name']} ${_cardInfo!['last_name']}',
                ),
              ),
    );
  }
}

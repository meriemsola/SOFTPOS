import 'package:flutter/material.dart';
import 'package:hce_emv/data/services/backend_service.dart'; // Remplacer BackendSimulationService par BackendService
import 'package:hce_emv/presentation/widgets/credit_card_widget.dart';
import 'package:hce_emv/presentation/widgets/loader_widget.dart';

class CardResultScreen extends StatefulWidget {
  final String encryptedCardData;

  const CardResultScreen({super.key, required this.encryptedCardData});

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

  Future<void> _simulateBackendCall() async {
    try {
      final response = await BackendService.verifyCard(
        // Remplacer BackendSimulationService par BackendService
        widget.encryptedCardData,
      );
      if (mounted) {
        setState(() {
          _cardInfo = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur backend: $e');
      // En cas d'erreur, sortir du chargement aussi
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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

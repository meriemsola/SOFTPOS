import 'package:flutter/material.dart';
import 'package:hce_emv/presentation/screens/credit_card_widget.dart';
import 'package:hce_emv/presentation/screens/qr_code_scanner_screen.dart'; // Importer la page du QR scanner

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final examplePan = '1234567812345678';
    final exampleExpiry = '1225';
    final exampleCvv = '123';
    final exampleName = 'Sabrina 💙';

    return Scaffold(
      appBar: AppBar(title: const Text("HB Technologies Pay")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Affichage de la carte
            CreditCardWidget(
              maskedPan: examplePan,
              expiryDate: exampleExpiry,
              cvv: exampleCvv,
              cardHolderName: exampleName,
            ),
            const SizedBox(height: 30),

            // Le bouton "Payer"
            ElevatedButton.icon(
              onPressed: () {
                _showPaymentOptions(context);
              },
              icon: const Icon(Icons.payment),
              label: const Text("Payer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour afficher la petite fenêtre de choix entre NFC ou QR Code
  void _showPaymentOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choisissez un mode de paiement"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.qr_code, color: Colors.indigo),
                title: const Text("Payer par QR Code"),
                onTap: () {
                  // Logique pour payer avec QR Code
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              QRCodeScannerScreen(), // Ouvre la page du scanner QR Code
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.nfc, color: Colors.indigo),
                title: const Text("Payer par NFC"),
                onTap: () {
                  // Logique pour payer avec NFC
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Paiement via NFC")),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

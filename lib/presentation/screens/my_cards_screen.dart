import 'package:flutter/material.dart';
import 'package:hce_emv/presentation/screens/credit_card_widget.dart';

class MyCardsScreen extends StatelessWidget {
  const MyCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final examplePan = '1234567812345678';
    final exampleExpiry = '1225';
    final exampleCvv = '123';
    final exampleName = 'Sabrina 💙';

    return Scaffold(
      appBar: AppBar(title: const Text("Mes Cartes")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Affichage de la carte unique
            CreditCardWidget(
              maskedPan: examplePan,
              expiryDate: exampleExpiry,
              cvv: exampleCvv,
              cardHolderName: exampleName,
            ),
            const SizedBox(height: 30),
            // Ajouter une nouvelle carte (seulement une fois)
            GestureDetector(
              onTap: () {
                // Logique pour ajouter une carte
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Ajouter une nouvelle carte")),
                );
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.indigo, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.add, size: 60, color: Colors.indigo),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

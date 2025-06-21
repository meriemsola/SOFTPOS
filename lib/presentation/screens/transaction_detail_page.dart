import 'package:flutter/material.dart';
import 'package:hce_emv/features/Softpos/models/transaction_log_model.dart';
import 'package:hce_emv/presentation/screens/receipt_screen.dart';


class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tx = ModalRoute.of(context)?.settings.arguments as TransactionLog?;

    if (tx == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail de la Transaction')),
        body: const Center(child: Text('Aucune donnée disponible')),
      );
    }

    final isSuccess = tx.status.toLowerCase().contains('acceptée') ||
        tx.status.toLowerCase().contains('approuvée');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la Transaction'),
        centerTitle: true,
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                isSuccess ? Icons.check_circle : Icons.cancel,
                size: 80,
                color: isSuccess ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('PAN', '****-${tx.pan.substring(tx.pan.length - 4)}'),
                    _buildInfoRow('Date', tx.dateTime),
                    _buildInfoRow('Montant', '${tx.amount.toStringAsFixed(2)} DA'),
                    _buildInfoRow('ATC', tx.atc),
                    _buildInfoRow('Statut', tx.status),
                    _buildInfoRow('Expiration', tx.expiration),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.receipt_long),
                label: const Text('Voir le reçu'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReceiptScreen(
                        pan: tx.pan,
                        expiration: tx.expiration,
                        name: '',
                        atc: tx.atc,
                        status: tx.status,
                        amount: tx.amount.toStringAsFixed(2),
                        transactionReference: 'TRN${tx.timestamp.millisecondsSinceEpoch}',
                        authorizationCode: 'AUTH1234',
                        dateTime: tx.dateTime,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label :',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
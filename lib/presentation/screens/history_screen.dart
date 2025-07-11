import 'package:flutter/material.dart';
import 'package:hce_emv/features/Softpos/models/transaction_log_model.dart';
import 'package:hce_emv/features/Softpos/transaction_storage.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<TransactionLog> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      print('📌 Chargement des transactions pour HistoryScreen');
      final data = await TransactionStorage.loadTransactions();
      setState(() {
        transactions = data.reversed.toList();
      });
    } catch (e) {
      print('❌ Erreur lors du chargement des transactions : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du chargement de l\'historique')),
      );
    }
  }

  Future<void> _clearHistory() async {
    try {
      await TransactionStorage.clearTransactions();
      setState(() {
        transactions.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Historique effacé avec succès')),
      );
    } catch (e) {
      print('❌ Erreur lors de la suppression de l\'historique : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression de l\'historique')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Effacer l’historique',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmer la suppression'),
                  content: const Text('Voulez-vous effacer tout l’historique des transactions ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () {
                        _clearHistory();
                        Navigator.pop(context);
                      },
                      child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: transactions.isEmpty
          ? const Center(
              child: Text(
                'Aucune transaction disponible',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadTransactions,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  final isSuccess = tx.status.toLowerCase().contains('acceptée') ||
                      tx.status.toLowerCase().contains('approuvée');

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSuccess ? Colors.green : Colors.red,
                        child: Icon(
                          isSuccess ? Icons.check : Icons.close,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        '${tx.amount.toStringAsFixed(2)} DA',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Carte: ****-${tx.pan.substring(tx.pan.length - 4)}\nDate: ${tx.dateTime}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Vérifie si la route '/transactionDetail' existe dans ton projet
                        try {
                          Navigator.pushNamed(
                            context,
                            '/transactionDetail',
                            arguments: tx,
                          );
                        } catch (e) {
                          print('❌ Erreur de navigation vers transactionDetail : $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Page de détails non disponible')),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
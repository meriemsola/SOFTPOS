import 'package:hce_emv/features/Softpos/models/transaction_log_model.dart';
import 'package:hce_emv/features/Softpos/core/backend_service.dart';
import 'package:workmanager/workmanager.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

const String sendOfflineTransactionTask = 'sendOfflineTransaction';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == sendOfflineTransactionTask) {
      print('📌 Exécution de la tâche d’envoi d’une transaction hors ligne');
      try {
        // Récupérer les données de la transaction depuis inputData
        final transactionData = inputData?['transactionData'] as String?;
        final ac = inputData?['ac'] as String?;
        final panSequenceNumber = inputData?['panSequenceNumber'] as String?;
        final unpredictableNumber = inputData?['unpredictableNumber'] as String?;

        if (transactionData == null || ac == null || panSequenceNumber == null || unpredictableNumber == null) {
          print('❌ Données manquantes dans inputData');
          return false;
        }

        // Décoder les données JSON
        final Map<String, dynamic> transactionJson = jsonDecode(transactionData);
        final transaction = TransactionLog(
          pan: transactionJson['pan'],
          expiration: transactionJson['expiration'],
          atc: transactionJson['atc'],
          result: transactionJson['result'],
          timestamp: DateTime.parse(transactionJson['timestamp']),
          amount: transactionJson['amount'],
          dateTime: transactionJson['dateTime'],
          status: transactionJson['status'],
          isOnline: transactionJson['isOnline'],
        );

        if (!transaction.isOnline) {
          print('📌 Envoi de la transaction hors ligne : ${transaction.pan}');

          final backendResult = await sendToBackend(
            pan: transaction.pan,
            panSequenceNumber: panSequenceNumber,
            amountAuthorised: (transaction.amount * 100).toInt().toRadixString(16).padLeft(12, '0').toUpperCase(),
            amountOther: '000000000003',
            expiryDate: transaction.expiration,
            ac: ac,
            atc: transaction.atc,
            cid: '40', // TC pour transactions hors ligne
            issuerApplicationData: null,
            terminalCountryCode: '0250', // France
            tvr: '0000000000',
            transactionCurrencyCode: '0978', // EUR
            transactionDate: DateFormat('yyMMdd').format(DateTime.parse(transaction.dateTime)),
            transactionType: '00',
            unpredictableNumber: unpredictableNumber,
            aip: '1C00',
          );

          if (backendResult != null) {
            print('✅ Transaction hors ligne envoyée avec succès : ${transaction.pan}');
          } else {
            print('❌ Échec de l’envoi de la transaction hors ligne : ${transaction.pan}');
            return false;
          }
        } else {
          print('❌ Transaction est en ligne, aucune action requise');
        }
      } catch (e) {
        print('❌ Erreur lors de l’envoi de la transaction hors ligne : $e');
        return false;
      }
    }
    return Future.value(true);
  });
}

class OfflineTransactionScheduler {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (!_isInitialized) {
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
      _isInitialized = true;
      print('📌 Workmanager initialisé pour les transactions hors ligne');
    }
  }

  static Future<void> scheduleOfflineTransactionSend({
    required TransactionLog transaction,
    required String ac,
    required String panSequenceNumber,
    required String unpredictableNumber,
  }) async {
    await initialize();
    if (transaction.isOnline) {
      print('📌 Transaction en ligne, aucun envoi différé requis');
      return;
    }

    final transactionTime = DateTime.parse(transaction.dateTime);
    final sendTime = transactionTime.add(const Duration(hours: 24));
    final now = DateTime.now();
    final initialDelay = sendTime.isAfter(now) ? sendTime.difference(now) : Duration.zero;

    // Générer un taskId unique basé sur pan, atc, et dateTime
    final taskId = 'send_offline_${transaction.pan}_${transaction.atc}_${transaction.dateTime.hashCode}';
    print('📌 Planification de l’envoi de la transaction ${transaction.pan} dans ${initialDelay.inSeconds} secondes');

    // Sérialiser la transaction en JSON pour inputData
    final transactionData = jsonEncode({
      'pan': transaction.pan,
      'expiration': transaction.expiration,
      'atc': transaction.atc,
      'result': transaction.result,
      'timestamp': transaction.timestamp.toIso8601String(),
      'amount': transaction.amount,
      'dateTime': transaction.dateTime,
      'status': transaction.status,
      'isOnline': transaction.isOnline,
    });

    await Workmanager().registerOneOffTask(
      taskId,
      sendOfflineTransactionTask,
      initialDelay: initialDelay,
      inputData: {
        'transactionData': transactionData,
        'ac': ac,
        'panSequenceNumber': panSequenceNumber,
        'unpredictableNumber': unpredictableNumber,
      },
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );

    print('📌 Tâche d’envoi différé planifiée pour la transaction ${transaction.pan} à ${sendTime.toIso8601String()}');
  }
}
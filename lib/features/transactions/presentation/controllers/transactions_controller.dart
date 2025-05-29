// lib/features/transactions/presentation/controllers/transactions_controller.dart
import 'package:hce_emv/features/transactions/application/transaction_service.dart';
import 'package:hce_emv/features/transactions/domain/models/transaction.dart';
import 'package:hce_emv/features/transactions/domain/models/transaction_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transactions_controller.g.dart';

@riverpod
class TransactionsController extends _$TransactionsController {
  @override
  Future<List<Transaction>> build() async {
    state = const AsyncLoading();
    final transactions = await AsyncValue.guard(() async {
      final result =
          await ref.read(transactionServiceProvider).getTransactions();
      return result.fold(
        (error) => throw error,
        (transactions) => transactions,
      );
    });
    state = transactions;
    return transactions.valueOrNull ?? [];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result =
          await ref.read(transactionServiceProvider).getTransactions();
      return result.fold(
        (error) => throw error,
        (transactions) => transactions,
      );
    });
  }
}

final transactionArticlesProvider =
    FutureProvider.family<List<TransactionItem>, int>((
      ref,
      transactionId,
    ) async {
      final result = await ref
          .read(transactionServiceProvider)
          .getTransactionArticles(transactionId);
      return result.fold((error) => throw error, (items) => items);
    });

// lib/features/transactions/application/transaction_service.dart
import 'package:hce_emv/features/transactions/domain/models/transaction.dart';
import 'package:hce_emv/features/transactions/domain/models/transaction_item.dart';
import 'package:hce_emv/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_service.g.dart';

@riverpod
TransactionService transactionService(Ref ref) =>
    TransactionService(ref.watch(transactionRepositoryProvider));

class TransactionService {
  final TransactionRepository _repository;

  TransactionService(this._repository);

  Future<Either<String, List<Transaction>>> getTransactions() {
    return _repository.getTransactions();
  }

  Future<Either<String, List<TransactionItem>>> getTransactionArticles(
    int transactionId,
  ) {
    return _repository.getTransactionArticles(transactionId);
  }
}

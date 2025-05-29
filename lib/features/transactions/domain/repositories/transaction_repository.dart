// lib/features/transactions/domain/repositories/transaction_repository.dart
import 'package:hce_emv/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:hce_emv/features/transactions/data/sources/transaction_client.dart';
import 'package:hce_emv/features/transactions/domain/models/transaction.dart';
import 'package:hce_emv/features/transactions/domain/models/transaction_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_repository.g.dart';

@riverpod
TransactionRepository transactionRepository(Ref ref) =>
    TransactionRepositoryImpl(ref.watch(transactionClientProvider));

abstract class TransactionRepository {
  Future<Either<String, List<Transaction>>> getTransactions();
  Future<Either<String, List<TransactionItem>>> getTransactionArticles(
    int transactionId,
  );
}

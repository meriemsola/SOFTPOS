// lib/features/transactions/data/repositories/transaction_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:hce_emv/core/network/network_interceptor.dart';
import 'package:hce_emv/features/transactions/data/sources/transaction_client.dart';
import 'package:hce_emv/features/transactions/domain/models/transaction.dart';
import 'package:hce_emv/features/transactions/domain/models/transaction_item.dart';
import 'package:hce_emv/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_repository_impl.g.dart';

@riverpod
TransactionRepository transactionRepository(Ref ref) =>
    TransactionRepositoryImpl(ref.watch(transactionClientProvider));

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionClient _transactionClient;

  TransactionRepositoryImpl(this._transactionClient);

  @override
  Future<Either<String, List<Transaction>>> getTransactions() async {
    try {
      final response = await _transactionClient.getTransactions();
      if (response.status == 'success' && response.data != null) {
        return right(response.data!);
      }
      return left(response.message);
    } on DioException catch (e) {
      final errorMessage = DioErrorHandler.handleError(e);
      return left(errorMessage);
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, List<TransactionItem>>> getTransactionArticles(
    int transactionId,
  ) async {
    try {
      final response = await _transactionClient.getTransactionArticles(
        transactionId,
      );
      if (response.status == 'success' && response.data != null) {
        return right(response.data!);
      }
      return left(response.message);
    } on DioException catch (e) {
      final errorMessage = DioErrorHandler.handleError(e);
      return left(errorMessage);
    } catch (e) {
      return left(e.toString());
    }
  }
}

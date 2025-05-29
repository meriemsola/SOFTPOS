// lib/features/transactions/data/sources/transaction_client.dart
import 'package:hce_emv/core/network/api_client.dart';
import 'package:hce_emv/core/network/api_endpoints.dart';
import 'package:hce_emv/core/network/api_response.dart';
import 'package:hce_emv/features/transactions/domain/models/transaction.dart';
import 'package:hce_emv/features/transactions/domain/models/transaction_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_client.g.dart';

@riverpod
TransactionClient transactionClient(Ref ref) =>
    TransactionClient(ref.watch(apiClientProvider));

class TransactionClient {
  final ApiClient _apiClient;

  TransactionClient(this._apiClient);

  Future<ApiResponse<List<Transaction>>> getTransactions() async {
    return _apiClient.get<List<Transaction>>(
      '/api/transactions/me',
      fromJson: (json) {
        if (json is List) {
          return json
              .map((item) => Transaction.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw FormatException('Expected List, got ${json.runtimeType}');
        }
      },
    );
  }

  Future<ApiResponse<List<TransactionItem>>> getTransactionArticles(
    int transactionId,
  ) async {
    return _apiClient.get<List<TransactionItem>>(
      ApiEndpoints.getTransactionArticles(transactionId.toString()),
      fromJson: (json) {
        if (json is List) {
          return json
              .map(
                (item) =>
                    TransactionItem.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw FormatException('Expected List, got \\${json.runtimeType}');
        }
      },
    );
  }
}

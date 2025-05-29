import 'package:hce_emv/core/network/api_client.dart';
import 'package:hce_emv/core/network/api_endpoints.dart';
import 'package:hce_emv/core/network/api_response.dart';
import 'package:hce_emv/features/articles/domain/models/checkout_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_client.g.dart';

@riverpod
CartClient cartClient(Ref ref) => CartClient(ref.watch(apiClientProvider));

class CartClient {
  final ApiClient _apiClient;

  CartClient(this._apiClient);

  Future<ApiResponse<Map<String, dynamic>>> checkoutCart(
    CheckoutRequest request,
  ) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.checkoutCart,
      data: request.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}

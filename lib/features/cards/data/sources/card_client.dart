// lib/features/cards/data/datasources/card_client.dart
import 'package:hce_emv/core/network/api_client.dart';
import 'package:hce_emv/core/network/api_endpoints.dart';
import 'package:hce_emv/core/network/api_response.dart';
import 'package:hce_emv/features/cards/domain/models/card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'card_client.g.dart';

@riverpod
CardClient cardClient(Ref ref) => CardClient(ref.watch(apiClientProvider));

class CardClient {
  final ApiClient _apiClient;
  CardClient(this._apiClient);

  Future<ApiResponse<Card>> createCard() async {
    return _apiClient.post<Card>(
      ApiEndpoints.createCard,
      fromJson: (json) => Card.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<Card>> getCard() async {
    return _apiClient.get<Card>(
      ApiEndpoints.getCard,
      fromJson: (json) => Card.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<bool>> validateCard(
    String pan,
    String cvv,
    String expiryDate,
  ) async {
    return _apiClient.post<bool>(
      ApiEndpoints.validateCard,
      data: {'pan': pan, 'cvv': cvv, 'expiryDate': expiryDate},
      fromJson: (json) => (json as Map<String, dynamic>)['status'] == 'success',
    );
  }
}

// lib/features/cards/data/repositories/card_repository_impl.dart
import 'package:hce_emv/core/network/network_interceptor.dart';
import 'package:hce_emv/features/cards/data/sources/card_client.dart';
import 'package:hce_emv/features/cards/domain/models/card.dart';
import 'package:hce_emv/features/cards/domain/repositories/card_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';

class CardRepositoryImpl implements CardRepository {
  final CardClient _cardClient;
  CardRepositoryImpl(this._cardClient);

  @override
  Future<Either<String, Card>> createCard() async {
    try {
      final response = await _cardClient.createCard();
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
  Future<Either<String, Card>> getCard() async {
    try {
      final response = await _cardClient.getCard();
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
  Future<Either<String, bool>> validateCard(
    String pan,
    String cvv,
    String expiryDate,
  ) async {
    try {
      final response = await _cardClient.validateCard(pan, cvv, expiryDate);
      if (response.status == 'success') {
        return right(true);
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

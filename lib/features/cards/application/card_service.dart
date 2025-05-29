// lib/features/cards/application/card_service.dart
import 'package:hce_emv/features/cards/domain/models/card.dart';
import 'package:hce_emv/features/cards/domain/repositories/card_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_service.g.dart';

@riverpod
CardService cardService(Ref ref) =>
    CardService(ref.watch(cardRepositoryProvider));

class CardService {
  final CardRepository _repository;

  CardService(this._repository);

  Future<Either<String, Card>> createCard() {
    return _repository.createCard();
  }

  Future<Either<String, Card>> getCard() {
    return _repository.getCard();
  }

  Future<Either<String, bool>> validateCard(
    String pan,
    String cvv,
    String expiryDate,
  ) {
    return _repository.validateCard(pan, cvv, expiryDate);
  }
}

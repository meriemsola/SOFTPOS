import 'package:hce_emv/features/cards/data/repositories/card_repository_impl.dart';
import 'package:hce_emv/features/cards/data/sources/card_client.dart';
import 'package:hce_emv/features/cards/domain/models/card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_repository.g.dart';

@riverpod
CardRepository cardRepository(Ref ref) =>
    CardRepositoryImpl(ref.watch(cardClientProvider));

abstract class CardRepository {
  Future<Either<String, Card>> createCard();
  Future<Either<String, Card>> getCard();
  Future<Either<String, bool>> validateCard(
    String pan,
    String cvv,
    String expiryDate,
  );
}

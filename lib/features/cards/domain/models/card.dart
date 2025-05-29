// lib/features/cards/domain/models/card_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'card.freezed.dart';
part 'card.g.dart';


@freezed
abstract class Card with _$Card {
  const factory Card({
    required int id,
    required String pan,
    required String panToken,
    required String cvv,
    required DateTime createdAt,
    required DateTime expiryDate,
    int? accountId,
  }) = _Card;

  factory Card.fromJson(Map<String, dynamic> json) => _$CardFromJson(json);
}
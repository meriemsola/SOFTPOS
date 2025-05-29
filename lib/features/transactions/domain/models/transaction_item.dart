import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hce_emv/features/articles/domain/models/article.dart';

part 'transaction_item.freezed.dart';
part 'transaction_item.g.dart';

@freezed
abstract class TransactionItem with _$TransactionItem {
  const factory TransactionItem({
    required int id,
    required Article article,
    required int quantity,
  }) = _TransactionItem;

  factory TransactionItem.fromJson(Map<String, dynamic> json) =>
      _$TransactionItemFromJson(json);
}

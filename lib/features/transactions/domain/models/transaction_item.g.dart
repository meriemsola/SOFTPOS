// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionItem _$TransactionItemFromJson(Map<String, dynamic> json) =>
    _TransactionItem(
      id: (json['id'] as num).toInt(),
      article: Article.fromJson(json['article'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$TransactionItemToJson(_TransactionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'article': instance.article,
      'quantity': instance.quantity,
    };

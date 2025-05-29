// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Account _$AccountFromJson(Map<String, dynamic> json) => _Account(
  id: (json['id'] as num).toInt(),
  accountNumber: json['accountNumber'] as String,
  balance: (json['balance'] as num).toDouble(),
  userId: (json['userId'] as num).toInt(),
  cardId: (json['cardId'] as num?)?.toInt(),
);

Map<String, dynamic> _$AccountToJson(_Account instance) => <String, dynamic>{
  'id': instance.id,
  'accountNumber': instance.accountNumber,
  'balance': instance.balance,
  'userId': instance.userId,
  'cardId': instance.cardId,
};

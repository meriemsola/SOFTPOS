// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Transaction _$TransactionFromJson(Map<String, dynamic> json) => _Transaction(
  id: (json['id'] as num).toInt(),
  amount: (json['amount'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  referenceNumber: json['referenceNumber'] as String,
  authorizationCode: json['authorizationCode'] as String?,
  responseCode: json['responseCode'] as String?,
  pan: json['pan'] as String?,
  userId: (json['userId'] as num).toInt(),
);

Map<String, dynamic> _$TransactionToJson(_Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'timestamp': instance.timestamp.toIso8601String(),
      'referenceNumber': instance.referenceNumber,
      'authorizationCode': instance.authorizationCode,
      'responseCode': instance.responseCode,
      'pan': instance.pan,
      'userId': instance.userId,
    };

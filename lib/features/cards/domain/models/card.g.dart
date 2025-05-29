// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Card _$CardFromJson(Map<String, dynamic> json) => _Card(
  id: (json['id'] as num).toInt(),
  pan: json['pan'] as String,
  panToken: json['panToken'] as String,
  cvv: json['cvv'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  expiryDate: DateTime.parse(json['expiryDate'] as String),
  accountId: (json['accountId'] as num?)?.toInt(),
);

Map<String, dynamic> _$CardToJson(_Card instance) => <String, dynamic>{
  'id': instance.id,
  'pan': instance.pan,
  'panToken': instance.panToken,
  'cvv': instance.cvv,
  'createdAt': instance.createdAt.toIso8601String(),
  'expiryDate': instance.expiryDate.toIso8601String(),
  'accountId': instance.accountId,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Reward _$RewardFromJson(Map<String, dynamic> json) => _Reward(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  pointsRequired: (json['pointsRequired'] as num).toInt(),
  category: json['category'] as String,
  available: json['available'] as bool,
);

Map<String, dynamic> _$RewardToJson(_Reward instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'pointsRequired': instance.pointsRequired,
  'category': instance.category,
  'available': instance.available,
};

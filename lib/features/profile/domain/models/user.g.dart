// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  email: json['email'] as String,
  enabled: json['enabled'] as bool? ?? false,
  loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt() ?? 0,
  role: $enumDecodeNullable(_$RoleEnumMap, json['role']) ?? Role.USER,
  authProvider:
      $enumDecodeNullable(_$AuthProviderEnumMap, json['authProvider']) ??
      AuthProvider.LOCAL,
  pointsExpirationDate:
      json['pointsExpirationDate'] == null
          ? null
          : DateTime.parse(json['pointsExpirationDate'] as String),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'enabled': instance.enabled,
  'loyaltyPoints': instance.loyaltyPoints,
  'role': _$RoleEnumMap[instance.role]!,
  'authProvider': _$AuthProviderEnumMap[instance.authProvider]!,
  'pointsExpirationDate': instance.pointsExpirationDate?.toIso8601String(),
};

const _$RoleEnumMap = {Role.USER: 'USER', Role.ADMIN: 'ADMIN'};

const _$AuthProviderEnumMap = {
  AuthProvider.LOCAL: 'LOCAL',
  AuthProvider.OAuth2: 'OAuth2',
};

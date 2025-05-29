// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) =>
    _AuthResponse(
      token: json['token'] as String,
      tokenExpiration: (json['tokenExpiration'] as num).toInt(),
      refreshToken: json['refreshToken'] as String,
      refreshTokenExpiration: (json['refreshTokenExpiration'] as num).toInt(),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseToJson(_AuthResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'tokenExpiration': instance.tokenExpiration,
      'refreshToken': instance.refreshToken,
      'refreshTokenExpiration': instance.refreshTokenExpiration,
      'user': instance.user,
    };

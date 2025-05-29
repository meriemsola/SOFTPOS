// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VerificationRequest _$VerificationRequestFromJson(Map<String, dynamic> json) =>
    _VerificationRequest(
      email: json['email'] as String,
      verificationCode: json['verificationCode'] as String,
    );

Map<String, dynamic> _$VerificationRequestToJson(
  _VerificationRequest instance,
) => <String, dynamic>{
  'email': instance.email,
  'verificationCode': instance.verificationCode,
};

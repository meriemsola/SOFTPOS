// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verification_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerificationRequest {

 String get email; String get verificationCode;
/// Create a copy of VerificationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationRequestCopyWith<VerificationRequest> get copyWith => _$VerificationRequestCopyWithImpl<VerificationRequest>(this as VerificationRequest, _$identity);

  /// Serializes this VerificationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationRequest&&(identical(other.email, email) || other.email == email)&&(identical(other.verificationCode, verificationCode) || other.verificationCode == verificationCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,verificationCode);

@override
String toString() {
  return 'VerificationRequest(email: $email, verificationCode: $verificationCode)';
}


}

/// @nodoc
abstract mixin class $VerificationRequestCopyWith<$Res>  {
  factory $VerificationRequestCopyWith(VerificationRequest value, $Res Function(VerificationRequest) _then) = _$VerificationRequestCopyWithImpl;
@useResult
$Res call({
 String email, String verificationCode
});




}
/// @nodoc
class _$VerificationRequestCopyWithImpl<$Res>
    implements $VerificationRequestCopyWith<$Res> {
  _$VerificationRequestCopyWithImpl(this._self, this._then);

  final VerificationRequest _self;
  final $Res Function(VerificationRequest) _then;

/// Create a copy of VerificationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? verificationCode = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,verificationCode: null == verificationCode ? _self.verificationCode : verificationCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _VerificationRequest implements VerificationRequest {
  const _VerificationRequest({required this.email, required this.verificationCode});
  factory _VerificationRequest.fromJson(Map<String, dynamic> json) => _$VerificationRequestFromJson(json);

@override final  String email;
@override final  String verificationCode;

/// Create a copy of VerificationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerificationRequestCopyWith<_VerificationRequest> get copyWith => __$VerificationRequestCopyWithImpl<_VerificationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerificationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationRequest&&(identical(other.email, email) || other.email == email)&&(identical(other.verificationCode, verificationCode) || other.verificationCode == verificationCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,verificationCode);

@override
String toString() {
  return 'VerificationRequest(email: $email, verificationCode: $verificationCode)';
}


}

/// @nodoc
abstract mixin class _$VerificationRequestCopyWith<$Res> implements $VerificationRequestCopyWith<$Res> {
  factory _$VerificationRequestCopyWith(_VerificationRequest value, $Res Function(_VerificationRequest) _then) = __$VerificationRequestCopyWithImpl;
@override @useResult
$Res call({
 String email, String verificationCode
});




}
/// @nodoc
class __$VerificationRequestCopyWithImpl<$Res>
    implements _$VerificationRequestCopyWith<$Res> {
  __$VerificationRequestCopyWithImpl(this._self, this._then);

  final _VerificationRequest _self;
  final $Res Function(_VerificationRequest) _then;

/// Create a copy of VerificationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? verificationCode = null,}) {
  return _then(_VerificationRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,verificationCode: null == verificationCode ? _self.verificationCode : verificationCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

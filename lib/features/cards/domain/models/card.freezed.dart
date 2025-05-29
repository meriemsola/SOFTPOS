// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Card {

 int get id; String get pan; String get panToken; String get cvv; DateTime get createdAt; DateTime get expiryDate; int? get accountId;
/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardCopyWith<Card> get copyWith => _$CardCopyWithImpl<Card>(this as Card, _$identity);

  /// Serializes this Card to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Card&&(identical(other.id, id) || other.id == id)&&(identical(other.pan, pan) || other.pan == pan)&&(identical(other.panToken, panToken) || other.panToken == panToken)&&(identical(other.cvv, cvv) || other.cvv == cvv)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.accountId, accountId) || other.accountId == accountId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pan,panToken,cvv,createdAt,expiryDate,accountId);

@override
String toString() {
  return 'Card(id: $id, pan: $pan, panToken: $panToken, cvv: $cvv, createdAt: $createdAt, expiryDate: $expiryDate, accountId: $accountId)';
}


}

/// @nodoc
abstract mixin class $CardCopyWith<$Res>  {
  factory $CardCopyWith(Card value, $Res Function(Card) _then) = _$CardCopyWithImpl;
@useResult
$Res call({
 int id, String pan, String panToken, String cvv, DateTime createdAt, DateTime expiryDate, int? accountId
});




}
/// @nodoc
class _$CardCopyWithImpl<$Res>
    implements $CardCopyWith<$Res> {
  _$CardCopyWithImpl(this._self, this._then);

  final Card _self;
  final $Res Function(Card) _then;

/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? pan = null,Object? panToken = null,Object? cvv = null,Object? createdAt = null,Object? expiryDate = null,Object? accountId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,pan: null == pan ? _self.pan : pan // ignore: cast_nullable_to_non_nullable
as String,panToken: null == panToken ? _self.panToken : panToken // ignore: cast_nullable_to_non_nullable
as String,cvv: null == cvv ? _self.cvv : cvv // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiryDate: null == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Card implements Card {
  const _Card({required this.id, required this.pan, required this.panToken, required this.cvv, required this.createdAt, required this.expiryDate, this.accountId});
  factory _Card.fromJson(Map<String, dynamic> json) => _$CardFromJson(json);

@override final  int id;
@override final  String pan;
@override final  String panToken;
@override final  String cvv;
@override final  DateTime createdAt;
@override final  DateTime expiryDate;
@override final  int? accountId;

/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardCopyWith<_Card> get copyWith => __$CardCopyWithImpl<_Card>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Card&&(identical(other.id, id) || other.id == id)&&(identical(other.pan, pan) || other.pan == pan)&&(identical(other.panToken, panToken) || other.panToken == panToken)&&(identical(other.cvv, cvv) || other.cvv == cvv)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.accountId, accountId) || other.accountId == accountId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,pan,panToken,cvv,createdAt,expiryDate,accountId);

@override
String toString() {
  return 'Card(id: $id, pan: $pan, panToken: $panToken, cvv: $cvv, createdAt: $createdAt, expiryDate: $expiryDate, accountId: $accountId)';
}


}

/// @nodoc
abstract mixin class _$CardCopyWith<$Res> implements $CardCopyWith<$Res> {
  factory _$CardCopyWith(_Card value, $Res Function(_Card) _then) = __$CardCopyWithImpl;
@override @useResult
$Res call({
 int id, String pan, String panToken, String cvv, DateTime createdAt, DateTime expiryDate, int? accountId
});




}
/// @nodoc
class __$CardCopyWithImpl<$Res>
    implements _$CardCopyWith<$Res> {
  __$CardCopyWithImpl(this._self, this._then);

  final _Card _self;
  final $Res Function(_Card) _then;

/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? pan = null,Object? panToken = null,Object? cvv = null,Object? createdAt = null,Object? expiryDate = null,Object? accountId = freezed,}) {
  return _then(_Card(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,pan: null == pan ? _self.pan : pan // ignore: cast_nullable_to_non_nullable
as String,panToken: null == panToken ? _self.panToken : panToken // ignore: cast_nullable_to_non_nullable
as String,cvv: null == cvv ? _self.cvv : cvv // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiryDate: null == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on

// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckoutRequest {

 List<CartItemRequest> get items; String? get pan; String? get expiryDate; String? get cvv; bool get usePoints;
/// Create a copy of CheckoutRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckoutRequestCopyWith<CheckoutRequest> get copyWith => _$CheckoutRequestCopyWithImpl<CheckoutRequest>(this as CheckoutRequest, _$identity);

  /// Serializes this CheckoutRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckoutRequest&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.pan, pan) || other.pan == pan)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.cvv, cvv) || other.cvv == cvv)&&(identical(other.usePoints, usePoints) || other.usePoints == usePoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),pan,expiryDate,cvv,usePoints);

@override
String toString() {
  return 'CheckoutRequest(items: $items, pan: $pan, expiryDate: $expiryDate, cvv: $cvv, usePoints: $usePoints)';
}


}

/// @nodoc
abstract mixin class $CheckoutRequestCopyWith<$Res>  {
  factory $CheckoutRequestCopyWith(CheckoutRequest value, $Res Function(CheckoutRequest) _then) = _$CheckoutRequestCopyWithImpl;
@useResult
$Res call({
 List<CartItemRequest> items, String? pan, String? expiryDate, String? cvv, bool usePoints
});




}
/// @nodoc
class _$CheckoutRequestCopyWithImpl<$Res>
    implements $CheckoutRequestCopyWith<$Res> {
  _$CheckoutRequestCopyWithImpl(this._self, this._then);

  final CheckoutRequest _self;
  final $Res Function(CheckoutRequest) _then;

/// Create a copy of CheckoutRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? pan = freezed,Object? expiryDate = freezed,Object? cvv = freezed,Object? usePoints = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CartItemRequest>,pan: freezed == pan ? _self.pan : pan // ignore: cast_nullable_to_non_nullable
as String?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as String?,cvv: freezed == cvv ? _self.cvv : cvv // ignore: cast_nullable_to_non_nullable
as String?,usePoints: null == usePoints ? _self.usePoints : usePoints // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _CheckoutRequest implements CheckoutRequest {
  const _CheckoutRequest({required final  List<CartItemRequest> items, this.pan, this.expiryDate, this.cvv, this.usePoints = false}): _items = items;
  factory _CheckoutRequest.fromJson(Map<String, dynamic> json) => _$CheckoutRequestFromJson(json);

 final  List<CartItemRequest> _items;
@override List<CartItemRequest> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? pan;
@override final  String? expiryDate;
@override final  String? cvv;
@override@JsonKey() final  bool usePoints;

/// Create a copy of CheckoutRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckoutRequestCopyWith<_CheckoutRequest> get copyWith => __$CheckoutRequestCopyWithImpl<_CheckoutRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckoutRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckoutRequest&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.pan, pan) || other.pan == pan)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.cvv, cvv) || other.cvv == cvv)&&(identical(other.usePoints, usePoints) || other.usePoints == usePoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),pan,expiryDate,cvv,usePoints);

@override
String toString() {
  return 'CheckoutRequest(items: $items, pan: $pan, expiryDate: $expiryDate, cvv: $cvv, usePoints: $usePoints)';
}


}

/// @nodoc
abstract mixin class _$CheckoutRequestCopyWith<$Res> implements $CheckoutRequestCopyWith<$Res> {
  factory _$CheckoutRequestCopyWith(_CheckoutRequest value, $Res Function(_CheckoutRequest) _then) = __$CheckoutRequestCopyWithImpl;
@override @useResult
$Res call({
 List<CartItemRequest> items, String? pan, String? expiryDate, String? cvv, bool usePoints
});




}
/// @nodoc
class __$CheckoutRequestCopyWithImpl<$Res>
    implements _$CheckoutRequestCopyWith<$Res> {
  __$CheckoutRequestCopyWithImpl(this._self, this._then);

  final _CheckoutRequest _self;
  final $Res Function(_CheckoutRequest) _then;

/// Create a copy of CheckoutRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? pan = freezed,Object? expiryDate = freezed,Object? cvv = freezed,Object? usePoints = null,}) {
  return _then(_CheckoutRequest(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CartItemRequest>,pan: freezed == pan ? _self.pan : pan // ignore: cast_nullable_to_non_nullable
as String?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as String?,cvv: freezed == cvv ? _self.cvv : cvv // ignore: cast_nullable_to_non_nullable
as String?,usePoints: null == usePoints ? _self.usePoints : usePoints // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CartItemRequest {

 int get articleId; int get quantity;
/// Create a copy of CartItemRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartItemRequestCopyWith<CartItemRequest> get copyWith => _$CartItemRequestCopyWithImpl<CartItemRequest>(this as CartItemRequest, _$identity);

  /// Serializes this CartItemRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartItemRequest&&(identical(other.articleId, articleId) || other.articleId == articleId)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,articleId,quantity);

@override
String toString() {
  return 'CartItemRequest(articleId: $articleId, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $CartItemRequestCopyWith<$Res>  {
  factory $CartItemRequestCopyWith(CartItemRequest value, $Res Function(CartItemRequest) _then) = _$CartItemRequestCopyWithImpl;
@useResult
$Res call({
 int articleId, int quantity
});




}
/// @nodoc
class _$CartItemRequestCopyWithImpl<$Res>
    implements $CartItemRequestCopyWith<$Res> {
  _$CartItemRequestCopyWithImpl(this._self, this._then);

  final CartItemRequest _self;
  final $Res Function(CartItemRequest) _then;

/// Create a copy of CartItemRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? articleId = null,Object? quantity = null,}) {
  return _then(_self.copyWith(
articleId: null == articleId ? _self.articleId : articleId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _CartItemRequest implements CartItemRequest {
  const _CartItemRequest({required this.articleId, required this.quantity});
  factory _CartItemRequest.fromJson(Map<String, dynamic> json) => _$CartItemRequestFromJson(json);

@override final  int articleId;
@override final  int quantity;

/// Create a copy of CartItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartItemRequestCopyWith<_CartItemRequest> get copyWith => __$CartItemRequestCopyWithImpl<_CartItemRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartItemRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartItemRequest&&(identical(other.articleId, articleId) || other.articleId == articleId)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,articleId,quantity);

@override
String toString() {
  return 'CartItemRequest(articleId: $articleId, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$CartItemRequestCopyWith<$Res> implements $CartItemRequestCopyWith<$Res> {
  factory _$CartItemRequestCopyWith(_CartItemRequest value, $Res Function(_CartItemRequest) _then) = __$CartItemRequestCopyWithImpl;
@override @useResult
$Res call({
 int articleId, int quantity
});




}
/// @nodoc
class __$CartItemRequestCopyWithImpl<$Res>
    implements _$CartItemRequestCopyWith<$Res> {
  __$CartItemRequestCopyWithImpl(this._self, this._then);

  final _CartItemRequest _self;
  final $Res Function(_CartItemRequest) _then;

/// Create a copy of CartItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? articleId = null,Object? quantity = null,}) {
  return _then(_CartItemRequest(
articleId: null == articleId ? _self.articleId : articleId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

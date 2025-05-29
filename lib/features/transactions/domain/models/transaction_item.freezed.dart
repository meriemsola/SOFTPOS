// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionItem {

 int get id; Article get article; int get quantity;
/// Create a copy of TransactionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionItemCopyWith<TransactionItem> get copyWith => _$TransactionItemCopyWithImpl<TransactionItem>(this as TransactionItem, _$identity);

  /// Serializes this TransactionItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionItem&&(identical(other.id, id) || other.id == id)&&(identical(other.article, article) || other.article == article)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,article,quantity);

@override
String toString() {
  return 'TransactionItem(id: $id, article: $article, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $TransactionItemCopyWith<$Res>  {
  factory $TransactionItemCopyWith(TransactionItem value, $Res Function(TransactionItem) _then) = _$TransactionItemCopyWithImpl;
@useResult
$Res call({
 int id, Article article, int quantity
});


$ArticleCopyWith<$Res> get article;

}
/// @nodoc
class _$TransactionItemCopyWithImpl<$Res>
    implements $TransactionItemCopyWith<$Res> {
  _$TransactionItemCopyWithImpl(this._self, this._then);

  final TransactionItem _self;
  final $Res Function(TransactionItem) _then;

/// Create a copy of TransactionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? article = null,Object? quantity = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,article: null == article ? _self.article : article // ignore: cast_nullable_to_non_nullable
as Article,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of TransactionItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ArticleCopyWith<$Res> get article {
  
  return $ArticleCopyWith<$Res>(_self.article, (value) {
    return _then(_self.copyWith(article: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _TransactionItem implements TransactionItem {
  const _TransactionItem({required this.id, required this.article, required this.quantity});
  factory _TransactionItem.fromJson(Map<String, dynamic> json) => _$TransactionItemFromJson(json);

@override final  int id;
@override final  Article article;
@override final  int quantity;

/// Create a copy of TransactionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionItemCopyWith<_TransactionItem> get copyWith => __$TransactionItemCopyWithImpl<_TransactionItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionItem&&(identical(other.id, id) || other.id == id)&&(identical(other.article, article) || other.article == article)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,article,quantity);

@override
String toString() {
  return 'TransactionItem(id: $id, article: $article, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$TransactionItemCopyWith<$Res> implements $TransactionItemCopyWith<$Res> {
  factory _$TransactionItemCopyWith(_TransactionItem value, $Res Function(_TransactionItem) _then) = __$TransactionItemCopyWithImpl;
@override @useResult
$Res call({
 int id, Article article, int quantity
});


@override $ArticleCopyWith<$Res> get article;

}
/// @nodoc
class __$TransactionItemCopyWithImpl<$Res>
    implements _$TransactionItemCopyWith<$Res> {
  __$TransactionItemCopyWithImpl(this._self, this._then);

  final _TransactionItem _self;
  final $Res Function(_TransactionItem) _then;

/// Create a copy of TransactionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? article = null,Object? quantity = null,}) {
  return _then(_TransactionItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,article: null == article ? _self.article : article // ignore: cast_nullable_to_non_nullable
as Article,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of TransactionItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ArticleCopyWith<$Res> get article {
  
  return $ArticleCopyWith<$Res>(_self.article, (value) {
    return _then(_self.copyWith(article: value));
  });
}
}

// dart format on

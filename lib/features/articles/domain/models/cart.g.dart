// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartItem _$CartItemFromJson(Map<String, dynamic> json) => _CartItem(
  article: Article.fromJson(json['article'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$CartItemToJson(_CartItem instance) => <String, dynamic>{
  'article': instance.article,
  'quantity': instance.quantity,
};

_Cart _$CartFromJson(Map<String, dynamic> json) => _Cart(
  id: (json['id'] as num).toInt(),
  user:
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
  status:
      $enumDecodeNullable(_$CartStatusEnumMap, json['status']) ??
      CartStatus.active,
);

Map<String, dynamic> _$CartToJson(_Cart instance) => <String, dynamic>{
  'id': instance.id,
  'user': instance.user,
  'items': instance.items,
  'createdAt': instance.createdAt.toIso8601String(),
  'totalAmount': instance.totalAmount,
  'status': _$CartStatusEnumMap[instance.status]!,
};

const _$CartStatusEnumMap = {
  CartStatus.active: 'active',
  CartStatus.checkedOut: 'checkedOut',
  CartStatus.completed: 'completed',
  CartStatus.cancelled: 'cancelled',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CheckoutRequest _$CheckoutRequestFromJson(Map<String, dynamic> json) =>
    _CheckoutRequest(
      items:
          (json['items'] as List<dynamic>)
              .map((e) => CartItemRequest.fromJson(e as Map<String, dynamic>))
              .toList(),
      pan: json['pan'] as String?,
      expiryDate: json['expiryDate'] as String?,
      cvv: json['cvv'] as String?,
      usePoints: json['usePoints'] as bool? ?? false,
    );

Map<String, dynamic> _$CheckoutRequestToJson(_CheckoutRequest instance) =>
    <String, dynamic>{
      'items': instance.items,
      'pan': instance.pan,
      'expiryDate': instance.expiryDate,
      'cvv': instance.cvv,
      'usePoints': instance.usePoints,
    };

_CartItemRequest _$CartItemRequestFromJson(Map<String, dynamic> json) =>
    _CartItemRequest(
      articleId: (json['articleId'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$CartItemRequestToJson(_CartItemRequest instance) =>
    <String, dynamic>{
      'articleId': instance.articleId,
      'quantity': instance.quantity,
    };

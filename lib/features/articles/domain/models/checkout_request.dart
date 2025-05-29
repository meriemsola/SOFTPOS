import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_request.freezed.dart';
part 'checkout_request.g.dart';

@freezed
abstract class CheckoutRequest with _$CheckoutRequest {
  const factory CheckoutRequest({
    required List<CartItemRequest> items,
    String? pan,
    String? expiryDate,
    String? cvv,
    @Default(false) bool usePoints,
  }) = _CheckoutRequest;

  factory CheckoutRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckoutRequestFromJson(json);
}

@freezed
abstract class CartItemRequest with _$CartItemRequest {
  const factory CartItemRequest({
    required int articleId,
    required int quantity,
  }) = _CartItemRequest;

  factory CartItemRequest.fromJson(Map<String, dynamic> json) =>
      _$CartItemRequestFromJson(json);
}

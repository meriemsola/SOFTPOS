import 'package:hce_emv/features/articles/domain/models/article.dart';
import 'package:hce_emv/features/profile/domain/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart.freezed.dart';
part 'cart.g.dart';

@freezed
abstract class CartItem with _$CartItem {
  const factory CartItem({required Article article, @Default(1) int quantity}) =
      _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);
}

enum CartStatus { active, checkedOut, completed, cancelled }

@freezed
abstract class Cart with _$Cart {
  const factory Cart({
    required int id,
    User? user,
    @Default([]) List<CartItem> items,
    required DateTime createdAt,
    @Default(0.0) double totalAmount,
    @Default(CartStatus.active) CartStatus status,
  }) = _Cart;

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
}

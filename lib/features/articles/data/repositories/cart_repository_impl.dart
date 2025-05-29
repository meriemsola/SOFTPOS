import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hce_emv/core/network/network_interceptor.dart';
import 'package:hce_emv/features/articles/data/sources/cart_client.dart';
import 'package:hce_emv/features/articles/domain/models/checkout_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hce_emv/features/articles/domain/models/article.dart';
import 'package:hce_emv/features/articles/domain/models/cart.dart';
import 'package:hce_emv/features/articles/domain/repositories/cart_repository.dart';
import 'package:fpdart/fpdart.dart';

class CartRepositoryImpl implements CartRepository {
  final CartClient _cartClient;

  CartRepositoryImpl(this._cartClient);
  static const String _cartKey = 'cart';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  Future<Cart> _loadCart() async {
    final prefs = await _prefs;
    final cartJson = prefs.getString(_cartKey);
    if (cartJson != null) {
      return Cart.fromJson(jsonDecode(cartJson));
    }
    return Cart(id: 1, createdAt: DateTime.now(), items: []);
  }

  Future<void> _saveCart(Cart cart) async {
    final prefs = await _prefs;
    await prefs.setString(_cartKey, jsonEncode(cart.toJson()));
  }

  @override
  Future<Either<String, Cart>> getCart() async {
    try {
      final cart = await _loadCart();
      return right(cart);
    } catch (e) {
      return left('Failed to load cart: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Cart>> addToCart(Article article, int quantity) async {
    try {
      final cart = await _loadCart();
      final index = cart.items.indexWhere(
        (item) => item.article.id == article.id,
      );
      List<CartItem> updatedItems = List.from(cart.items);
      if (index != -1) {
        final existing = updatedItems[index];
        updatedItems[index] = existing.copyWith(
          quantity: existing.quantity + quantity,
        );
      } else {
        updatedItems.add(CartItem(article: article, quantity: quantity));
      }
      final updatedCart = cart.copyWith(
        items: updatedItems,
        totalAmount: _calculateTotal(updatedItems),
      );
      await _saveCart(updatedCart);
      return right(updatedCart);
    } catch (e) {
      return left('Failed to add to cart: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Cart>> removeFromCart(int articleId) async {
    try {
      final cart = await _loadCart();
      final updatedItems =
          cart.items.where((item) => item.article.id != articleId).toList();
      final updatedCart = cart.copyWith(
        items: updatedItems,
        totalAmount: _calculateTotal(updatedItems),
      );
      await _saveCart(updatedCart);
      return right(updatedCart);
    } catch (e) {
      return left('Failed to remove from cart: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Cart>> updateCartItem(
    Article article,
    int quantity,
  ) async {
    try {
      final cart = await _loadCart();
      final index = cart.items.indexWhere(
        (item) => item.article.id == article.id,
      );
      List<CartItem> updatedItems = List.from(cart.items);
      if (index != -1) {
        if (quantity > 0) {
          updatedItems[index] = updatedItems[index].copyWith(
            quantity: quantity,
          );
        } else {
          updatedItems.removeAt(index);
        }
      } else if (quantity > 0) {
        updatedItems.add(CartItem(article: article, quantity: quantity));
      }
      final updatedCart = cart.copyWith(
        items: updatedItems,
        totalAmount: _calculateTotal(updatedItems),
      );
      await _saveCart(updatedCart);
      return right(updatedCart);
    } catch (e) {
      return left('Failed to update cart item: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> checkoutCart(
    CheckoutRequest request,
  ) async {
    try {
      final response = await _cartClient.checkoutCart(request);
      if (response.status == 'success' && response.data != null) {
        return right(response.data!);
      }
      return left(response.message);
    } on DioException catch (e) {
      final errorMessage = DioErrorHandler.handleError(e);
      return left(errorMessage);
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<void> clearCart() async {
    final prefs = await _prefs;
    await prefs.remove(_cartKey);
  }

  double _calculateTotal(List<CartItem> items) {
    return items.fold(
      0.0,
      (sum, item) => sum + item.article.price * item.quantity,
    );
  }
}

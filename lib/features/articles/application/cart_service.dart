// lib/features/articles/application/article_service.dart
import 'package:hce_emv/features/articles/domain/models/article.dart';
import 'package:hce_emv/features/articles/domain/models/checkout_request.dart';
import 'package:hce_emv/features/articles/domain/repositories/cart_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hce_emv/features/articles/domain/models/cart.dart';

part 'cart_service.g.dart';

@riverpod
CartService cartService(Ref ref) =>
    CartService(ref.watch(cartRepositoryProvider));

class CartService {
  final CartRepository _repository;

  CartService(this._repository);

  Future<Either<String, Cart>> getCart() {
    return _repository.getCart();
  }

  Future<Either<String, Cart>> addToCart(Article article, int quantity) {
    return _repository.addToCart(article, quantity);
  }

  Future<Either<String, Cart>> removeFromCart(int articleId) {
    return _repository.removeFromCart(articleId);
  }

  Future<Either<String, Cart>> updateCartItem(Article article, int quantity) {
    return _repository.updateCartItem(article, quantity);
  }

  Future<Either<String, Map<String, dynamic>>> checkoutCart(
    CheckoutRequest request,
  ) {
    return _repository.checkoutCart(request);
  }

  Future<void> clearCart() {
    return _repository.clearCart();
  }
}

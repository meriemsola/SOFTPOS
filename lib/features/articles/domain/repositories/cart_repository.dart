// lib/features/articles/domain/repositories/article_repository.dart
import 'package:hce_emv/features/articles/data/repositories/cart_repository_impl.dart';
import 'package:hce_emv/features/articles/data/sources/cart_client.dart';
import 'package:hce_emv/features/articles/domain/models/article.dart';
import 'package:hce_emv/features/articles/domain/models/checkout_request.dart';
import 'package:hce_emv/features/articles/domain/models/cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_repository.g.dart';

@riverpod
CartRepository cartRepository(Ref ref) =>
    CartRepositoryImpl(ref.watch(cartClientProvider));

abstract class CartRepository {
  Future<Either<String, Cart>> getCart();
  Future<Either<String, Cart>> addToCart(Article article, int quantity);
  Future<Either<String, Cart>> removeFromCart(int articleId);
  Future<Either<String, Cart>> updateCartItem(Article article, int quantity);
  Future<Either<String, Map<String, dynamic>>> checkoutCart(
    CheckoutRequest request,
  );
  Future<void> clearCart();
}

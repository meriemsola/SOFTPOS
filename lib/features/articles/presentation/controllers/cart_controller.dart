import 'package:hce_emv/features/articles/application/cart_service.dart';
import 'package:hce_emv/features/articles/domain/models/article.dart';
import 'package:hce_emv/features/articles/domain/models/cart.dart';
import 'package:hce_emv/features/articles/domain/models/checkout_request.dart';
import 'package:hce_emv/features/transactions/presentation/controllers/transactions_controller.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_controller.g.dart';

@riverpod
class CartController extends _$CartController {
  @override
  Future<Cart> build() async {
    state = const AsyncLoading();
    final cart = await AsyncValue.guard(() async {
      final result = await ref.read(cartServiceProvider).getCart();
      return result.fold((error) => throw error, (cart) => cart);
    });
    state = cart;
    return cart.value!;
  }

  Future<void> addToCart(Article article, [int quantity = 1]) async {
    state = const AsyncLoading();
    final result = await ref
        .read(cartServiceProvider)
        .addToCart(article, quantity);
    state = result.fold(
      (error) => AsyncError(error, StackTrace.current),
      (cart) => AsyncData(cart),
    );
  }

  Future<void> removeFromCart(Article article) async {
    state = const AsyncLoading();
    final result = await ref
        .read(cartServiceProvider)
        .removeFromCart(article.id);
    state = result.fold(
      (error) => AsyncError(error, StackTrace.current),
      (cart) => AsyncData(cart),
    );
  }

  Future<void> updateQuantity(Article article, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(article);
      return;
    }
    state = const AsyncLoading();
    final result = await ref
        .read(cartServiceProvider)
        .updateCartItem(article, quantity);
    state = result.fold(
      (error) => AsyncError(error, StackTrace.current),
      (cart) => AsyncData(cart),
    );
  }

  Future<(int earned, int deducted, int total)?> checkoutCart(
    CheckoutRequest request,
  ) async {
    state = const AsyncLoading();
    try {
      final result = await ref.read(cartServiceProvider).checkoutCart(request);
      if (result.isLeft()) {
        final error = result.swap().getOrElse((error) => 'Unknown error');
        state = AsyncError(error, StackTrace.current);
        return null;
      }
      final response = result.getOrElse((error) => {});
      final userRepo = ref.read(userRepositoryProvider);
      final updatedUser = await userRepo.getUser();

      int earnedPoints = response['addedLoyaltyPoints'] as int? ?? 0;
      int deductedPoints = response['deductedLoyaltyPoints'] as int? ?? 0;
      int netPointsChange = earnedPoints - deductedPoints;
      int? totalPoints;

      if (updatedUser != null) {
        totalPoints = updatedUser.loyaltyPoints + netPointsChange;
        final updatedUserWithPoints = updatedUser.copyWith(
          loyaltyPoints: totalPoints,
        );
        await userRepo.saveUser(updatedUserWithPoints);
        ref.invalidate(userProvider);
      }

      await ref.read(transactionsControllerProvider.notifier).refresh();
      await ref.read(cartServiceProvider).clearCart();
      state = AsyncData(Cart(id: 1, createdAt: DateTime.now(), items: []));

      if (totalPoints != null) {
        return (earnedPoints, deductedPoints, totalPoints);
      }
      return null;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return null;
    }
  }

  Future<void> clearCart() async {
    await ref.read(cartServiceProvider).clearCart();
    state = AsyncData(Cart(id: 1, createdAt: DateTime.now(), items: []));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final result = await ref.read(cartServiceProvider).getCart();
    state = result.fold(
      (error) => AsyncError(error, StackTrace.current),
      (cart) => AsyncData(cart),
    );
  }
}

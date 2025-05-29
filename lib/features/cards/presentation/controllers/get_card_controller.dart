// lib/features/cards/presentation/controllers/get_card_controller.dart
import 'package:hce_emv/features/cards/application/card_service.dart';
import 'package:hce_emv/features/cards/domain/models/card.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'get_card_controller.g.dart';

@riverpod
class GetCardController extends _$GetCardController {
  @override
  Future<Card?> build() async {
    state = const AsyncLoading();
    final card = await AsyncValue.guard(() async {
      final result = await ref.read(cardServiceProvider).getCard();
      return result.fold((error) => throw error, (card) => card);
    });
    print('card: ${card.value}');
    state = card;
    return card.value;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(cardServiceProvider).getCard();
      return result.fold((error) => throw error, (card) => card);
    });
  }
}

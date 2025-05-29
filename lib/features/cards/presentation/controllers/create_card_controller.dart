// lib/features/cards/presentation/controllers/create_card_controller.dart
import 'package:hce_emv/features/cards/application/card_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_card_controller.g.dart';

@riverpod
class CreateCardController extends _$CreateCardController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<bool> createCard() async {
    state = const AsyncLoading();

    try {
      final result = await ref.read(cardServiceProvider).createCard();

      return result.fold(
        (error) {
          state = AsyncError(error, StackTrace.current);
          return false;
        },
        (response) {
          state = const AsyncData(null);
          return true;
        },
      );
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return false;
    }
  }
}

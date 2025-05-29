// lib/features/cards/presentation/controllers/validate_card_controller.dart
import 'package:hce_emv/features/cards/application/card_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'validate_card_controller.g.dart';

@riverpod
class ValidateCardController extends _$ValidateCardController {
  @override
  AsyncValue<bool?> build() {
    return const AsyncData(null);
  }

  Future<bool> validateCard(String pan, String cvv, String expiryDate) async {
    state = const AsyncLoading();
    try {
      final result = await ref
          .read(cardServiceProvider)
          .validateCard(pan, cvv, expiryDate);
      return result.fold(
        (error) {
          state = AsyncError(error, StackTrace.current);
          return false;
        },
        (isValid) {
          state = AsyncData(isValid);
          return isValid;
        },
      );
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return false;
    }
  }
}

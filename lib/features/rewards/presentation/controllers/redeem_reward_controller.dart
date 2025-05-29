import 'package:hce_emv/features/rewards/application/reward_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';

part 'redeem_reward_controller.g.dart';

@riverpod
class RedeemRewardController extends _$RedeemRewardController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<bool> redeemReward(String rewardId, int pointsRequired) async {
    state = const AsyncLoading();

    try {
      final result = await ref
          .read(rewardServiceProvider)
          .redeemReward(rewardId);

      return await result.fold(
        (error) {
          state = AsyncError(error, StackTrace.current);
          return false;
        },
        (reward) async {
          // Deduct user points after successful redemption
          final userRepo = ref.read(userRepositoryProvider);
          final user = await userRepo.getUser();
          if (user != null) {
            final updatedUser = user.copyWith(
              loyaltyPoints: user.loyaltyPoints - pointsRequired,
            );
            await userRepo.saveUser(updatedUser);
            ref.invalidate(userProvider);
          }
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

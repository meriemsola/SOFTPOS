// lib/features/rewards/presentation/controllers/user_rewards_controller.dart
import 'package:hce_emv/features/rewards/application/reward_service.dart';
import 'package:hce_emv/features/rewards/domain/models/reward.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_rewards_controller.g.dart';

@riverpod
class UserRewardsController extends _$UserRewardsController {
  @override
  Future<List<Reward>> build() async {
    state = const AsyncLoading();
    final rewards = await AsyncValue.guard(() async {
      final result = await ref.read(rewardServiceProvider).getUserRewards();
      return result.fold((error) => throw error, (rewards) => rewards);
    });
    state = rewards;
    return rewards.value!;
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final result = await ref.read(rewardServiceProvider).getUserRewards();
      return result.fold((error) => throw error, (rewards) => rewards);
    });
  }
}

// lib/features/rewards/presentation/controllers/rewards_controller.dart
import 'package:hce_emv/features/rewards/application/reward_service.dart';
import 'package:hce_emv/features/rewards/domain/models/reward.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rewards_controller.g.dart';

@riverpod
class RewardsController extends _$RewardsController {
  @override
  Future<List<Reward>?> build() async {
    state = const AsyncLoading();
    final rewards = await AsyncValue.guard(() async {
      final result = await ref.read(rewardServiceProvider).getRewards();
      return result.fold((error) => throw error, (rewards) => rewards);
    });
    state = rewards;
    return rewards.valueOrNull ?? [];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(rewardServiceProvider).getRewards();
      return result.fold((error) => throw error, (card) => card);
    });
  }
}

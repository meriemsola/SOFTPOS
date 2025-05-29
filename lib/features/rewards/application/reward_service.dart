import 'package:hce_emv/features/rewards/domain/models/reward.dart';
import 'package:hce_emv/features/rewards/domain/repositories/reward_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reward_service.g.dart';

@riverpod
RewardService rewardService(Ref ref) =>
    RewardService(ref.watch(rewardRepositoryProvider));

class RewardService {
  final RewardRepository _repository;

  RewardService(this._repository);

  Future<Either<String, List<Reward>>> getRewards() {
    return _repository.getRewards();
  }

  Future<Either<String, List<Reward>>> getUserRewards() {
    return _repository.getUserRewards();
  }

  Future<Either<String, Reward>> redeemReward(String rewardId) {
    return _repository.redeemReward(rewardId);
  }
}

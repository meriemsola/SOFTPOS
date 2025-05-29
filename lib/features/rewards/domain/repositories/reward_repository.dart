// lib/features/rewards/domain/repositories/reward_repository.dart
import 'package:hce_emv/features/rewards/data/sources/reward_client.dart';
import 'package:hce_emv/features/rewards/data/repositories/reward_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/reward.dart';

part 'reward_repository.g.dart';

@riverpod
RewardRepository rewardRepository(Ref ref) =>
    RewardRepositoryImpl(ref.watch(rewardClientProvider));

abstract class RewardRepository {
  Future<Either<String, List<Reward>>> getRewards();
  Future<Either<String, List<Reward>>> getUserRewards();
  Future<Either<String, Reward>> redeemReward(String rewardId);
}

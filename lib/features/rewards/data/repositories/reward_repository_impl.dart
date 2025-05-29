// lib/features/rewards/data/repositories/reward_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:hce_emv/core/network/network_interceptor.dart';
import 'package:hce_emv/features/rewards/data/sources/reward_client.dart';
import 'package:hce_emv/features/rewards/domain/models/reward.dart';
import 'package:hce_emv/features/rewards/domain/repositories/reward_repository.dart';
import 'package:fpdart/fpdart.dart';

class RewardRepositoryImpl implements RewardRepository {
  final RewardClient _rewardClient;

  RewardRepositoryImpl(this._rewardClient);

  @override
  Future<Either<String, List<Reward>>> getRewards() async {
    try {
      final response = await _rewardClient.getRewards();
      if (response.status == 'success' && response.data != null) {
        return right(response.data!);
      }
      return left(response.message);
    } on DioException catch (e) {
      final errorMessage = DioErrorHandler.handleError(e);
      return left(errorMessage);
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Reward>>> getUserRewards() async {
    try {
      final response = await _rewardClient.getUserRewards();
      if (response.status == 'success' && response.data != null) {
        return right(response.data!);
      }
      return left(response.message);
    } on DioException catch (e) {
      final errorMessage = DioErrorHandler.handleError(e);
      return left(errorMessage);
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, Reward>> redeemReward(String rewardId) async {
    try {
      final response = await _rewardClient.redeemReward(rewardId);
      if (response.status == 'success' && response.data != null) {
        return right(response.data!);
      }
      return left(response.message);
    } on DioException catch (e) {
      final errorMessage = DioErrorHandler.handleError(e);
      return left(errorMessage);
    } catch (e) {
      return left(e.toString());
    }
  }
}

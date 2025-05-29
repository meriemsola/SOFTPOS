// reward_client.dart
import 'package:hce_emv/core/network/api_client.dart';
import 'package:hce_emv/core/network/api_endpoints.dart';
import 'package:hce_emv/core/network/api_response.dart';
import 'package:hce_emv/features/rewards/domain/models/reward.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reward_client.g.dart';

@riverpod
RewardClient rewardClient(Ref ref) =>
    RewardClient(ref.watch(apiClientProvider));

class RewardClient {
  final ApiClient _apiClient;

  RewardClient(this._apiClient);

  Future<ApiResponse<List<Reward>>> getRewards() async {
    return _apiClient.get<List<Reward>>(
      ApiEndpoints.availableRewards,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((item) => Reward.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          // Handle the case where json is not a List
          throw FormatException('Expected List, got ${json.runtimeType}');
        }
      },
    );
  }

  Future<ApiResponse<List<Reward>>> getUserRewards() async {
    return _apiClient.get<List<Reward>>(
      ApiEndpoints.claimedRewards,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((item) => Reward.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw FormatException('Expected List, got ${json.runtimeType}');
        }
      },
    );
  }

  Future<ApiResponse<Reward>> redeemReward(String rewardId) async {
    return _apiClient.post<Reward>(
      ApiEndpoints.claimReward(rewardId),
      fromJson: (json) => Reward.fromJson(json as Map<String, dynamic>),
    );
  }
}

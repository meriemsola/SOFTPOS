// lib/features/rewards/domain/models/reward.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reward.freezed.dart';
part 'reward.g.dart';

@freezed
abstract class Reward with _$Reward {
  const factory Reward({
    required int id,
    required String name,
    required String description,
    required int pointsRequired,
    required String category,
    required bool available,
  }) = _Reward;

  factory Reward.fromJson(Map<String, dynamic> json) => _$RewardFromJson(json);
}

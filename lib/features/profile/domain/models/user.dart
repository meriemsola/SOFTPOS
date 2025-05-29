import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hce_emv/core/utils/helpers/loyalty_helper.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum Role { USER, ADMIN }

enum AuthProvider { LOCAL, OAuth2 }

@freezed
abstract class User with _$User {
  const factory User({
    required int id,
    required String username,
    required String email,
    @Default(false) bool enabled,
    @Default(0) int loyaltyPoints,
    @Default(Role.USER) Role role,
    @Default(AuthProvider.LOCAL) AuthProvider authProvider,
    DateTime? pointsExpirationDate,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

extension UserTierExtension on User {
  LoyaltyTier get tier => LoyaltyHelper.getTier(loyaltyPoints);
}

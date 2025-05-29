import 'package:flutter/material.dart';
import 'package:hce_emv/core/utils/helpers/loyalty_helper.dart';
import 'package:hce_emv/features/profile/domain/models/user.dart';
import 'package:hce_emv/shared/presentation/widgets/card_container.dart';

class LoyaltyStatus extends StatelessWidget {
  final User user;

  const LoyaltyStatus({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tierColor = _tierColor(user.tier);
    final daysLeft = LoyaltyHelper.daysUntilExpiration(
      user.pointsExpirationDate,
    );
    final isSilver = user.tier == LoyaltyTier.silver;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CardContainer(
        padding: const EdgeInsets.all(18),
        borderRadius: 18,
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Tier badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSilver
                            ? const Color(0xFFE0E0E0).withOpacity(0.7)
                            : tierColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSilver ? const Color(0xFFB0B0B0) : tierColor,
                      width: 1.4,
                    ),
                    boxShadow:
                        isSilver
                            ? [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : [],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: isSilver ? const Color(0xFFB0B0B0) : tierColor,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        LoyaltyHelper.tierName(user.tier),
                        style: TextStyle(
                          color: isSilver ? Colors.black87 : tierColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Expiration chip
                if (user.pointsExpirationDate != null && daysLeft >= 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.red, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Expires in $daysLeft days',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            // Progress bar with label
            Row(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color:
                              isSilver
                                  ? const Color(0xFFE0E0E0)
                                  : tierColor.withOpacity(0.10),
                          boxShadow:
                              isSilver
                                  ? [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.18),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                  : [],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: LoyaltyHelper.progressToNextTier(
                            user.loyaltyPoints,
                          ),
                          child: Container(
                            height: 18,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient:
                                  isSilver
                                      ? const LinearGradient(
                                        colors: [
                                          Color(0xFFB0B0B0),
                                          Color(0xFFD3D3D3),
                                          Color(0xFFF5F5F5),
                                          Color(0xFFB0B0B0),
                                        ],
                                        stops: [0.0, 0.5, 0.8, 1.0],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      )
                                      : LinearGradient(
                                        colors: [
                                          tierColor.withOpacity(0.7),
                                          tierColor,
                                        ],
                                      ),
                              boxShadow:
                                  isSilver
                                      ? [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.15),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                      : [],
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '${user.loyaltyPoints} / ${LoyaltyHelper.nextTierThreshold(user.loyaltyPoints)} pts',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isSilver
                                      ? Colors.black87
                                      : (isDark
                                          ? Colors.white70
                                          : Colors.black54),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Next: ${LoyaltyHelper.tierName(LoyaltyHelper.getTier(LoyaltyHelper.nextTierThreshold(user.loyaltyPoints)))}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSilver ? Colors.black87 : tierColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _tierColor(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return const Color(0xFFB08D57);
      case LoyaltyTier.silver:
        return const Color(0xFFC0C0C0);
      case LoyaltyTier.gold:
        return const Color(0xFFFFD700);
      case LoyaltyTier.platinum:
        return const Color(0xFF6A5ACD);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:hce_emv/features/rewards/domain/models/reward.dart';
import 'package:hce_emv/shared/presentation/widgets/card_container.dart';
import 'package:hce_emv/theme/app_colors.dart';

class RewardCard extends StatelessWidget {
  final Reward reward;
  final VoidCallback onTap;
  const RewardCard({super.key, required this.reward, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CardContainer(
        onTap: onTap,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(Icons.card_giftcard, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reward.category,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '-${reward.pointsRequired}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

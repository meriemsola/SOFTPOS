import 'package:hce_emv/theme/app_colors.dart';
import 'package:flutter/material.dart';

class RewardsTabBar extends StatelessWidget {
  final TabController tabController;

  const RewardsTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.primary,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? Colors.white70 : Colors.black87,
        tabs: const [Tab(text: 'Browse Rewards'), Tab(text: 'My Rewards')],
      ),
    );
  }
}

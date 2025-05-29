import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hce_emv/theme/app_sizes.dart';

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class SkeletonLoyaltyCard extends StatelessWidget {
  const SkeletonLoyaltyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: double.infinity,
      height: 180,
      borderRadius: BorderRadius.circular(20),
    );
  }
}

class SkeletonRewardCard extends StatelessWidget {
  const SkeletonRewardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: AppSizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(
            width: 150,
            height: 80,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          const SizedBox(height: AppSizes.sm),
          SkeletonBox(width: 100, height: 16),
          const SizedBox(height: 8),
          SkeletonBox(width: 60, height: 12),
          const SizedBox(height: 8),
          SkeletonBox(width: 40, height: 12),
        ],
      ),
    );
  }
}

class SkeletonRewardListItem extends StatelessWidget {
  const SkeletonRewardListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SkeletonBox(
          width: 60,
          height: 60,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 120, height: 16),
              const SizedBox(height: 8),
              SkeletonBox(width: 80, height: 12),
            ],
          ),
        ),
        SkeletonBox(width: 40, height: 16),
      ],
    );
  }
}

class SkeletonArticleCard extends StatelessWidget {
  const SkeletonArticleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(
          width: double.infinity,
          height: 120,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        const SizedBox(height: AppSizes.sm),
        SkeletonBox(width: 100, height: 16),
        const SizedBox(height: 8),
        SkeletonBox(width: 60, height: 12),
      ],
    );
  }
}

class SkeletonProfileHeader extends StatelessWidget {
  const SkeletonProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SkeletonBox(
          width: 100,
          height: 100,
          borderRadius: BorderRadius.circular(50),
        ),
        const SizedBox(height: AppSizes.md),
        SkeletonBox(width: 120, height: 20),
        const SizedBox(height: 8),
        SkeletonBox(width: 180, height: 14),
        const SizedBox(height: 16),
        SkeletonBox(width: 80, height: 16),
      ],
    );
  }
}

class SkeletonTransactionItem extends StatelessWidget {
  const SkeletonTransactionItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SkeletonBox(
          width: 40,
          height: 40,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 120, height: 16),
              const SizedBox(height: 8),
              SkeletonBox(width: 80, height: 12),
            ],
          ),
        ),
        SkeletonBox(width: 40, height: 16),
      ],
    );
  }
}

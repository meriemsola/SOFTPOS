import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hce_emv/features/rewards/presentation/controllers/rewards_controller.dart';

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

final viewTypeProvider = StateProvider<bool>((ref) => true);

final categoriesProvider = Provider<List<String>>((ref) {
  final rewardsAsync = ref.watch(rewardsControllerProvider);
  return rewardsAsync.maybeWhen(
    data: (rewards) {
      // Extract unique categories from rewards
      final categories =
          rewards?.map((reward) => reward.category).toSet().toList() ?? [];
      // Sort categories alphabetically
      categories.sort();
      return categories;
    },
    orElse: () => [],
  );
});

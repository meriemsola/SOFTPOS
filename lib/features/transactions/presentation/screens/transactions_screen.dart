import 'package:hce_emv/core/extensions/context_extensions.dart';
// import 'package:hce_emv/features/rewards/domain/models/reward.dart';
// import 'package:hce_emv/features/rewards/presentation/controllers/user_rewards_controller.dart';
import 'package:hce_emv/features/transactions/domain/models/transaction.dart';
import 'package:hce_emv/features/transactions/presentation/controllers/transactions_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hce_emv/shared/presentation/widgets/skeletons.dart';
import 'package:hce_emv/shared/presentation/widgets/gradient_background.dart';
import '../widgets/transaction_card.dart';
import '../widgets/transaction_filter_bar.dart';
// import '../widgets/reward_filter_bar.dart';
// import 'package:hce_emv/features/rewards/presentation/screens/rewards_screen.dart' show EnhancedRewardListCard, EnhancedRewardDetailsSheet;
import 'package:intl/intl.dart';
import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/core/utils/helpers/currency_helper.dart';
import 'package:hce_emv/shared/providers/global_providers.dart';

enum TransactionSortBy {
  dateDesc,
  dateAsc,
  amountDesc,
  amountAsc,
  referenceAsc,
  referenceDesc,
}

enum TransactionFilter {
  all,
  thisWeek,
  thisMonth,
  lastMonth,
  last3Months,
  thisYear,
  custom,
}

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  TransactionSortBy _sortBy = TransactionSortBy.dateDesc;
  TransactionFilter _filter = TransactionFilter.all;
  DateTimeRange? _customDateRange;
  bool _showFilters = false;

  // Memoization state
  List<Transaction> _filteredTransactions = [];
  Map<String, List<Transaction>> _groupedTransactions = {};
  List<Transaction>? _lastTransactions;
  String? _lastSearchQuery;
  TransactionSortBy? _lastSortBy;
  TransactionFilter? _lastFilter;
  DateTimeRange? _lastCustomDateRange;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilteredAndGrouped(List<Transaction> transactions) {
    if (_lastTransactions == transactions &&
        _lastSearchQuery == _searchQuery &&
        _lastSortBy == _sortBy &&
        _lastFilter == _filter &&
        _lastCustomDateRange == _customDateRange) {
      return; // No change, skip recomputation
    }
    _filteredTransactions = _filterAndSortTransactions(transactions);
    _groupedTransactions = _groupTransactionsByDate(_filteredTransactions);
    _lastTransactions = transactions;
    _lastSearchQuery = _searchQuery;
    _lastSortBy = _sortBy;
    _lastFilter = _filter;
    _lastCustomDateRange = _customDateRange;
  }

  List<Transaction> _filterAndSortTransactions(List<Transaction> transactions) {
    // Apply date filter
    List<Transaction> filtered =
        transactions.where((tx) {
          final now = DateTime.now();
          switch (_filter) {
            case TransactionFilter.all:
              return true;
            case TransactionFilter.thisWeek:
              final weekStart = now.subtract(Duration(days: now.weekday - 1));
              return tx.timestamp.isAfter(weekStart) ||
                  tx.timestamp.isAtSameMomentAs(weekStart);
            case TransactionFilter.thisMonth:
              return tx.timestamp.year == now.year &&
                  tx.timestamp.month == now.month;
            case TransactionFilter.lastMonth:
              final lastMonth = DateTime(now.year, now.month - 1);
              return tx.timestamp.year == lastMonth.year &&
                  tx.timestamp.month == lastMonth.month;
            case TransactionFilter.last3Months:
              final threeMonthsAgo = DateTime(now.year, now.month - 3);
              return tx.timestamp.isAfter(threeMonthsAgo);
            case TransactionFilter.thisYear:
              return tx.timestamp.year == now.year;
            case TransactionFilter.custom:
              if (_customDateRange == null) return true;
              return tx.timestamp.isAfter(_customDateRange!.start) &&
                  tx.timestamp.isBefore(
                    _customDateRange!.end.add(const Duration(days: 1)),
                  );
          }
        }).toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered =
          filtered.where((tx) {
            return tx.referenceNumber.toLowerCase().contains(query) ||
                (tx.authorizationCode?.toLowerCase().contains(query) ??
                    false) ||
                (tx.pan?.toLowerCase().contains(query) ?? false);
          }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case TransactionSortBy.dateDesc:
        filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case TransactionSortBy.dateAsc:
        filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case TransactionSortBy.amountDesc:
        filtered.sort((a, b) => b.amount.abs().compareTo(a.amount.abs()));
        break;
      case TransactionSortBy.amountAsc:
        filtered.sort((a, b) => a.amount.abs().compareTo(a.amount.abs()));
        break;
      case TransactionSortBy.referenceAsc:
        filtered.sort((a, b) => a.referenceNumber.compareTo(b.referenceNumber));
        break;
      case TransactionSortBy.referenceDesc:
        filtered.sort((a, b) => b.referenceNumber.compareTo(a.referenceNumber));
        break;
    }

    return filtered;
  }

  Map<String, List<Transaction>> _groupTransactionsByDate(
    List<Transaction> transactions,
  ) {
    final Map<String, List<Transaction>> grouped = {};
    for (final transaction in transactions) {
      String key;
      final now = DateTime.now();
      final difference = now.difference(transaction.timestamp!).inDays;

      if (difference == 0) {
        key = 'Today';
      } else if (difference == 1) {
        key = 'Yesterday';
      } else if (difference < 7) {
        key = DateFormat('EEEE').format(transaction.timestamp!);
      } else {
        key = DateFormat('MMM dd, yyyy').format(transaction.timestamp!);
      }

      grouped.putIfAbsent(key, () => []).add(transaction);
    }

    return grouped;
  }

  double _calculateTotalAmount(List<Transaction> transactions) {
    return transactions.fold(0.0, (sum, tx) => sum + tx.amount.abs());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final transactionsAsync = ref.watch(transactionsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: _showFilters ? AppColors.primary : null,
            ),
            tooltip: 'Filters',
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () async {
              await ref.read(transactionsControllerProvider.notifier).refresh();
              // await ref.read(userRewardsControllerProvider.notifier).refresh();
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TransactionFilterBar(controller: _searchController),
                /*
                child: _tabController.index == 0
                    ? TransactionFilterBar(controller: _searchController)
                    : RewardFilterBar(controller: _searchController),
                */
              ),

              // Filter Options (when expanded)
              if (_showFilters)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black12 : Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sort Options
                      const Text(
                        'Sort by',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildSortChip(
                            'Date (Newest)',
                            TransactionSortBy.dateDesc,
                          ),
                          _buildSortChip(
                            'Date (Oldest)',
                            TransactionSortBy.dateAsc,
                          ),
                          _buildSortChip(
                            'Amount (High)',
                            TransactionSortBy.amountDesc,
                          ),
                          _buildSortChip(
                            'Amount (Low)',
                            TransactionSortBy.amountAsc,
                          ),
                          _buildSortChip(
                            'Reference (A-Z)',
                            TransactionSortBy.referenceAsc,
                          ),
                          _buildSortChip(
                            'Reference (Z-A)',
                            TransactionSortBy.referenceDesc,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Filter Options
                      const Text(
                        'Filter by date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFilterChip('All', TransactionFilter.all),
                          _buildFilterChip(
                            'This Week',
                            TransactionFilter.thisWeek,
                          ),
                          _buildFilterChip(
                            'This Month',
                            TransactionFilter.thisMonth,
                          ),
                          _buildFilterChip(
                            'Last Month',
                            TransactionFilter.lastMonth,
                          ),
                          _buildFilterChip(
                            'Last 3 Months',
                            TransactionFilter.last3Months,
                          ),
                          _buildFilterChip(
                            'This Year',
                            TransactionFilter.thisYear,
                          ),
                          _buildFilterChip(
                            'Custom Range',
                            TransactionFilter.custom,
                          ),
                        ],
                      ),

                      // Custom Date Range Picker
                      if (_filter == TransactionFilter.custom)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final range = await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                      initialDateRange: _customDateRange,
                                    );
                                    if (range != null) {
                                      setState(() {
                                        _customDateRange = range;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.date_range),
                                  label: Text(
                                    _customDateRange == null
                                        ? 'Select Date Range'
                                        : '${DateFormat('MMM dd').format(_customDateRange!.start)} - ${DateFormat('MMM dd').format(_customDateRange!.end)}',
                                  ),
                                ),
                              ),
                              if (_customDateRange != null) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _customDateRange = null;
                                    });
                                  },
                                  icon: const Icon(Icons.clear),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

              Expanded(
                child: transactionsAsync.when(
                  data: (transactions) {
                    _updateFilteredAndGrouped(transactions);
                    final filtered = _filteredTransactions;
                    final totalAmount = _calculateTotalAmount(filtered);
                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (_searchQuery.isNotEmpty ||
                                _filter != TransactionFilter.all)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                      _searchController.clear();
                                      _filter = TransactionFilter.all;
                                      _customDateRange = null;
                                    });
                                  },
                                  child: const Text('Clear filters'),
                                ),
                              ),
                          ],
                        ),
                      );
                    }

                    final groupedTransactions = _groupedTransactions;

                    return Column(
                      children: [
                        // Summary Card
                        if (filtered.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.1),
                                  AppColors.secondary.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(16),
                              ),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${filtered.length} Transaction${filtered.length == 1 ? '' : 's'}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _getFilterDescription(),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Total Amount',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      CurrencyHelper.format(totalAmount),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        // Grouped Transaction List
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: groupedTransactions.length,
                            itemBuilder: (context, index) {
                              final entry = groupedTransactions.entries
                                  .elementAt(index);
                              final dateKey = entry.key;
                              final dayTransactions = entry.value;
                              final dayTotal = _calculateTotalAmount(
                                dayTransactions,
                              );

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date Header
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          dateKey,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          CurrencyHelper.format(dayTotal),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Day's Transactions
                                  ...dayTransactions.asMap().entries.map((
                                    entry,
                                  ) {
                                    final i = entry.key;
                                    final tx = entry.value;
                                    return Padding(
                                      key: ValueKey(tx.id),
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: TransactionCard(
                                        transaction: tx,
                                        onTap:
                                            () => _showTransactionDetails(
                                              context,
                                              tx,
                                            ),
                                        animationIndex: i < 10 ? i : null,
                                      ),
                                    );
                                  }),

                                  const SizedBox(height: 8),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  loading:
                      () => ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: 6,
                        itemBuilder:
                            (context, index) => const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: SkeletonTransactionItem(),
                            ),
                      ),
                  error:
                      (error, stack) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 16),
                            const Text('Error loading transactions'),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed:
                                  () => ref.refresh(
                                    transactionsControllerProvider,
                                  ),
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                ),
                /*
                // Rewards Tab
                userRewardsAsync.when(
                  data: (rewards) {
                    // Filter rewards by search query (name or category)
                    final filteredRewards = _searchQuery.isEmpty
                        ? rewards
                        : rewards.where((reward) {
                            final query = _searchQuery.toLowerCase();
                            return reward.name.toLowerCase().contains(
                                  query,
                                ) ||
                                reward.category.toLowerCase().contains(
                                  query,
                                );
                          }).toList();
                    if (filteredRewards.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.card_giftcard,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No claimed rewards yet'
                                  : 'No rewards found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                  child: const Text('Clear search'),
                                ),
                              ),
                          ],
                        ),
                      );
                    }

                    // Group rewards by category (like in rewards_screen.dart)
                    final groupedRewards = <String, List<Reward>>{};
                    for (final reward in filteredRewards) {
                      if (groupedRewards.containsKey(reward.category)) {
                        groupedRewards[reward.category]!.add(reward);
                      } else {
                        groupedRewards[reward.category] = [reward];
                      }
                    }
                    final categories = groupedRewards.keys.toList()..sort();

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: categories.length,
                      itemBuilder: (context, categoryIndex) {
                        final category = categories[categoryIndex];
                        final categoryRewards = groupedRewards[category]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (categoryIndex > 0)
                              const SizedBox(height: 24),
                            // Category header (copied from rewards_screen.dart)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withOpacity(0.1),
                                    AppColors.primary.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getCategoryIcon(category),
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ),
                                    ),
                                    child: Text(
                                      categoryRewards.length.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...categoryRewards.map(
                              (reward) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: EnhancedRewardListCard(
                                  reward: reward,
                                  isRedeemed: true,
                                  onTap: () => _showEnhancedRewardDetails(
                                    context,
                                    reward,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  loading: () => ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 4,
                    itemBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: SkeletonRewardListItem(),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text('Error loading rewards'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () =>
                              ref.refresh(userRewardsControllerProvider),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                ),
                */
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, TransactionSortBy sortBy) {
    final isSelected = _sortBy == sortBy;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _sortBy = sortBy;
          });
        }
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildFilterChip(String label, TransactionFilter filter) {
    final isSelected = _filter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filter = filter;
            if (filter != TransactionFilter.custom) {
              _customDateRange = null;
            }
          });
        }
      },
      selectedColor: AppColors.secondary.withOpacity(0.2),
      checkmarkColor: AppColors.secondary,
    );
  }

  String _getFilterDescription() {
    switch (_filter) {
      case TransactionFilter.all:
        return 'All time';
      case TransactionFilter.thisWeek:
        return 'This week';
      case TransactionFilter.thisMonth:
        return 'This month';
      case TransactionFilter.lastMonth:
        return 'Last month';
      case TransactionFilter.last3Months:
        return 'Last 3 months';
      case TransactionFilter.thisYear:
        return 'This year';
      case TransactionFilter.custom:
        if (_customDateRange != null) {
          return '${DateFormat('MMM dd').format(_customDateRange!.start)} - ${DateFormat('MMM dd').format(_customDateRange!.end)}';
        }
        return 'Custom range';
    }
  }

  void _showTransactionDetails(BuildContext context, Transaction tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder:
                (context, scrollController) => _TransactionDetailsSheet(
                  transaction: tx,
                  scrollController: scrollController,
                ),
          ),
    );
  }

  /*
  void _showEnhancedRewardDetails(BuildContext context, Reward reward) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => EnhancedRewardDetailsSheet(reward: reward),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'travel':
        return Icons.flight;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.health_and_safety;
      default:
        return Icons.card_giftcard;
    }
  }
  */
}

class _TransactionDetailsSheet extends ConsumerWidget {
  final Transaction transaction;
  final ScrollController scrollController;

  const _TransactionDetailsSheet({
    required this.transaction,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    String? locale;
    String currency = 'USD';
    userAsync.whenData((user) {
      // If you add locale/currency to user, update them here
    });
    locale ??= Localizations.localeOf(context).toString();
    final articlesAsync = ref.watch(
      transactionArticlesProvider(transaction.id),
    );

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transaction Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          transaction.referenceNumber,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Amount Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade50, Colors.red.shade100],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Amount',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '-${CurrencyHelper.format(transaction.amount.abs(), currencyCode: currency, locale: locale)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Transaction Details
              _buildDetailSection('Transaction Information', [
                _buildDetailRow(
                  'Date & Time',
                  DateFormat(
                    'MMMM dd, yyyy • HH:mm',
                  ).format(transaction.timestamp!),
                ),
                _buildDetailRow(
                  'Reference Number',
                  transaction.referenceNumber,
                ),
                _buildDetailRow(
                  'Authorization Code',
                  transaction.authorizationCode ?? 'N/A',
                ),
                _buildDetailRow(
                  'Response Code',
                  transaction.responseCode ?? 'N/A',
                ),
                _buildDetailRow(
                  'Card Number',
                  '****${transaction.pan?.substring(transaction.pan!.length - 4) ?? 'N/A'}',
                ),
              ]),

              const SizedBox(height: 24),

              // Articles Section
              const Text(
                'Purchased Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              articlesAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('No items found for this transaction'),
                      ),
                    );
                  }

                  return Column(
                    children:
                        items
                            .map(
                              (item) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.shopping_bag,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.article.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Quantity: ${item.quantity}',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          CurrencyHelper.format(
                                            item.article.price * item.quantity,
                                            currencyCode: currency,
                                            locale: locale,
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (item.quantity > 1)
                                          Text(
                                            '${CurrencyHelper.format(item.article.price, currencyCode: currency, locale: locale)} each',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  );
                },
                loading:
                    () => Container(
                      padding: const EdgeInsets.all(20),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                error:
                    (e, _) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Failed to load items',
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                        ],
                      ),
                    ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

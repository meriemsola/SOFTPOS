import 'package:hce_emv/core/extensions/context_extensions.dart';
import 'package:hce_emv/features/Softpos/transaction_storage.dart';
import 'package:hce_emv/features/transactions/domain/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:hce_emv/shared/presentation/widgets/skeletons.dart';
import 'package:hce_emv/shared/presentation/widgets/gradient_background.dart';
import 'package:hce_emv/features/transactions/presentation/widgets/transaction_card.dart';
import 'package:hce_emv/features/transactions/presentation/widgets/transaction_filter_bar.dart';
import 'package:intl/intl.dart';
import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/core/utils/helpers/currency_helper.dart';

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

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
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
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });
    final transactionLogs = await TransactionStorage.loadTransactions();
    setState(() {
      _transactions =
          transactionLogs
              .asMap()
              .entries
              .map(
                (entry) => Transaction(
                  id: entry.key,
                  userId: 0,
                  referenceNumber: entry.value.dateTime,
                  authorizationCode:
                      entry.value.isOnline ? entry.value.atc : 'AUTH1234',
                  responseCode: entry.value.status == 'Approved' ? '00' : 'N/A',
                  pan: entry.value.pan,
                  timestamp: entry.value.timestamp,
                  amount: entry.value.amount,
                ),
              )
              .toList();
      _updateFilteredAndGrouped(_transactions);
      _isLoading = false;
    });
  }

  Future<void> _clearHistory() async {
    await TransactionStorage.clearTransactions();
    setState(() {
      _transactions.clear();
      _filteredTransactions.clear();
      _groupedTransactions.clear();
      _lastTransactions = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Historique effacé avec succès')),
    );
  }

  void _updateFilteredAndGrouped(List<Transaction> transactions) {
    // Force update if any parameter has changed
    if (_lastTransactions != transactions ||
        _lastSearchQuery != _searchQuery ||
        _lastSortBy != _sortBy ||
        _lastFilter != _filter ||
        _lastCustomDateRange != _customDateRange) {
      _filteredTransactions = _filterAndSortTransactions(transactions);
      _groupedTransactions = _groupTransactionsByDate(_filteredTransactions);
      _lastTransactions = transactions;
      _lastSearchQuery = _searchQuery;
      _lastSortBy = _sortBy;
      _lastFilter = _filter;
      _lastCustomDateRange = _customDateRange;
      setState(() {}); // Force UI update
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _updateFilteredAndGrouped(_transactions);
    });
  }

  List<Transaction> _filterAndSortTransactions(List<Transaction> transactions) {
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
        filtered.sort((a, b) => a.amount.abs().compareTo(b.amount.abs()));
        break;
      case TransactionSortBy.referenceAsc:
        filtered.sort((a, b) => a.referenceNumber.compareTo(b.referenceNumber));
        break;
      case TransactionSortBy.referenceDesc:
        filtered.sort((a, b) => b.referenceNumber.compareTo(b.referenceNumber));
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
      final difference = now.difference(transaction.timestamp).inDays;

      if (difference == 0) {
        key = 'Today';
      } else if (difference == 1) {
        key = 'Yesterday';
      } else if (difference < 7) {
        key = DateFormat('EEEE').format(transaction.timestamp);
      } else {
        key = DateFormat('MMM dd, yyyy').format(transaction.timestamp);
      }

      grouped.putIfAbsent(key, () => []).add(transaction);
    }
    return grouped;
  }

  double _calculateTotalAmount(List<Transaction> transactions) {
    return transactions.fold(0.0, (sum, tx) => sum + tx.amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

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
            onPressed: _loadTransactions,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear History',
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Confirm Deletion'),
                      content: const Text(
                        'Do you want to clear the entire transaction history?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _clearHistory();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TransactionFilterBar(controller: _searchController),
              ),
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
                                        _updateFilteredAndGrouped(
                                          _transactions,
                                        );
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
                                      _updateFilteredAndGrouped(_transactions);
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
                child:
                    _isLoading
                        ? ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: 6,
                          itemBuilder:
                              (context, index) => const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: SkeletonTransactionItem(),
                              ),
                        )
                        : _filteredTransactions.isEmpty
                        ? Center(
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
                                        _updateFilteredAndGrouped(
                                          _transactions,
                                        );
                                      });
                                    },
                                    child: const Text('Clear filters'),
                                  ),
                                ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          // Changed to ListView.builder for better scrolling
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _groupedTransactions.length,
                          itemBuilder: (context, index) {
                            final entry = _groupedTransactions.entries
                                .elementAt(index);
                            final dateKey = entry.key;
                            final dayTransactions = entry.value;
                            final dayTotal = _calculateTotalAmount(
                              dayTransactions,
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...dayTransactions.asMap().entries.map((entry) {
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
                                      onDelete: () async {},
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
            _updateFilteredAndGrouped(_transactions);
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
            _updateFilteredAndGrouped(_transactions);
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
}

class _TransactionDetailsSheet extends StatelessWidget {
  final Transaction transaction;
  final ScrollController scrollController;

  const _TransactionDetailsSheet({
    required this.transaction,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    const currency = 'DA';

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transaction Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            transaction.referenceNumber,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade50, Colors.green.shade100],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Amount',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '+${CurrencyHelper.format(transaction.amount.abs(), currencyCode: currency, locale: locale)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailSection('Transaction Information', [
                  _buildDetailRow(
                    'Date & Time',
                    DateFormat(
                      'MMMM dd, yyyy • HH:mm',
                    ).format(transaction.timestamp),
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
                  _buildDetailRow('User ID', transaction.userId.toString()),
                ]),
              ],
            ),
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

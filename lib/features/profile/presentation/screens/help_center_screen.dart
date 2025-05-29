// lib/features/profile/presentation/screens/help_center_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hce_emv/core/extensions/context_extensions.dart';
import 'package:hce_emv/features/profile/domain/models/faq_item.dart';
import 'package:hce_emv/shared/presentation/widgets/gradient_background.dart';
import 'package:hce_emv/shared/presentation/widgets/card_container.dart';
import 'package:hce_emv/theme/app_colors.dart';
import 'package:hce_emv/theme/app_sizes.dart';
import 'package:hce_emv/core/utils/helpers/toast_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:hce_emv/shared/presentation/widgets/profile_shared_widgets.dart';

class HelpCenterScreen extends ConsumerStatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  ConsumerState<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends ConsumerState<HelpCenterScreen> {
  final _searchController = TextEditingController();
  List<FAQItem> _filteredFAQs = [];

  final List<FAQItem> _allFAQs = [
    FAQItem(
      category: 'Account',
      question: 'How do I create an account?',
      answer:
          'To create an account, tap the "Sign Up" button on the login screen, enter your email and create a password. You\'ll receive a verification email to complete the process.',
    ),
    FAQItem(
      category: 'Account',
      question: 'How do I reset my password?',
      answer:
          'On the login screen, tap "Forgot Password?" and enter your email address. You\'ll receive instructions to reset your password.',
    ),
    FAQItem(
      category: 'Rewards',
      question: 'How do I earn loyalty points?',
      answer:
          'You can earn loyalty points by making purchases, referring friends, completing challenges, and participating in special promotions.',
    ),
    FAQItem(
      category: 'Rewards',
      question: 'When do my points expire?',
      answer:
          'Loyalty points expire 12 months from the date they were earned. You can check your points expiration date in your profile.',
    ),
    FAQItem(
      category: 'Rewards',
      question: 'How do I redeem my points?',
      answer:
          'Go to the Rewards section, browse available rewards, and tap "Claim" on the reward you want. Make sure you have enough points.',
    ),
    FAQItem(
      category: 'Cards',
      question: 'How do I add a loyalty card?',
      answer:
          'Go to the Cards section and tap "Add Card". Enter your card details or scan the barcode if available.',
    ),
    FAQItem(
      category: 'Cards',
      question: 'Can I have multiple cards?',
      answer:
          'Currently, you can have one active loyalty card per account. Contact support if you need to change your card.',
    ),
    FAQItem(
      category: 'Transactions',
      question: 'Where can I see my transaction history?',
      answer:
          'Your transaction history is available in the Transactions tab. You can filter by date and transaction type.',
    ),
    FAQItem(
      category: 'Technical',
      question: 'The app is running slowly, what should I do?',
      answer:
          'Try closing and reopening the app. If the problem persists, clear the app cache in Settings > Data & Storage > Clear Cache.',
    ),
    FAQItem(
      category: 'Technical',
      question: 'I\'m not receiving notifications',
      answer:
          'Check your notification settings in Settings > Notifications. Also ensure notifications are enabled for the app in your device settings.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredFAQs = _allFAQs;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFAQs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFAQs = _allFAQs;
      } else {
        _filteredFAQs =
            _allFAQs
                .where(
                  (faq) =>
                      faq.question.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      faq.answer.toLowerCase().contains(query.toLowerCase()) ||
                      faq.category.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final categories =
        _filteredFAQs.map((faq) => faq.category).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterFAQs,
                  decoration: InputDecoration(
                    hintText: 'Search for help...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterFAQs('');
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor:
                        isDark ? AppColors.darkCard : AppColors.lightCard,
                  ),
                ),
              ),

              // Quick Actions
              if (_searchController.text.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Row(
                        children: [
                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.chat_bubble_outline,
                              title: 'Live Chat',
                              subtitle: 'Chat with support',
                              onTap: _startLiveChat,
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.email_outlined,
                              title: 'Email Us',
                              subtitle: 'Send us an email',
                              onTap: _sendEmail,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.lg),
                    ],
                  ),
                ),
              ],

              // FAQ List
              Expanded(
                child:
                    _filteredFAQs.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.md,
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final categoryFAQs =
                                _filteredFAQs
                                    .where((faq) => faq.category == category)
                                    .toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (index > 0)
                                  const SizedBox(height: AppSizes.lg),
                                SectionHeader(category),
                                const SizedBox(height: AppSizes.sm),
                                ...categoryFAQs.map(
                                  (faq) => _buildFAQItem(faq),
                                ),
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

  Widget _buildFAQItem(FAQItem faq) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: CardContainer(
        child: ExpansionTile(
          title: Text(
            faq.question,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Text(
                faq.answer,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: context.isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: context.isDarkMode ? Colors.white30 : Colors.black26,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.isDarkMode ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Try different keywords or contact support',
            style: TextStyle(
              fontSize: 14,
              color: context.isDarkMode ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          ElevatedButton.icon(
            onPressed: _startLiveChat,
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }

  void _startLiveChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder:
                (context, scrollController) => Container(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      const Text(
                        'Live Chat Support',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      Text(
                        'Chat with our support team for immediate assistance.',
                        style: TextStyle(
                          color:
                              context.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSizes.xl),
                      Icon(
                        Icons.support_agent,
                        size: 80,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppSizes.lg),
                      const Text(
                        'Live chat is available:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      const Text('Monday - Friday: 9:00 AM - 6:00 PM'),
                      const Text('Saturday: 10:00 AM - 4:00 PM'),
                      const Text('Sunday: Closed'),
                      const SizedBox(height: AppSizes.xl),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.pop();
                            ToastHelper.showInfo(
                              'Live chat will be available soon',
                            );
                          },
                          child: const Text('Start Chat'),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _sendEmail() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Contact Support'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Send us an email at:'),
                SizedBox(height: 8),
                SelectableText(
                  'support@fideligo.com',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 16),
                Text('We typically respond within 24 hours.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  context.pop();
                  ToastHelper.showInfo('Opening email app...');
                  // TODO: Implement email app opening
                },
                child: const Text('Open Email'),
              ),
            ],
          ),
    );
  }
}

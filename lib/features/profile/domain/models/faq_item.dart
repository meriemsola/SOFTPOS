// lib/features/profile/domain/models/faq_item.dart
class FAQItem {
  final String category;
  final String question;
  final String answer;

  const FAQItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}

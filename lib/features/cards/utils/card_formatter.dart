// lib/features/cards/utils/card_formatter.dart
class CardFormatter {


  static String maskCardNumber(String pan) {
    if (pan.isEmpty) return '';

    final cleanPan = pan.replaceAll(RegExp(r'\D'), '');

    if (cleanPan.length <= 4) return cleanPan;

    final masked =
        '*' * (cleanPan.length - 4) + cleanPan.substring(cleanPan.length - 4);

    final buffer = StringBuffer();
    for (int i = 0; i < masked.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(masked[i]);
    }

    return buffer.toString();
  }

  static String getCardType(String pan) {
    if (pan.isEmpty) return 'Unknown';

    final cleanPan = pan.replaceAll(RegExp(r'\D'), '');

    if (cleanPan.startsWith('4')) {
      return 'Visa';
    } else if (cleanPan.startsWith('5')) {
      return 'MasterCard';
    } else if (cleanPan.startsWith('3')) {
      return 'American Express';
    } else if (cleanPan.startsWith('6')) {
      return 'Discover';
    }

    return 'Unknown';
  }
}

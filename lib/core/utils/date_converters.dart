// lib/core/utils/date_converters.dart
import 'package:intl/intl.dart';

class DateConverters {
  static String formatExpiryDate(DateTime date) {
    return DateFormat('MM/yy').format(date);
  }

  static String formatExpiryDateForApi(DateTime date) {
    return DateFormat('MMyy').format(date);
  }

  static DateTime parseExpiryDate(String expiryDate) {
    final parts = expiryDate.split('/');
    if (parts.length != 2) {
      throw FormatException('Invalid expiry date format: $expiryDate');
    }

    final month = int.parse(parts[0]);
    var year = int.parse(parts[1]);

    if (year < 100) {
      year += 2000;
    }

    final lastDay = DateTime(year, month + 1, 0).day;

    return DateTime(year, month, lastDay, 23, 59, 59);
  }

  static bool isCardExpired(DateTime expiryDate) {
    final now = DateTime.now();
    return expiryDate.isBefore(now);
  }
}

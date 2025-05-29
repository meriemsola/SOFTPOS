import 'package:intl/intl.dart';

class CurrencyHelper {
  /// Format a double as currency, e.g. 1234.56 -> $1,234.56
  /// [currencyCode] defaults to 'USD'.
  static String format(
    double amount, {
    String currencyCode = 'USD',
    String? locale,
  }) {
    final format = NumberFormat.currency(
      locale: locale,
      symbol: NumberFormat.simpleCurrency(name: currencyCode).currencySymbol,
      name: currencyCode,
    );
    return format.format(amount);
  }
}

import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 1,
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }
}
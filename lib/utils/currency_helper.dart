import 'package:intl/intl.dart';

class CurrencyHelper {
  static String formatRupiah(double amount) {
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);
    return formatter.format(amount);
  }
}

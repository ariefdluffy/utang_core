import 'package:intl/intl.dart';

class DateHelper {
  static String formatTanggal(DateTime date) {
    final formatter = DateFormat('EEEE, d MMMM y', 'id_ID');
    return formatter.format(date);
  }

  static String formatWaktu(DateTime date) {
    final formatter = DateFormat('HH:mm', 'id_ID');
    return formatter.format(date);
  }

  static String formatTanggalLengkap(DateTime date) {
    return formatTanggal(date);
  }
}

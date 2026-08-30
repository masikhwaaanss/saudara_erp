import 'package:intl/intl.dart';

class DateFormatter {
  /// Format date to dd/MM/yyyy
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format date time to dd/MM/yyyy HH:mm
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  /// Format date time with seconds
  static String formatDateTimeWithSeconds(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
  }

  /// Format date to full text (e.g., "30 Agustus 2026")
  static String formatDateToText(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  /// Format date to day name and date (e.g., "Sabtu, 30 Agustus 2026")
  static String formatDateFull(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
  }

  /// Format time only (HH:mm)
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Format year and month (MM/yyyy)
  static String formatYearMonth(DateTime date) {
    return DateFormat('MM/yyyy').format(date);
  }

  /// Get relative time (e.g., "2 jam yang lalu")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'baru saja';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes menit yang lalu';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours jam yang lalu';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days hari yang lalu';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu yang lalu';
    } else {
      return formatDate(dateTime);
    }
  }
}

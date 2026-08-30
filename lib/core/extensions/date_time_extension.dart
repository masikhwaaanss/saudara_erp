extension DateTimeExtension on DateTime {
  /// Format date to dd/MM/yyyy
  String toFormattedDate() {
    return '$day/$month/$year';
  }

  /// Format date to dd/MM/yyyy HH:mm
  String toFormattedDateTime() {
    return '$day/$month/$year ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Format date to yyyy-MM-dd
  String toISODate() {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  /// Format date to yyyyMMdd
  String toCompactDate() {
    return '$year${month.toString().padLeft(2, '0')}${day.toString().padLeft(2, '0')}';
  }

  /// Check if date is today
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Get start of day (00:00:00)
  DateTime startOfDay() {
    return DateTime(year, month, day);
  }

  /// Get end of day (23:59:59)
  DateTime endOfDay() {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// Get start of month
  DateTime startOfMonth() {
    return DateTime(year, month, 1);
  }

  /// Get end of month
  DateTime endOfMonth() {
    return DateTime(year, month + 1, 0, 23, 59, 59, 999);
  }

  /// Check if date is overdue
  bool isOverdue() {
    return isBefore(DateTime.now());
  }

  /// Get days difference from now
  int daysFromNow() {
    final now = DateTime.now();
    final difference = now.difference(this);
    return difference.inDays;
  }
}

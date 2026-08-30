class NumberFormatter {
  /// Format to currency IDR
  static String formatCurrency(int amount) {
    return 'Rp ${formatNumber(amount)}';
  }

  /// Format number with thousands separator
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (Match m) => '${m.group(1)}.',
    );
  }

  /// Format decimal to 2 places
  static String formatDecimal(double value) {
    return value.toStringAsFixed(2);
  }

  /// Parse currency string to int
  static int parseCurrency(String value) {
    final cleaned = value
        .replaceAll('Rp ', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .trim();
    return int.tryParse(cleaned) ?? 0;
  }

  /// Format percentage
  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(2)}%';
  }
}

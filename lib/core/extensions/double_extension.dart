extension DoubleExtension on double {
  /// Format to currency
  String toCurrencyFormat() {
    return 'Rp ${toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (Match m) => '${m.group(1)}.',
    )}';
  }

  /// Format to thousands
  String toThousandsFormat() {
    return toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (Match m) => '${m.group(1)}.',
    );
  }

  /// Format to specific decimal places
  String toDecimalFormat(int places) {
    return toStringAsFixed(places);
  }
}

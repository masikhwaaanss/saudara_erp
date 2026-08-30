extension IntExtension on int {
  /// Format to currency
  String toCurrencyFormat() {
    return 'Rp ${toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (Match m) => '${m.group(1)}.',
    )}';
  }

  /// Format to thousands
  String toThousandsFormat() {
    return toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (Match m) => '${m.group(1)}.',
    );
  }
}

extension StringExtension on String {
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Check if string is numeric
  bool isNumeric() {
    return double.tryParse(this) != null;
  }

  /// Check if email is valid (simple validation)
  bool isValidEmail() {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if phone number is valid (Indonesian format)
  bool isValidPhone() {
    final phoneRegex = RegExp(r'^(\+62|62|0)[0-9]{9,12}$');
    return phoneRegex.hasMatch(replaceAll('-', '').replaceAll(' ', ''));
  }

  /// Convert to currency format
  String toCurrency() {
    if (!isNumeric()) return this;
    final number = int.parse(this);
    return 'Rp ${number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (Match m) => '${m.group(1)}.',
    )}';
  }

  /// Remove all whitespace
  String removeAllWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Check if string contains only letters
  bool isAlphabetic() {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }

  /// Check if string contains alphanumeric only
  bool isAlphaNumeric() {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }
}

class InputValidator {
  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(
      String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != password) {
      return 'Password tidak cocok';
    }
    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    if (!RegExp(r'^(\+62|62|0)[0-9]{9,12}$')
        .hasMatch(value.replaceAll('-', '').replaceAll(' ', ''))) {
      return 'Format nomor telepon tidak valid';
    }
    return null;
  }

  /// Validate numeric field
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName harus berupa angka';
    }
    return null;
  }

  /// Validate positive number
  static String? validatePositiveNumber(String? value, String fieldName) {
    final numericError = validateNumeric(value, fieldName);
    if (numericError != null) return numericError;
    if (double.parse(value!) <= 0) {
      return '$fieldName harus lebih dari 0';
    }
    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength) {
    if (value == null) return null;
    if (value.length > maxLength) {
      return 'Maksimal $maxLength karakter';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength) {
    if (value == null || value.isEmpty) return null;
    if (value.length < minLength) {
      return 'Minimal $minLength karakter';
    }
    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL tidak boleh kosong';
    }
    if (!Uri.tryParse(value)?.hasAbsolutePath ?? false) {
      return 'Format URL tidak valid';
    }
    return null;
  }

  /// Validate date format dd/MM/yyyy
  static String? validateDateFormat(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tanggal tidak boleh kosong';
    }
    try {
      final parts = value.split('/');
      if (parts.length != 3) throw FormatException();
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      if (day < 1 || day > 31 || month < 1 || month > 12 || year < 1900) {
        throw FormatException();
      }
    } catch (_) {
      return 'Format tanggal tidak valid (dd/MM/yyyy)';
    }
    return null;
  }
}

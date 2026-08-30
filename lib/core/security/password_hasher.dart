import 'package:crypto/crypto.dart';

class PasswordHasher {
  /// Hash password using SHA256
  static String hashPassword(String password) {
    return sha256.convert(password.codeUnits).toString();
  }

  /// Verify password against hash
  static bool verifyPassword(String password, String hash) {
    return hashPassword(password) == hash;
  }
}

/// Base Exception
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => 'AppException: $message';
}

/// Database Exception
class DatabaseException extends AppException {
  DatabaseException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );
}

/// Authentication Exception
class AuthException extends AppException {
  AuthException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );
}

/// Validation Exception
class ValidationException extends AppException {
  final Map<String, String>? errors;

  ValidationException({
    required String message,
    this.errors,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );
}

/// Not Found Exception
class NotFoundException extends AppException {
  NotFoundException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );
}

/// Business Logic Exception
class BusinessException extends AppException {
  BusinessException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );
}

/// File Exception
class FileException extends AppException {
  FileException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );
}

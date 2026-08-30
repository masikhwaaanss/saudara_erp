import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('🔍 LOG: $message');
      if (error != null) {
        print('❌ ERROR: $error');
      }
      if (stackTrace != null) {
        print('📍 STACK: $stackTrace');
      }
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ INFO: $message');
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      print('✅ SUCCESS: $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️ WARNING: $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
      if (error != null) {
        print('   Details: $error');
      }
      if (stackTrace != null) {
        print('   Stack: $stackTrace');
      }
    }
  }
}

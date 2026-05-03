import 'package:flutter/material.dart';
import 'config.dart';

// Base Exception
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException(this.message, {this.code, this.originalError, this.stackTrace});

  @override
  String toString() {
    if (AppConfig.enableDebugLogging) {
      return 'AppException: $message (Code: $code)\n$stackTrace';
    }
    return message;
  }
}

// Specific Exceptions
class NetworkException extends AppException {
  NetworkException({dynamic error, StackTrace? stackTrace})
    : super(
        'No internet connection. Please check your network settings.',
        code: 'NETWORK_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
}

class AuthException extends AppException {
  AuthException(super.message, {super.code, dynamic error, super.stackTrace})
    : super(originalError: error);
}

class BookingException extends AppException {
  BookingException(super.message, {dynamic error, super.stackTrace})
    : super(code: 'BOOKING_ERROR', originalError: error);
}

class ValidationException extends AppException {
  ValidationException(super.message, {dynamic error, super.stackTrace})
    : super(code: 'VALIDATION_ERROR', originalError: error);
}

class ServerException extends AppException {
  ServerException({dynamic error, StackTrace? stackTrace})
    : super(
        'Server error. Please try again later.',
        code: 'SERVER_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
}

// Result class for handling success/failure
abstract class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});
}

// Error Logger (for debugging)
class ErrorLogger {
  static void logError(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (AppConfig.enableDebugLogging) {
      debugPrint('⚠️ ERROR: $message');
      if (error != null) debugPrint('   Error: $error');
      if (stackTrace != null) debugPrint('   StackTrace: $stackTrace');
    }
  }

  static void logInfo(String message) {
    if (AppConfig.enableDebugLogging) {
      debugPrint('ℹ️ INFO: $message');
    }
  }

  static void logSuccess(String message) {
    if (AppConfig.enableDebugLogging) {
      debugPrint('✅ SUCCESS: $message');
    }
  }
}

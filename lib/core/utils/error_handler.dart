import 'package:flutter/material.dart';
import 'package:intellicash/core/utils/logger.dart';

/// Centralized error handling system for IntelliCash
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// Error types for categorization
  enum ErrorType {
    network,
    database,
    validation,
    authentication,
    fileSystem,
    unknown,
  }

  /// Error severity levels
  enum ErrorSeverity {
    low,
    medium,
    high,
    critical,
  }

  /// Handle and log errors with appropriate categorization
  void handleError(
    dynamic error,
    StackTrace? stackTrace, {
    ErrorType type = ErrorType.unknown,
    ErrorSeverity severity = ErrorSeverity.medium,
    String? context,
    bool showUserMessage = true,
  }) {
    // Log the error with context
    Logger.printDebug('''
=== ERROR HANDLED ===
Type: $type
Severity: $severity
Context: ${context ?? 'No context provided'}
Error: $error
StackTrace: ${stackTrace ?? 'No stack trace'}
===================
''');

    // Log to analytics/crash reporting if severity is high or critical
    if (severity == ErrorSeverity.high || severity == ErrorSeverity.critical) {
      _logToAnalytics(error, stackTrace, type, severity, context);
    }

    // Show user-friendly message if requested
    if (showUserMessage) {
      _showUserMessage(error, type, severity);
    }
  }

  /// Handle async operations with error handling
  Future<T> handleAsync<T>(
    Future<T> Function() operation, {
    ErrorType type = ErrorType.unknown,
    ErrorSeverity severity = ErrorSeverity.medium,
    String? context,
    T? defaultValue,
    bool showUserMessage = true,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      handleError(
        error,
        stackTrace,
        type: type,
        severity: severity,
        context: context,
        showUserMessage: showUserMessage,
      );

      if (defaultValue != null) {
        return defaultValue;
      }

      rethrow;
    }
  }

  /// Handle database operations with specific error handling
  Future<T> handleDatabaseOperation<T>(
    Future<T> Function() operation, {
    String? context,
    T? defaultValue,
  }) async {
    return handleAsync(
      operation,
      type: ErrorType.database,
      severity: ErrorSeverity.high,
      context: context,
      defaultValue: defaultValue,
    );
  }

  /// Handle network operations with specific error handling
  Future<T> handleNetworkOperation<T>(
    Future<T> Function() operation, {
    String? context,
    T? defaultValue,
  }) async {
    return handleAsync(
      operation,
      type: ErrorType.network,
      severity: ErrorSeverity.medium,
      context: context,
      defaultValue: defaultValue,
    );
  }

  /// Handle file system operations with specific error handling
  Future<T> handleFileOperation<T>(
    Future<T> Function() operation, {
    String? context,
    T? defaultValue,
  }) async {
    return handleAsync(
      operation,
      type: ErrorType.fileSystem,
      severity: ErrorSeverity.medium,
      context: context,
      defaultValue: defaultValue,
    );
  }

  /// Validate input with error handling
  T? handleValidation<T>(
    T? Function() validation, {
    String? context,
    bool showUserMessage = true,
  }) {
    try {
      return validation();
    } catch (error, stackTrace) {
      handleError(
        error,
        stackTrace,
        type: ErrorType.validation,
        severity: ErrorSeverity.low,
        context: context,
        showUserMessage: showUserMessage,
      );
      return null;
    }
  }

  /// Show user-friendly error messages
  void _showUserMessage(dynamic error, ErrorType type, ErrorSeverity severity) {
    String message = _getUserFriendlyMessage(error, type, severity);
    
    // In a real app, you would show this via a snackbar or dialog
    // For now, we'll just log it
    Logger.printDebug('User Message: $message');
  }

  /// Get user-friendly error messages
  String _getUserFriendlyMessage(dynamic error, ErrorType type, ErrorSeverity severity) {
    switch (type) {
      case ErrorType.network:
        return 'Connection error. Please check your internet connection and try again.';
      case ErrorType.database:
        return 'Data error occurred. Please restart the app and try again.';
      case ErrorType.validation:
        return 'Invalid input. Please check your data and try again.';
      case ErrorType.authentication:
        return 'Authentication failed. Please log in again.';
      case ErrorType.fileSystem:
        return 'File operation failed. Please check your storage and try again.';
      case ErrorType.unknown:
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Log errors to analytics/crash reporting service
  void _logToAnalytics(
    dynamic error,
    StackTrace? stackTrace,
    ErrorType type,
    ErrorSeverity severity,
    String? context,
  ) {
    // In a real app, you would send this to Firebase Crashlytics, Sentry, etc.
    Logger.printDebug('''
=== ANALYTICS LOG ===
Error logged to analytics service:
Type: $type
Severity: $severity
Context: $context
Error: $error
===================
''');
  }

  /// Create a safe callback wrapper
  Function() safeCallback(
    Function() callback, {
    ErrorType type = ErrorType.unknown,
    ErrorSeverity severity = ErrorSeverity.medium,
    String? context,
  }) {
    return () {
      try {
        callback();
      } catch (error, stackTrace) {
        handleError(
          error,
          stackTrace,
          type: type,
          severity: severity,
          context: context,
        );
      }
    };
  }

  /// Create a safe async callback wrapper
  Future<void> Function() safeAsyncCallback(
    Future<void> Function() callback, {
    ErrorType type = ErrorType.unknown,
    ErrorSeverity severity = ErrorSeverity.medium,
    String? context,
  }) {
    return () async {
      try {
        await callback();
      } catch (error, stackTrace) {
        handleError(
          error,
          stackTrace,
          type: type,
          severity: severity,
          context: context,
        );
      }
    };
  }
}

/// Global error handler instance
final errorHandler = ErrorHandler();

/// Extension for easier error handling on Future
extension FutureErrorHandler<T> on Future<T> {
  /// Handle errors with default value
  Future<T> handleError({
    T? defaultValue,
    ErrorHandler.ErrorType type = ErrorHandler.ErrorType.unknown,
    ErrorHandler.ErrorSeverity severity = ErrorHandler.ErrorSeverity.medium,
    String? context,
    bool showUserMessage = true,
  }) async {
    try {
      return await this;
    } catch (error, stackTrace) {
      errorHandler.handleError(
        error,
        stackTrace,
        type: type,
        severity: severity,
        context: context,
        showUserMessage: showUserMessage,
      );
      
      if (defaultValue != null) {
        return defaultValue;
      }
      
      rethrow;
    }
  }
}

/// Extension for easier error handling on nullable values
extension NullableErrorHandler<T> on T? {
  /// Safely execute operation on nullable value
  R? safeOperation<R>(
    R Function(T value) operation, {
    String? context,
    bool showUserMessage = true,
  }) {
    if (this == null) {
      errorHandler.handleError(
        'Null value encountered',
        null,
        type: ErrorHandler.ErrorType.validation,
        severity: ErrorHandler.ErrorSeverity.low,
        context: context,
        showUserMessage: showUserMessage,
      );
      return null;
    }
    
    try {
      return operation(this as T);
    } catch (error, stackTrace) {
      errorHandler.handleError(
        error,
        stackTrace,
        type: ErrorHandler.ErrorType.validation,
        severity: ErrorHandler.ErrorSeverity.low,
        context: context,
        showUserMessage: showUserMessage,
      );
      return null;
    }
  }
} 
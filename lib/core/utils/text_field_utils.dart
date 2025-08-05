import 'package:flutter/services.dart';
import 'package:intellicash/core/utils/error_handler.dart';
import 'package:intellicash/i18n/generated/translations.g.dart';

/// A text input formatter that allows up to two decimal places,
/// replacing or disabling any invalid symbols
List<FilteringTextInputFormatter> get twoDecimalDigitFormatter =>
    decimalDigitFormatter(2);

/// A text input formatter that allows up to N decimal places,
/// replacing or disabling any invalid symbols
List<FilteringTextInputFormatter> decimalDigitFormatter(int decimalPlaces) {
  return errorHandler.handleValidation(
    () {
      if (decimalPlaces < 0) {
        throw Exception('Decimal places must be non-negative');
      }
      
      return [
        FilteringTextInputFormatter.deny(',', replacementString: '.'),
        FilteringTextInputFormatter.allow(
            RegExp(r'(^\d*\.?\d{0,' + decimalPlaces.toString() + r'})')),
      ];
    },
    context: 'Creating decimal digit formatter',
    showUserMessage: false,
  ) ?? [
    FilteringTextInputFormatter.deny(',', replacementString: '.'),
    FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d{0,2})')),
  ];
}

enum ValidatorType {
  text,
  double,
  int;

  bool get isNumber => this == double || this == int;
}

String? fieldValidator(String? value,
    {bool isRequired = false, ValidatorType validator = ValidatorType.text}) {
  return errorHandler.handleValidation(
    () {
      if (!isRequired && (value == null || value.isEmpty)) {
        // If the field is not required and is empty, we don't return any error
        return null;
      } else if (value == null || value.isEmpty) {
        return t.general.validations.required;
      }

      if (validator.isNumber) {
        final parsedValue = double.tryParse(value);
        if (parsedValue == null) {
          if (value.contains(',')) {
            return 'Character "," is not valid. Split the decimal part by a "."';
          }

          if (validator == ValidatorType.int && int.tryParse(value) == null) {
            return 'Please enter an integer number';
          }

          return 'Please enter a valid number';
        }

        // Additional validation for specific number types
        if (validator == ValidatorType.int && parsedValue != parsedValue.toInt()) {
          return 'Please enter a whole number';
        }
      }

      return null;
    },
    context: 'Validating field: ${validator.name}',
    showUserMessage: false,
  );
}

/// Validate email format
String? emailValidator(String? value, {bool isRequired = false}) {
  return errorHandler.handleValidation(
    () {
      if (!isRequired && (value == null || value.isEmpty)) {
        return null;
      } else if (value == null || value.isEmpty) {
        return t.general.validations.required;
      }

      // Basic email validation regex
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email address';
      }

      return null;
    },
    context: 'Validating email',
    showUserMessage: false,
  );
}

/// Validate phone number format
String? phoneValidator(String? value, {bool isRequired = false}) {
  return errorHandler.handleValidation(
    () {
      if (!isRequired && (value == null || value.isEmpty)) {
        return null;
      } else if (value == null || value.isEmpty) {
        return t.general.validations.required;
      }

      // Basic phone validation (allows digits, spaces, dashes, parentheses)
      final phoneRegex = RegExp(r'^[\d\s\-\(\)\+]+$');
      if (!phoneRegex.hasMatch(value)) {
        return 'Please enter a valid phone number';
      }

      // Check minimum length
      final digitsOnly = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
      if (digitsOnly.length < 7) {
        return 'Phone number is too short';
      }

      return null;
    },
    context: 'Validating phone number',
    showUserMessage: false,
  );
}

/// Validate URL format
String? urlValidator(String? value, {bool isRequired = false}) {
  return errorHandler.handleValidation(
    () {
      if (!isRequired && (value == null || value.isEmpty)) {
        return null;
      } else if (value == null || value.isEmpty) {
        return t.general.validations.required;
      }

      // Basic URL validation
      final urlRegex = RegExp(
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
      );
      if (!urlRegex.hasMatch(value)) {
        return 'Please enter a valid URL';
      }

      return null;
    },
    context: 'Validating URL',
    showUserMessage: false,
  );
}

/// Validate password strength
String? passwordValidator(String? value, {bool isRequired = false}) {
  return errorHandler.handleValidation(
    () {
      if (!isRequired && (value == null || value.isEmpty)) {
        return null;
      } else if (value == null || value.isEmpty) {
        return t.general.validations.required;
      }

      if (value.length < 8) {
        return 'Password must be at least 8 characters long';
      }

      // Check for at least one uppercase letter
      if (!RegExp(r'[A-Z]').hasMatch(value)) {
        return 'Password must contain at least one uppercase letter';
      }

      // Check for at least one lowercase letter
      if (!RegExp(r'[a-z]').hasMatch(value)) {
        return 'Password must contain at least one lowercase letter';
      }

      // Check for at least one digit
      if (!RegExp(r'[0-9]').hasMatch(value)) {
        return 'Password must contain at least one number';
      }

      return null;
    },
    context: 'Validating password',
    showUserMessage: false,
  );
}

/// Create a composite validator that runs multiple validators
String? compositeValidator(String? value, List<String? Function(String?)> validators) {
  return errorHandler.handleValidation(
    () {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    },
    context: 'Running composite validation',
    showUserMessage: false,
  );
}

/// Safe text parsing with error handling
T? safeParse<T>(String? text, T Function(String) parser, {String? context}) {
  return errorHandler.handleValidation(
    () {
      if (text == null || text.isEmpty) {
        return null;
      }
      
      try {
        return parser(text);
      } catch (e) {
        throw Exception('Failed to parse text: $e');
      }
    },
    context: context ?? 'Parsing text',
    showUserMessage: false,
  );
}

/// Safe number parsing
double? safeParseDouble(String? text, {String? context}) {
  return safeParse(text, double.parse, context: context ?? 'Parsing double');
}

/// Safe integer parsing
int? safeParseInt(String? text, {String? context}) {
  return safeParse(text, int.parse, context: context ?? 'Parsing integer');
}

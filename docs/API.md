# IntelliCash API Documentation

## Overview

This document provides comprehensive API documentation for the IntelliCash personal finance application. The API is built using Flutter/Dart with SQLite database and Firebase integration.

## Table of Contents

1. [Core Services](#core-services)
2. [Database Models](#database-models)
3. [Error Handling](#error-handling)
4. [Authentication](#authentication)
5. [AI Integration](#ai-integration)
6. [File Operations](#file-operations)
7. [Internationalization](#internationalization)

---

## Core Services

### ErrorHandler

Centralized error handling system for the entire application.

#### Error Types

```dart
enum ErrorType {
  network,      // Network-related errors
  database,     // Database operation errors
  validation,   // Input validation errors
  authentication, // Authentication errors
  fileSystem,   // File system errors
  unknown,      // Unknown errors
}
```

#### Error Severity

```dart
enum ErrorSeverity {
  low,      // Minor issues, no user action needed
  medium,   // Moderate issues, user should be informed
  high,     // Important issues, user action may be required
  critical, // Critical issues, app may be unusable
}
```

#### Usage Examples

```dart
// Basic error handling
errorHandler.handleError(
  error,
  stackTrace,
  type: ErrorHandler.ErrorType.database,
  severity: ErrorHandler.ErrorSeverity.high,
  context: 'Database operation',
);

// Async operation handling
await errorHandler.handleAsync(
  () async {
    // Your async operation
    return result;
  },
  type: ErrorHandler.ErrorType.network,
  context: 'API call',
);

// Database operation handling
await errorHandler.handleDatabaseOperation(
  () async => await database.insert(data),
  context: 'Inserting transaction',
);

// File operation handling
await errorHandler.handleFileOperation(
  () async => await file.writeAsString(content),
  context: 'Saving backup',
);

// Validation handling
final result = errorHandler.handleValidation(
  () => validateInput(input),
  context: 'Input validation',
  showUserMessage: true,
);
```

### AppDB

Main database class using Drift ORM for SQLite operations.

#### Safe Operations

```dart
// Safe insert
await appDB.safeInsert(transaction);

// Safe update
await appDB.safeUpdate(account);

// Safe delete
await appDB.safeDelete(category);

// Safe batch operations
await appDB.safeBatch(() async {
  await appDB.insert(transaction1);
  await appDB.insert(transaction2);
  await appDB.update(account);
});

// Safe custom statements
await appDB.safeCustomStatement('SELECT * FROM transactions WHERE amount > ?', [100.0]);
```

#### Database Validation

```dart
// Validate database integrity
final isValid = await appDB.validateDatabase();

// Backup database
await appDB.backupDatabase();

// Restore database
await appDB.restoreDatabase();
```

### KeyValueService

Persistent key-value storage with error handling.

```dart
// Set and get values
await keyValueService.setItem('user_preference', 'value');
final value = await keyValueService.getItem('user_preference');

// Check if item exists
final exists = await keyValueService.hasItem('key');

// Remove item
await keyValueService.removeItem('key');

// Batch updates
await keyValueService.batchUpdate({
  'setting1': 'value1',
  'setting2': 'value2',
});

// Clear all items
await keyValueService.clearAll();
```

---

## Database Models

### Transaction

```dart
class Transaction {
  final int? id;
  final double amount;
  final String description;
  final int categoryId;
  final int accountId;
  final DateTime date;
  final String? notes;
  final List<String>? tags;
  final bool isRecurring;
  final String? recurringPattern;
  
  // Constructor
  Transaction({
    this.id,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.accountId,
    required this.date,
    this.notes,
    this.tags,
    this.isRecurring = false,
    this.recurringPattern,
  });
}
```

### Account

```dart
class Account {
  final int? id;
  final String name;
  final AccountType type;
  final double balance;
  final String currency;
  final String? icon;
  final Color? color;
  final bool isActive;
  
  // Constructor
  Account({
    this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    this.icon,
    this.color,
    this.isActive = true,
  });
}
```

### Category

```dart
class Category {
  final int? id;
  final String name;
  final String icon;
  final Color color;
  final int? parentId;
  final bool isIncome;
  final bool isActive;
  
  // Constructor
  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.parentId,
    this.isIncome = false,
    this.isActive = true,
  });
}
```

### Budget

```dart
class Budget {
  final int? id;
  final String name;
  final double amount;
  final String period; // monthly, yearly
  final int categoryId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  
  // Constructor
  Budget({
    this.id,
    required this.name,
    required this.amount,
    required this.period,
    required this.categoryId,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });
}
```

---

## Error Handling

### Error Handler Extensions

```dart
// Future extension for error handling
extension FutureErrorHandler<T> on Future<T> {
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

// Nullable extension for safe operations
extension NullableErrorHandler<T> on T? {
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
```

### Safe Callbacks

```dart
// Safe callback wrapper
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

// Safe async callback wrapper
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
```

---

## Authentication

### Firebase Authentication

```dart
// Initialize Firebase
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

// Sign in with email and password
final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Sign up with email and password
final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);

// Sign out
await FirebaseAuth.instance.signOut();

// Get current user
final user = FirebaseAuth.instance.currentUser;
```

### Biometric Authentication

```dart
// Check if biometric authentication is available
final isAvailable = await LocalAuthentication().canCheckBiometrics;

// Authenticate with biometrics
final isAuthenticated = await LocalAuthentication().authenticate(
  localizedReason: 'Please authenticate to access your financial data',
  options: const AuthenticationOptions(
    biometricOnly: true,
    stickyAuth: true,
  ),
);
```

---

## AI Integration

### Google Generative AI

```dart
// Initialize AI service
final aiService = GoogleGenerativeAI(apiKey: apiKey);
final model = aiService.getGenerativeModel(model: 'gemini-pro');

// Generate content
final response = await model.generateContent([
  Content.text('Analyze my spending patterns for this month'),
]);

// Stream responses
final responseStream = model.generateContentStream([
  Content.text('Provide financial advice based on my transactions'),
]);

await for (final chunk in responseStream) {
  print(chunk.text);
}
```

### Natural Language Processing

```dart
// Process user query
final query = 'Show food spending last month';
final processedQuery = await aiService.processQuery(query);

// Get categorized results
final results = await aiService.getCategorizedResults(processedQuery);

// Analyze spending patterns
final analysis = await aiService.analyzeSpendingPatterns(transactions);

// Generate financial insights
final insights = await aiService.generateInsights(userData);
```

---

## File Operations

### Backup Database Service

```dart
// Export database to file
await backupService.exportDatabaseFile();

// Import database from file
await backupService.importDatabase(file);

// Export to CSV
await backupService.exportToCsv(transactions, file);

// Import from CSV
await backupService.importFromCsv(file);

// Read file with error handling
final content = await backupService.readFile(file);

// Process CSV data
final data = await backupService.processCsv(content);
```

### File Picker

```dart
// Pick file for import
final result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['csv', 'json'],
);

if (result != null) {
  final file = File(result.files.single.path!);
  await backupService.importDatabase(file);
}
```

---

## Internationalization

### Translation System

```dart
// Initialize translations
await LocaleSettings.useDeviceLocale();

// Get translated text
final text = t('common.save');

// Get text with parameters
final text = t('transaction.amount', args: [amount.toString()]);

// Get pluralized text
final text = t('transaction.count', args: [count.toString()]);
```

### Locale Management

```dart
// Set locale
await LocaleSettings.setLocale(const Locale('en'));

// Get current locale
final locale = LocaleSettings.currentLocale;

// Get available locales
final locales = LocaleSettings.supportedLocales;
```

---

## Validation

### Input Validation

```dart
// Email validation
final isValidEmail = emailValidator(email);

// Phone validation
final isValidPhone = phoneValidator(phone);

// URL validation
final isValidUrl = urlValidator(url);

// Password validation
final isValidPassword = passwordValidator(password);

// Composite validation
final isValid = compositeValidator([
  (value) => emailValidator(value),
  (value) => passwordValidator(value),
]);
```

### Safe Parsing

```dart
// Safe parse with error handling
final number = safeParse(text, double.parse, context: 'Parsing amount');

// Safe parse double
final amount = safeParseDouble(text, context: 'Parsing transaction amount');

// Safe parse integer
final count = safeParseInt(text, context: 'Parsing transaction count');
```

---

## Testing

### Unit Tests

```dart
// Test error handler
test('ErrorHandler should handle database errors', () async {
  await errorHandler.handleDatabaseOperation(
    () async => throw DatabaseException('Test error'),
    context: 'Test operation',
  );
  
  // Verify error was logged
  expect(logger.logs, contains('Database operation failed'));
});

// Test database operations
test('AppDB should safely insert transaction', () async {
  final transaction = Transaction(
    amount: 100.0,
    description: 'Test transaction',
    categoryId: 1,
    accountId: 1,
    date: DateTime.now(),
  );
  
  await appDB.safeInsert(transaction);
  
  final savedTransaction = await appDB.getTransaction(transaction.id!);
  expect(savedTransaction, isNotNull);
});
```

### Widget Tests

```dart
// Test widget with error handling
testWidgets('Transaction form should handle validation errors', (tester) async {
  await tester.pumpWidget(TransactionForm());
  
  // Try to save without required fields
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  
  // Verify error message is shown
  expect(find.text('Please fill in all required fields'), findsOneWidget);
});
```

---

## Best Practices

### Error Handling

1. **Always use the centralized ErrorHandler**
2. **Provide meaningful context for errors**
3. **Handle edge cases gracefully**
4. **Log errors appropriately**
5. **Show user-friendly error messages**

### Database Operations

1. **Use safe operations (safeInsert, safeUpdate, safeDelete)**
2. **Wrap operations in error handlers**
3. **Validate data before database operations**
4. **Use transactions for multiple operations**
5. **Backup data before major changes**

### Security

1. **Never log sensitive information**
2. **Use environment variables for secrets**
3. **Validate all user inputs**
4. **Implement proper authentication**
5. **Encrypt sensitive data**

### Performance

1. **Use async operations for I/O**
2. **Implement proper caching**
3. **Optimize database queries**
4. **Use pagination for large datasets**
5. **Monitor memory usage**

---

## Troubleshooting

### Common Issues

1. **Database connection errors**
   - Check if database file exists
   - Verify file permissions
   - Ensure proper initialization

2. **Firebase configuration errors**
   - Verify API keys in environment variables
   - Check Firebase project settings
   - Ensure proper authentication setup

3. **AI service errors**
   - Verify API key configuration
   - Check network connectivity
   - Ensure proper model initialization

4. **File operation errors**
   - Check file permissions
   - Verify file paths
   - Ensure proper error handling

### Debug Mode

Enable debug mode for detailed error information:

```dart
// Enable debug logging
Logger.enableDebugMode();

// Set log level
Logger.setLogLevel(LogLevel.debug);
```

---

## Support

For API-related questions and issues:

- **Documentation**: This file and inline code comments
- **Issues**: GitHub issues for API-related problems
- **Discussions**: GitHub discussions for API design
- **Security**: Report security issues privately

---

**Last Updated**: December 2024  
**Version**: 1.0 
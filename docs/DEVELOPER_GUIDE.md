# IntelliCash Developer Guide

## Overview

Welcome to the IntelliCash development team! This guide will help you get started with contributing to our AI-powered personal finance application. Whether you're a seasoned Flutter developer or just starting out, this guide will provide you with everything you need to know.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Project Architecture](#project-architecture)
3. [Development Environment](#development-environment)
4. [Coding Standards](#coding-standards)
5. [Testing Guidelines](#testing-guidelines)
6. [Debugging](#debugging)
7. [Performance Optimization](#performance-optimization)
8. [Security Best Practices](#security-best-practices)
9. [Deployment](#deployment)
10. [Troubleshooting](#troubleshooting)

---

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.22.3 or higher)
- **Dart SDK** (3.4.1 or higher)
- **Git** for version control
- **Android Studio** or **VS Code** with Flutter extensions
- **Firebase CLI** (optional, for Firebase operations)

### Initial Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/Sudoerz/IntelliCash.git
   cd IntelliCash
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate necessary code**
   ```bash
   # Generate database code
   flutter packages pub run build_runner build
   
   # Generate translations
   dart run slang
   
   # Generate icons
   flutter packages pub run flutter_launcher_icons
   ```

4. **Set up Firebase (if needed)**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

### First Run

```bash
# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Run with specific device
flutter run -d <device-id>
```

---

## Project Architecture

### Directory Structure

```
IntelliCash/
├── lib/
│   ├── app/                    # Main application modules
│   │   ├── accounts/          # Account management
│   │   ├── ai/               # AI integration
│   │   ├── budgets/          # Budget planning
│   │   ├── categories/       # Category management
│   │   ├── currencies/       # Currency handling
│   │   ├── home/            # Dashboard and main UI
│   │   ├── layout/          # Navigation and layout
│   │   ├── onboarding/      # User onboarding
│   │   ├── settings/        # App settings
│   │   ├── stats/           # Analytics and reports
│   │   ├── tags/            # Tag management
│   │   └── transactions/    # Transaction handling
│   ├── core/                 # Core functionality
│   │   ├── database/        # Database layer
│   │   ├── extensions/      # Dart extensions
│   │   ├── models/          # Data models
│   │   ├── presentation/    # UI components
│   │   ├── routes/          # Navigation routes
│   │   ├── services/        # Business logic
│   │   └── utils/           # Utility functions
│   ├── i18n/                # Internationalization
│   └── main.dart            # App entry point
├── assets/                   # Static assets
├── android/                  # Android-specific code
├── ios/                     # iOS-specific code
├── test/                    # Unit and widget tests
├── integration_test/         # Integration tests
└── docs/                    # Documentation
```

### Architecture Patterns

#### 1. **Service Layer Pattern**
- Business logic is separated into service classes
- Services handle data operations and external API calls
- Controllers/Widgets only handle UI logic

#### 2. **Repository Pattern**
- Database operations are abstracted through repositories
- Easy to switch between different data sources
- Centralized data access logic

#### 3. **Error Handling Pattern**
- Centralized error handling through `ErrorHandler`
- Consistent error reporting and user feedback
- Graceful degradation for different error types

#### 4. **Dependency Injection**
- Services are injected where needed
- Easy to mock for testing
- Loose coupling between components

### Key Components

#### ErrorHandler
Centralized error handling system used throughout the app.

```dart
// Example usage
await errorHandler.handleDatabaseOperation(
  () async => await database.insert(data),
  context: 'Inserting transaction',
);
```

#### AppDB
Main database class using Drift ORM for SQLite operations.

```dart
// Safe database operations
await appDB.safeInsert(transaction);
await appDB.safeUpdate(account);
await appDB.safeDelete(category);
```

#### KeyValueService
Persistent key-value storage for app settings and preferences.

```dart
// Store and retrieve values
await keyValueService.setItem('theme', 'dark');
final theme = await keyValueService.getItem('theme');
```

---

## Development Environment

### IDE Setup

#### VS Code (Recommended)

1. **Install Extensions**
   - Flutter
   - Dart
   - Flutter Widget Snippets
   - Error Lens
   - GitLens

2. **Settings**
   ```json
   {
     "dart.lineLength": 80,
     "dart.enableSdkFormatter": true,
     "editor.formatOnSave": true,
     "editor.codeActionsOnSave": {
       "source.fixAll": true
     }
   }
   ```

#### Android Studio

1. **Install Plugins**
   - Flutter
   - Dart
   - Flutter Inspector

2. **Configure**
   - Enable auto-import
   - Set up code formatting
   - Configure debugging

### Code Generation

The project uses several code generation tools:

```bash
# Generate database code
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch

# Clean generated files
flutter packages pub run build_runner clean

# Generate translations
dart run slang

# Generate icons
flutter packages pub run flutter_launcher_icons
```

### Hot Reload

Use hot reload for faster development:

```bash
# Start with hot reload
flutter run --hot

# Or use 'r' in the terminal to hot reload
# Use 'R' for hot restart
```

---

## Coding Standards

### Dart/Flutter Conventions

#### 1. **Naming Conventions**
```dart
// Classes: PascalCase
class TransactionService {}

// Variables and functions: camelCase
final transactionAmount = 100.0;
void calculateTotal() {}

// Constants: SCREAMING_SNAKE_CASE
const MAX_RETRY_ATTEMPTS = 3;

// Private members: underscore prefix
class _PrivateClass {}
void _privateMethod() {}
```

#### 2. **File Organization**
```dart
// 1. Imports (dart, flutter, packages, local)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intellicash/core/services/error_handler.dart';

// 2. Class definition
class MyWidget extends StatelessWidget {
  // 3. Constants
  static const double _padding = 16.0;
  
  // 4. Fields
  final String title;
  
  // 5. Constructor
  const MyWidget({super.key, required this.title});
  
  // 6. Methods
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

#### 3. **Error Handling**
Always use the centralized ErrorHandler:

```dart
// Good
await errorHandler.handleDatabaseOperation(
  () async => await database.insert(data),
  context: 'Inserting transaction',
);

// Bad
try {
  await database.insert(data);
} catch (e) {
  print('Error: $e');
}
```

#### 4. **Documentation**
```dart
/// A service for managing user transactions.
/// 
/// This service provides methods for creating, updating, and deleting
/// transactions with proper error handling and validation.
class TransactionService {
  /// Creates a new transaction in the database.
  /// 
  /// [transaction] The transaction to create.
  /// [context] Optional context for error handling.
  /// 
  /// Returns the created transaction with an ID.
  /// 
  /// Throws [DatabaseException] if the operation fails.
  Future<Transaction> createTransaction(
    Transaction transaction, {
    String? context,
  }) async {
    // Implementation
  }
}
```

### Code Quality

#### 1. **Linting**
The project uses `flutter_lints` for code quality:

```bash
# Run linter
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

#### 2. **Formatting**
```bash
# Format all Dart files
dart format .

# Format specific file
dart format lib/main.dart
```

#### 3. **Type Safety**
Always use strong typing:

```dart
// Good
final List<Transaction> transactions = [];
final String? optionalValue = null;

// Bad
final transactions = [];
final optionalValue = null;
```

---

## Testing Guidelines

### Test Structure

#### 1. **Unit Tests**
```dart
// test/services/transaction_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:intellicash/core/services/transaction_service.dart';

void main() {
  group('TransactionService', () {
    late TransactionService service;
    
    setUp(() {
      service = TransactionService();
    });
    
    test('should create transaction successfully', () async {
      // Arrange
      final transaction = Transaction(
        amount: 100.0,
        description: 'Test',
        categoryId: 1,
        accountId: 1,
        date: DateTime.now(),
      );
      
      // Act
      final result = await service.createTransaction(transaction);
      
      // Assert
      expect(result.id, isNotNull);
      expect(result.amount, equals(100.0));
    });
    
    test('should handle database errors gracefully', () async {
      // Arrange
      final invalidTransaction = Transaction(
        amount: -100.0, // Invalid amount
        description: '',
        categoryId: 0,
        accountId: 0,
        date: DateTime.now(),
      );
      
      // Act & Assert
      expect(
        () => service.createTransaction(invalidTransaction),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
```

#### 2. **Widget Tests**
```dart
// test/widgets/transaction_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intellicash/app/transactions/widgets/transaction_card.dart';

void main() {
  group('TransactionCard', () {
    testWidgets('should display transaction details', (tester) async {
      // Arrange
      final transaction = Transaction(
        amount: 100.0,
        description: 'Grocery shopping',
        categoryId: 1,
        accountId: 1,
        date: DateTime.now(),
      );
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TransactionCard(transaction: transaction),
        ),
      );
      
      // Assert
      expect(find.text('Grocery shopping'), findsOneWidget);
      expect(find.text('\$100.00'), findsOneWidget);
    });
    
    testWidgets('should handle tap events', (tester) async {
      // Arrange
      bool tapped = false;
      final transaction = Transaction(/* ... */);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TransactionCard(
            transaction: transaction,
            onTap: () => tapped = true,
          ),
        ),
      );
      
      await tester.tap(find.byType(Card));
      await tester.pump();
      
      // Assert
      expect(tapped, isTrue);
    });
  });
}
```

#### 3. **Integration Tests**
```dart
// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intellicash/main.dart' as app;

void main() {
  group('App Integration Tests', () {
    testWidgets('should navigate through main flows', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      
      // Act & Assert - Navigate to transactions
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      expect(find.byType(TransactionForm), findsOneWidget);
      
      // Fill form and save
      await tester.enterText(
        find.byKey(const Key('amount_field')),
        '100.0',
      );
      await tester.enterText(
        find.byKey(const Key('description_field')),
        'Test transaction',
      );
      
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      
      // Verify transaction was created
      expect(find.text('Test transaction'), findsOneWidget);
    });
  });
}
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/transaction_service_test.dart

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/

# Run tests on specific device
flutter test -d <device-id>
```

### Test Coverage

Maintain high test coverage:
- **Unit tests**: 80%+ coverage
- **Widget tests**: All UI components
- **Integration tests**: Critical user flows

---

## Debugging

### Debug Tools

#### 1. **Flutter Inspector**
```bash
# Open Flutter Inspector
flutter run --debug
```

#### 2. **Logging**
```dart
// Use the Logger utility
Logger.printDebug('Debug message');
Logger.printInfo('Info message');
Logger.printWarning('Warning message');
Logger.printError('Error message');
```

#### 3. **Error Handling**
```dart
// Debug error handling
errorHandler.handleError(
  error,
  stackTrace,
  type: ErrorHandler.ErrorType.database,
  severity: ErrorHandler.ErrorSeverity.high,
  context: 'Debug operation',
);
```

### Common Debugging Scenarios

#### 1. **Database Issues**
```dart
// Check database state
final isValid = await appDB.validateDatabase();
print('Database valid: $isValid');

// Check database file
final dbFile = await appDB.getDatabaseFile();
print('Database file: ${dbFile.path}');
```

#### 2. **UI Issues**
```dart
// Debug widget tree
debugPrint('Widget tree: ${context.findAncestorWidgetOfExactType<MaterialApp>()}');

// Debug layout
debugPrint('Layout constraints: ${context.findRenderObject()?.constraints}');
```

#### 3. **Performance Issues**
```dart
// Profile performance
import 'package:flutter/foundation.dart';

void expensiveOperation() {
  final stopwatch = Stopwatch()..start();
  
  // Your expensive operation
  
  stopwatch.stop();
  debugPrint('Operation took: ${stopwatch.elapsedMilliseconds}ms');
}
```

---

## Performance Optimization

### 1. **Widget Optimization**

#### Use const constructors
```dart
// Good
const MyWidget({super.key});

// Bad
MyWidget({super.key});
```

#### Minimize rebuilds
```dart
// Use ValueNotifier for simple state
final ValueNotifier<int> counter = ValueNotifier(0);

// Use ChangeNotifier for complex state
class MyState extends ChangeNotifier {
  int _counter = 0;
  int get counter => _counter;
  
  void increment() {
    _counter++;
    notifyListeners();
  }
}
```

### 2. **Database Optimization**

#### Use batch operations
```dart
// Good
await appDB.safeBatch(() async {
  for (final transaction in transactions) {
    await appDB.insert(transaction);
  }
});

// Bad
for (final transaction in transactions) {
  await appDB.insert(transaction);
}
```

#### Optimize queries
```dart
// Use specific columns
final results = await appDB.select(appDB.transactions)
  .addColumns([appDB.transactions.amount, appDB.transactions.description])
  .get();

// Use indexes
final results = await appDB.select(appDB.transactions)
  .where((t) => t.date.isBetween(startDate, endDate))
  .get();
```

### 3. **Memory Management**

#### Dispose resources
```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription _subscription;
  
  @override
  void initState() {
    super.initState();
    _subscription = stream.listen((data) {
      // Handle data
    });
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

---

## Security Best Practices

### 1. **Input Validation**
```dart
// Always validate user input
final amount = safeParseDouble(input, context: 'Transaction amount');
if (amount == null || amount <= 0) {
  throw ValidationException('Invalid amount');
}
```

### 2. **Secure Storage**
```dart
// Use secure storage for sensitive data
final secureStorage = FlutterSecureStorage();
await secureStorage.write(key: 'api_key', value: apiKey);
final storedKey = await secureStorage.read(key: 'api_key');
```

### 3. **Environment Variables**
```dart
// Use environment variables for secrets
final apiKey = const String.fromEnvironment('API_KEY');
if (apiKey.isEmpty) {
  throw Exception('API key not configured');
}
```

### 4. **Error Handling**
```dart
// Never expose sensitive information in errors
errorHandler.handleError(
  error,
  stackTrace,
  type: ErrorHandler.ErrorType.authentication,
  severity: ErrorHandler.ErrorSeverity.high,
  context: 'Authentication failed',
);
```

---

## Deployment

### 1. **Build Configuration**

#### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Build for specific architecture
flutter build apk --target-platform android-arm64 --release
```

#### iOS
```bash
# Build for iOS
flutter build ios --release

# Archive for App Store
flutter build ipa --release
```

### 2. **Version Management**
```bash
# Update version
./scripts/update_version.sh 7.5.2

# Windows
.\scripts\update_version.ps1 7.5.2
```

### 3. **Testing Before Release**
```bash
# Run all tests
flutter test

# Run integration tests
flutter test integration_test/

# Analyze code
flutter analyze

# Check dependencies
flutter pub deps
```

### 4. **Release Checklist**
- [ ] All tests pass
- [ ] Code analysis clean
- [ ] Version updated
- [ ] Changelog updated
- [ ] Documentation updated
- [ ] Security review completed
- [ ] Performance tested
- [ ] UI/UX reviewed

---

## Troubleshooting

### Common Issues

#### 1. **Build Issues**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter packages pub run build_runner build
```

#### 2. **Database Issues**
```bash
# Reset database
flutter packages pub run build_runner clean
flutter packages pub run build_runner build
```

#### 3. **Dependency Issues**
```bash
# Update dependencies
flutter pub upgrade

# Check for conflicts
flutter pub deps
```

#### 4. **Performance Issues**
```bash
# Profile the app
flutter run --profile

# Analyze performance
flutter run --trace-startup
```

### Getting Help

1. **Check Documentation**
   - README.md
   - API.md
   - VERSIONING.md

2. **Search Issues**
   - GitHub issues
   - Stack Overflow

3. **Ask for Help**
   - GitHub discussions
   - Discord community
   - Team meetings

---

## Contributing Workflow

### 1. **Create Feature Branch**
```bash
git checkout -b feature/your-feature-name
```

### 2. **Make Changes**
- Follow coding standards
- Write tests
- Update documentation

### 3. **Test Changes**
```bash
flutter test
flutter analyze
flutter test integration_test/
```

### 4. **Commit Changes**
```bash
git add .
git commit -m "feat: add new transaction validation

- Add input validation for transaction amounts
- Include unit tests for validation logic
- Update documentation with new validation rules"
```

### 5. **Push and Create PR**
```bash
git push origin feature/your-feature-name
```

### 6. **Review Process**
- Code review by team members
- Address feedback
- Merge when approved

---

## Resources

### Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Drift Documentation](https://drift.simonbinder.eu/)
- [Firebase Documentation](https://firebase.google.com/docs)

### Tools
- [Flutter Inspector](https://docs.flutter.dev/development/tools/devtools/inspector)
- [Flutter Performance](https://docs.flutter.dev/development/tools/devtools/performance)
- [Flutter Memory](https://docs.flutter.dev/development/tools/devtools/memory)

### Community
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Reddit r/FlutterDev](https://www.reddit.com/r/FlutterDev/)

---

**Last Updated**: December 2024  
**Version**: 1.0 
<!-- PROJECT LOGO -->
<br />
<div align="center">
    <img src="assets/resources/appIcon.png"  alt="App Icon" width="100" height="100">

  <h1 align="center">IntelliCash - AI Personal Finance Guide</h1>

  <p align="center">
    IntelliCash is a next-gen personal finance platform powered by Google Cloud services like Firebase and Vertex AI, delivering enterprise-grade financial intelligence with consumer-level simplicity.
    <br />
    <a href="#about-the-project"><strong>Start exploring »</strong></a>
    <br />
  </p>
</div>

<!-- TABLE OF CONTENTS -->

  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#-why-intellicash">Why IntelliCash?</a></li>
        <li><a href="#-core-google-cloud-integrations">Core Google Cloud Integrations</a></li>
        <li><a href="#-hybrid-ai-architecture">Hybrid AI Architecture</a></li>
        <li><a href="#-enhanced-technical-stack">Enhanced Technical Stack</a></li>
        <li><a href="#-key-features">Key Features</a></li>
      </ul>
    </li>
    <li>
      <a href="#run-the-code-locally-">Run the code locally</a>
      <ul>
        <li><a href="#prerequisites-%EF%B8%8F">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
        <li><a href="#security-setup">Security Setup</a></li>
        <li><a href="#development-setup">Development Setup</a></li>
      </ul>
    </li>
    <li>
      <a href="#api-documentation">API Documentation</a>
      <ul>
        <li><a href="#core-services">Core Services</a></li>
        <li><a href="#database-operations">Database Operations</a></li>
        <li><a href="#error-handling">Error Handling</a></li>
        <li><a href="#ai-integration">AI Integration</a></li>
      </ul>
    </li>
    <li>
      <a href="#contributing-">Contributing</a>
      <ul>
        <li><a href="#how-to-get-started">How to get started</a></li>
        <li><a href="#development-guidelines">Development Guidelines</a></li>
        <li><a href="#testing">Testing</a></li>
        <li><a href="#why-to-contribute-">Why to contribute?</a></li>
      </ul>
    </li>
    <li>
      <a href="#project-structure">Project Structure</a>
    </li>
    <li>
      <a href="#versioning">Versioning</a>
    </li>
  </ol>

## About the project

### 📸 Screenshots

|                                                                                                                    |                                                                                                                    |                                                                                                                    |                                                                                                                    |
| :----------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------: |
| ![1](https://github.com/enrique-lozano/Monekin/blob/main/app-marketplaces/screenshots/en/Mockups/Diapositiva1.PNG) | ![2](https://github.com/enrique-lozano/Monekin/blob/main/app-marketplaces/screenshots/en/Mockups/Diapositiva2.PNG) | ![3](https://github.com/enrique-lozano/Monekin/blob/main/app-marketplaces/screenshots/en/Mockups/Diapositiva3.PNG) | ![4](https://github.com/enrique-lozano/Monekin/blob/main/app-marketplaces/screenshots/en/Mockups/Diapositiva4.PNG) |
| ![5](https://github.com/enrique-lozano/Monekin/blob/main/app-marketplaces/screenshots/en/Mockups/Diapositiva5.PNG) | ![6](https://github.com/enrique-lozano/Monekin/blob/main/app-marketplaces/screenshots/en/Mockups/Diapositiva6.PNG) |

### 🌟 Why IntelliCash? 

- **Hybrid AI Intelligence**  
  Combines on-device ML processing with cloud-based AI models for smart financial analysis.
- **Google Cloud Powered**  
  Leverages Firebase, Cloud Functions, and BigQuery to deliver secure, scalable, real-time insights.
- **Smart Transaction Categorization**  
  Achieves 98% accuracy using a blend of local ML models and Vertex AI.
- **Natural Language Queries**  
  Ask questions like "Show food spending last month" using built-in NLP support.
- **Predictive Forecasting**  
  Uses Vertex AI to provide future budget estimates based on spending patterns.
- **Scalable Data Handling**  
  Handles millions of transactions using Firestore and Cloud SQL.
- **Cross-Device Sync**  
  Seamless real-time data synchronization across all your devices.
- **Advanced Security**  
  End-to-end encryption, IAM, and Google Cloud Secret Manager integration.
- **Open Source First**  
  Built with transparency and privacy in mind—local-first where possible.

### 🚀 Core Google Cloud Integrations

1. **Firebase Platform**
   - Secure authentication (OAuth, biometrics, 2FA)
   - Firestore with offline sync
   - Cloud Functions for backend automation
   - Crashlytics for bug and crash tracking

2. **Vertex AI Services**
   - Custom-trained classification models
   - AutoML Tables for time-series forecasting
   - Natural language understanding for finance
   - Anomaly detection for fraud and outliers

3. **Google Cloud Infrastructure**
   - Microservices with Cloud Run
   - Pub/Sub for real-time event streaming
   - Secret Manager for key management
   - Cloud SQL and BigQuery for data analytics

### 🔄 Hybrid AI Architecture

**Data Flow:**

`[Device] → [Firebase] → [Cloud Functions] → [Vertex AI] → [BigQuery] ↑____________↓ ↑ [Local SQLite]`

**Architecture Highlights:**

- **Local Intelligence**
  - Offline transaction tracking using SQLite
  - On-device models with TensorFlow Lite

- **Cloud Augmentation**
  - Cloud model inference via Vertex AI
  - Real-time sync through Firestore

- **Security-First Design**
  - IAM, encryption at rest, and audit logging

### 🔧 Enhanced Technical Stack

**Frontend:**
- Flutter with Firebase integration
- Google Maps for location tagging
- Interactive charts via Google Charts

**Backend Services:**
- Cloud Run containers
- Cloud Scheduler for automation
- Memorystore (Redis) for caching

**Data Pipeline:**
- Dataflow for ETL
- BigQuery for advanced analytics
- Looker Studio for dashboards

**ML Operations:**
- Vertex AI Pipelines for MLOps
- Model monitoring and auto-retraining

### ✨ Key Features

#### 📊 **Financial Management**
- **Transaction Tracking**: Record and categorize all income and expenses
- **Budget Planning**: Set monthly budgets with smart recommendations
- **Multi-Currency Support**: Handle transactions in multiple currencies
- **Recurring Transactions**: Automate regular payments and income
- **Export & Import**: CSV export/import for data portability

#### 🤖 **AI-Powered Features**
- **Smart Categorization**: Automatic transaction categorization with 98% accuracy
- **Natural Language Queries**: Ask questions like "Show food spending last month"
- **Predictive Analytics**: AI-driven spending forecasts and budget recommendations
- **Anomaly Detection**: Identify unusual spending patterns
- **Chat Interface**: Conversational AI for financial insights

#### 📱 **User Experience**
- **Cross-Platform**: Works on Android, iOS, and Web
- **Offline Support**: Full functionality without internet connection
- **Real-time Sync**: Instant updates across all devices
- **Dark Mode**: Comfortable viewing in any lighting
- **Accessibility**: Screen reader support and keyboard navigation

#### 🔒 **Security & Privacy**
- **Local-First**: Data stored locally with optional cloud sync
- **End-to-End Encryption**: All sensitive data encrypted
- **Biometric Authentication**: Fingerprint and face unlock support
- **Private Mode**: Hide sensitive transactions
- **Backup & Restore**: Secure data backup and recovery

---

## Run the code locally 🚀🧑‍💻

IntelliCash is fully open-source and easy to set up locally. Whether you're contributing, learning, or exploring—you're welcome here!

### Prerequisites 🛠️

1. **Flutter SDK** – Install from the [official guide](https://docs.flutter.dev/get-started/install)
2. **Code Editor (Optional)** – [VS Code](https://code.visualstudio.com/) or Android Studio recommended
3. **Git** – For version control
4. **Android Studio / Xcode** – For mobile development

### Getting the Project 📂

**Option 1: Download as ZIP**
- Go to the [IntelliCash GitHub Repo](https://github.com/Sudoerz/IntelliCash)
- Click **Code** > **Download ZIP**
- Extract to your desired folder

**Option 2: Clone the Repo**
```bash
git clone https://github.com/Sudoerz/IntelliCash
cd IntelliCash
```

### Installation 📦

Navigate to the project folder and install dependencies:

```bash
flutter pub get
```

### Security Setup 🔐

**Important:** Before running the app, you need to configure Firebase and keystore files securely.

#### 1. Firebase Configuration

Create a `.env` file in the project root with your Firebase credentials:

```bash
FIREBASE_API_KEY=your_api_key_here
FIREBASE_APP_ID=your_app_id_here
FIREBASE_SENDER_ID=your_sender_id_here
FIREBASE_PROJECT_ID=your_project_id_here
FIREBASE_STORAGE_BUCKET=your_storage_bucket_here
```

**Or** use FlutterFire CLI for automatic configuration:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

#### 2. Keystore Setup (For Release Builds)

For Android release builds, create a keystore file:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then create `android/key.properties`:

```properties
storePassword=<your_keystore_password>
keyPassword=<your_key_password>
keyAlias=upload
storeFile=<path_to_keystore>/upload-keystore.jks
```

**⚠️ Security Notes:**
- Never commit `.env`, `*.jks`, or `key.properties` files
- Store keystore files in secure local storage
- Use environment variables for sensitive data
- The `.gitignore` file already excludes these sensitive files

### Development Setup 🛠️

#### 1. Code Generation

Generate necessary code files:

```bash
# Generate database code
flutter packages pub run build_runner build

# Generate translations
dart run slang

# Generate icons
flutter packages pub run flutter_launcher_icons
```

#### 2. Database Setup

The app uses SQLite with Drift ORM. Database migrations are handled automatically:

```bash
# Check database status
flutter packages pub run drift_dev --help
```

#### 3. Testing

Run tests to ensure everything works:

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widget_test.dart
```

### Run the App ▶️

Run the app on an emulator or connected device:

```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Profile mode (for performance testing)
flutter run --profile
```

---

## API Documentation 📚

### Core Services

#### ErrorHandler
Centralized error handling system for the entire application.

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
```

#### Database Operations
Safe database operations with automatic error handling.

```dart
// Safe database operations
await appDB.safeInsert(transaction);
await appDB.safeUpdate(account);
await appDB.safeDelete(category);

// Batch operations
await appDB.safeBatch(() async {
  // Multiple database operations
});
```

#### Key-Value Service
Persistent key-value storage with error handling.

```dart
// Set and get values
await keyValueService.setItem('user_preference', 'value');
final value = await keyValueService.getItem('user_preference');

// Batch updates
await keyValueService.batchUpdate({
  'setting1': 'value1',
  'setting2': 'value2',
});
```

### Database Operations

#### Transaction Management
```dart
// Create transaction
final transaction = Transaction(
  amount: 100.0,
  description: 'Grocery shopping',
  categoryId: 1,
  accountId: 1,
  date: DateTime.now(),
);

// Insert with error handling
await errorHandler.handleDatabaseOperation(
  () async => await appDB.safeInsert(transaction),
  context: 'Creating transaction',
);
```

#### Account Management
```dart
// Create account
final account = Account(
  name: 'Main Account',
  type: AccountType.bank,
  balance: 1000.0,
  currency: 'USD',
);

// Update account balance
await appDB.safeUpdate(account.copyWith(balance: newBalance));
```

#### Category Management
```dart
// Create category
final category = Category(
  name: 'Food & Dining',
  icon: 'restaurant',
  color: Colors.orange,
  parentId: null,
);

// Get categories with subcategories
final categories = await appDB.getCategoriesWithSubcategories();
```

### Error Handling

#### Error Types
- `ErrorType.network`: Network-related errors
- `ErrorType.database`: Database operation errors
- `ErrorType.validation`: Input validation errors
- `ErrorType.authentication`: Authentication errors
- `ErrorType.fileSystem`: File system errors
- `ErrorType.unknown`: Unknown errors

#### Error Severity
- `ErrorSeverity.low`: Minor issues, no user action needed
- `ErrorSeverity.medium`: Moderate issues, user should be informed
- `ErrorSeverity.high`: Important issues, user action may be required
- `ErrorSeverity.critical`: Critical issues, app may be unusable

#### Usage Examples
```dart
// Handle validation errors
final result = errorHandler.handleValidation(
  () => validateInput(input),
  context: 'Input validation',
  showUserMessage: true,
);

// Handle file operations
await errorHandler.handleFileOperation(
  () async => await file.writeAsString(content),
  context: 'Saving file',
);
```

### AI Integration

#### Google Generative AI
```dart
// Initialize AI service
final aiService = GoogleGenerativeAI(apiKey: apiKey);
final model = aiService.getGenerativeModel(model: 'gemini-pro');

// Generate response
final response = await model.generateContent([
  Content.text('Analyze my spending patterns'),
]);
```

#### Natural Language Processing
```dart
// Process user query
final query = 'Show food spending last month';
final processedQuery = await aiService.processQuery(query);

// Get categorized results
final results = await aiService.getCategorizedResults(processedQuery);
```

---

## Contributing 🙋🏻

### How to get started

1. **Fork the repo**

New to forking? Use [this GitHub guide](https://docs.github.com/en/get-started/quickstart/fork-a-repo) to fork and set up your copy.

2. **Set up your workspace**

Clone your fork locally, then open it using your preferred code editor.

We recommend **Visual Studio Code**, along with the Flutter extension pack. Type `@recommended` in the extensions tab to install all project-recommended tools.

3. **Create a feature branch**

```bash
git checkout -b feature/your-feature-name
```

4. **Make your changes**

Follow the development guidelines below.

5. **Test your changes**

```bash
flutter test
flutter analyze
```

6. **Submit a pull request**

Create a detailed pull request with:
- Description of changes
- Screenshots (if UI changes)
- Test results
- Any breaking changes

### Development Guidelines

#### Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

#### Error Handling
- Always use the centralized `ErrorHandler`
- Provide meaningful error messages
- Handle edge cases gracefully
- Log errors appropriately

#### Testing
- Write unit tests for business logic
- Add widget tests for UI components
- Include integration tests for critical flows
- Test error scenarios

#### Documentation
- Update README.md for new features
- Add API documentation for new services
- Include usage examples
- Update changelog for releases

### Testing

#### Unit Tests
```bash
# Run all unit tests
flutter test

# Run specific test file
flutter test test/services/error_handler_test.dart

# Run with coverage
flutter test --coverage
```

#### Widget Tests
```bash
# Run widget tests
flutter test test/widget_test.dart

# Run specific widget test
flutter test test/widgets/transaction_card_test.dart
```

#### Integration Tests
```bash
# Run integration tests
flutter test integration_test/

# Run on specific device
flutter test integration_test/ -d <device-id>
```

### Why to contribute 🙌

Contributing to IntelliCash gives you a chance to:

- 🚀 Learn practical Flutter + Firebase development
- 🌍 Work with an open-source community
- 🔧 Understand full-stack cloud-native architectures
- 💼 Build your GitHub portfolio with meaningful contributions
- 💡 Help people take control of their finances with AI

All skill levels are welcome — whether you're fixing typos, improving UI, writing docs, or building features.

---

## Project Structure 📁

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

---

## Versioning 📋

IntelliCash follows [Semantic Versioning](https://semver.org/) principles:

- **MAJOR.MINOR.PATCH** format
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes and security updates

### Current Version: `7.5.1+750001`

For detailed versioning information, see [VERSIONING.md](VERSIONING.md) and [CHANGELOG.md](CHANGELOG.md).

### Version Management

Use the provided scripts to update versions:

```bash
# Unix/Linux/macOS
./scripts/update_version.sh 7.5.2

# Windows PowerShell
.\scripts\update_version.ps1 7.5.2

# Dry run to see changes
./scripts/update_version.sh 7.5.3 --dry-run
```

---

**Credits:**  
- [Google Cloud](https://cloud.google.com/) – for cloud infrastructure and AI services.
- [Firebase](https://firebase.google.com/) – for authentication, database, and analytics.
- [Monekin](https://github.com/enrique-lozano/Monekin) – for financial tracking design and structure.
- [Vertex AI](https://cloud.google.com/vertex-ai) – for integrating generative AI capabilities.
- [Chroma DB](https://www.trychroma.com/) – for vector search and semantic memory.
- [MCP](https://mcp.sudomate.ai/) – for natural language SQL and fast API workflows.


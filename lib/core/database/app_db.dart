import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:intellicash/core/database/connection/connection.dart';
import 'package:intellicash/core/database/services/category/category_service.dart';
import 'package:intellicash/core/database/services/currency/currency_service.dart';
import 'package:intellicash/core/database/services/shared/key_value_service.dart';
import 'package:intellicash/core/database/services/user-setting/app_data_service.dart';
import 'package:intellicash/core/database/services/user-setting/user_setting_service.dart';
import 'package:intellicash/core/database/sql/initial_categories.dart';
import 'package:intellicash/core/database/sql/initial_currencies.dart';
import 'package:intellicash/core/database/sql/migrations/v5.dart';
import 'package:intellicash/core/database/sql/migrations/v6.dart';
import 'package:intellicash/core/database/sql/migrations/v7.dart';
import 'package:intellicash/core/database/sql/settings_initial_seed.dart';
import 'package:intellicash/core/utils/error_handler.dart';
import 'package:intellicash/core/utils/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_db.g.dart';

@DriftDatabase(tables: [
  // ... existing tables ...
])
class AppDB extends _$AppDB {
  static final AppDB _instance = AppDB._internal();
  factory AppDB() => _instance;
  AppDB._internal() : super(_openConnection());

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'intellicash.db'));
      return NativeDatabase.createInBackground(file);
    });
  }

  final String dbName;
  final bool inMemory;
  final bool logStatements;

  /// Get the path to the DB, that is `xxxx/xxxx/.../filename.db`
  Future<String> get databasePath async =>
      p.join((await getApplicationDocumentsDirectory()).path, dbName);

  Future<void> migrateDB(int from, int to) async {
    return errorHandler.handleDatabaseOperation(
      () async {
        Logger.printDebug('Executing migrations from previous version...');

        for (var i = from + 1; i <= to; i++) {
          Logger.printDebug('Migrating database from v$from to v$i...');

          String initialSQL =
              await rootBundle.loadString('assets/sql/migrations/v$i.sql');

          for (final sqlStatement in splitSQLStatements(initialSQL)) {
            Logger.printDebug('Running custom statement: $sqlStatement');
            await customStatement(sqlStatement);
          }

          await AppDataService.instance
              .setItem(AppDataKey.dbVersion, i.toStringAsFixed(0));
        }

        Logger.printDebug('Migration completed!');
      },
      context: 'Migrating database from v$from to v$to',
    );
  }

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        return errorHandler.handleDatabaseOperation(
          () async {
            Logger.printDebug(
                'DB found! Version ${details.versionNow} (previous was ${details.versionBefore}). Path to DB -> ${await databasePath}');

            if (details.wasCreated) {
              Logger.printDebug('Executing seeders... Populating the database...');

              try {
                final initialDbSeedersStatements = [
                  settingsInitialSeedSQL,
                  appDataInitialSeedSQL(schemaVersion)
                ];

                for (final sqlStatement in initialDbSeedersStatements) {
                  await customStatement(sqlStatement);
                }

                await CategoryService.instance.initializeCategories();
                await CurrencyService.instance.initializeCurrencies();

                Logger.printDebug('Initial data correctly inserted!');
              } catch (e) {
                Logger.printDebug('ERROR: $e');
                throw Exception('Failed to initialize database: $e');
              }
            }

            await customStatement('PRAGMA foreign_keys = ON');
          },
          context: 'Opening database',
        );
      },
    );
  }

  /// Safely execute custom SQL statements
  Future<void> safeCustomStatement(String sql) async {
    return errorHandler.handleDatabaseOperation(
      () async {
        await customStatement(sql);
      },
      context: 'Executing custom SQL: ${sql.substring(0, sql.length > 50 ? 50 : sql.length)}...',
    );
  }

  /// Safely execute queries with error handling
  Future<List<T>> safeSelect<T>(
    Query<T> query, {
    String? context,
  }) async {
    return errorHandler.handleDatabaseOperation(
      () async {
        return await query.get();
      },
      context: context ?? 'Executing select query',
      defaultValue: <T>[],
    );
  }

  /// Safely execute inserts with error handling
  Future<int> safeInsert<T extends Table>(
    Insertable<T> insertable, {
    String? context,
  }) async {
    return errorHandler.handleDatabaseOperation(
      () async {
        return await into(this.getTable<T>()).insert(insertable);
      },
      context: context ?? 'Executing insert operation',
      defaultValue: -1,
    );
  }

  /// Safely execute updates with error handling
  Future<int> safeUpdate<T extends Table>(
    Updateable<T> updateable, {
    String? context,
  }) async {
    return errorHandler.handleDatabaseOperation(
      () async {
        return await update(this.getTable<T>()).replace(updateable);
      },
      context: context ?? 'Executing update operation',
      defaultValue: 0,
    );
  }

  /// Safely execute deletes with error handling
  Future<int> safeDelete<T extends Table>(
    Expression<bool> Function(T) filter, {
    String? context,
  }) async {
    return errorHandler.handleDatabaseOperation(
      () async {
        return await (delete(this.getTable<T>())..where(filter)).go();
      },
      context: context ?? 'Executing delete operation',
      defaultValue: 0,
    );
  }

  /// Safely execute batch operations
  Future<void> safeBatch(Future<void> Function(Batch) batchOperation, {
    String? context,
  }) async {
    return errorHandler.handleDatabaseOperation(
      () async {
        final batch = this.batch();
        await batchOperation(batch);
        await batch.commit();
      },
      context: context ?? 'Executing batch operation',
    );
  }

  /// Validate database integrity
  Future<bool> validateDatabase() async {
    return errorHandler.handleDatabaseOperation(
      () async {
        try {
          // Check if database file exists
          final dbPath = await databasePath;
          final dbFile = File(dbPath);
          
          if (!await dbFile.exists()) {
            throw Exception('Database file not found');
          }

          // Check if we can read from the database
          final result = await customSelect('SELECT 1').getSingle();
          return result.data.isNotEmpty;
        } catch (e) {
          Logger.printDebug('Database validation failed: $e');
          return false;
        }
      },
      context: 'Validating database integrity',
      defaultValue: false,
    );
  }

  /// Backup database with error handling
  Future<bool> backupDatabase(String backupPath) async {
    return errorHandler.handleDatabaseOperation(
      () async {
        final dbPath = await databasePath;
        final dbFile = File(dbPath);
        
        if (!await dbFile.exists()) {
          throw Exception('Database file not found');
        }

        final backupFile = File(backupPath);
        await dbFile.copy(backupFile.path);
        
        Logger.printDebug('Database backed up to: $backupPath');
        return true;
      },
      context: 'Backing up database',
      defaultValue: false,
    );
  }

  /// Restore database from backup with error handling
  Future<bool> restoreDatabase(String backupPath) async {
    return errorHandler.handleDatabaseOperation(
      () async {
        final backupFile = File(backupPath);
        
        if (!await backupFile.exists()) {
          throw Exception('Backup file not found');
        }

        final dbPath = await databasePath;
        final currentDbFile = File(dbPath);
        
        // Create backup of current database
        if (await currentDbFile.exists()) {
          final currentBackup = '${dbPath}_restore_backup_${DateTime.now().millisecondsSinceEpoch}';
          await currentDbFile.copy(currentBackup);
        }

        // Restore from backup
        await backupFile.copy(dbPath);
        
        Logger.printDebug('Database restored from: $backupPath');
        return true;
      },
      context: 'Restoring database from backup',
      defaultValue: false,
    );
  }
}

LazyDatabase openConnection(String dbName, {bool logStatements = false}) {
  return LazyDatabase(() async {
    // Should be in the same route as the indicated in the databasePath getter of the AppDB class
    final file =
        File(join((await getApplicationDocumentsDirectory()).path, dbName));

    return NativeDatabase.createBackgroundConnection(file,
        logStatements: logStatements);
  });
}

/// Splits a string containing multiple SQL statements into a list of individual statements.
///
/// This function takes a string of SQL commands separated by semicolons and
/// splits them into individual statements.
///
/// Example:
/// ```dart
/// String sql = "CREATE TABLE users (id INT); INSERT INTO users (id) VALUES (1);";
/// List<String> statements = splitSQLStatements(sql);
/// Logger.printDebug(statements); // Output: ["CREATE TABLE users (id INT)", "INSERT INTO users (id) VALUES (1)"]
/// ```
///
/// [sqliteStr] - The input string containing multiple SQL statements.
///
/// Returns a list of individual SQL statements.
List<String> splitSQLStatements(String sqliteStr) {
  return sqliteStr
      .split(RegExp(r';\s'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

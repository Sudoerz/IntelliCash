import 'dart:io';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:intellicash/core/database/app_db.dart';
import 'package:intellicash/core/database/services/app-data/app_data_service.dart';
import 'package:intellicash/core/utils/error_handler.dart';
import 'package:intellicash/core/utils/logger.dart';
import 'package:intellicash/i18n/generated/translations.g.dart';

class BackupDatabaseService {
  static final BackupDatabaseService _instance = BackupDatabaseService._internal();
  factory BackupDatabaseService() => _instance;
  BackupDatabaseService._internal();

  final AppDB db = AppDB.instance;

  Future<bool> exportDatabase() async {
    return errorHandler.handleDatabaseOperation(
      () async {
        final dbPath = await db.databasePath;
        final dbFile = File(dbPath);

        if (!await dbFile.exists()) {
          throw Exception('Database file not found');
        }

        final result = await FilePicker.platform.saveFile(
          dialogTitle: t.backup.export.title,
          fileName: 'intellicash_backup_${DateTime.now().millisecondsSinceEpoch}.db',
        );

        if (result != null) {
          await dbFile.copy(result);
          Logger.printDebug('Database exported successfully to: $result');
          return true;
        }

        return false;
      },
      context: 'Exporting database',
      defaultValue: false,
    );
  }

  Future<bool> importDatabase() async {
    return errorHandler.handleDatabaseOperation(
      () async {
        final selectedFile = await readFile();
        if (selectedFile == null) return false;

        final dbPath = await db.databasePath;
        final currentDBContent = await File(dbPath).readAsBytes();

        // Create a backup of current database
        final backupPath = '${dbPath}_backup_${DateTime.now().millisecondsSinceEpoch}';
        await File(dbPath).copy(backupPath);

        try {
          // Replace current database with imported one
          await File(dbPath)
              .writeAsBytes(await selectedFile.readAsBytes(), mode: FileMode.write);

          // Validate and migrate the imported database
          final dbVersion = int.parse((await AppDataService.instance
              .getAppDataItem(AppDataKey.dbVersion)
              .first)!);

          if (dbVersion < db.schemaVersion) {
            await db.migrateDB(dbVersion, db.schemaVersion);
          }

          db.markTablesUpdated(db.allTables);
          Logger.printDebug('Database imported successfully');
          return true;
        } catch (e) {
          // Restore the original database on error
          await File(dbPath).writeAsBytes(currentDBContent, mode: FileMode.write);
          db.markTablesUpdated(db.allTables);

          Logger.printDebug('Database import failed: $e');
          throw Exception('The database is invalid or could not be read. Please check the file format.');
        }
      },
      context: 'Importing database',
      defaultValue: false,
    );
  }

  Future<File?> readFile() async {
    return errorHandler.handleFileOperation(
      () async {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['db'],
        );

        if (result != null && result.files.single.path != null) {
          return File(result.files.single.path!);
        }

        return null;
      },
      context: 'Reading file for import',
      defaultValue: null,
    );
  }

  Future<List<List<dynamic>>> processCsv(String csvData) async {
    return errorHandler.handleValidation(
      () {
        try {
          return const CsvToListConverter().convert(csvData, eol: '\n');
        } catch (e) {
          throw Exception('Invalid CSV format: $e');
        }
      },
      context: 'Processing CSV data',
    ) ?? [];
  }

  Future<bool> exportToCsv() async {
    return errorHandler.handleDatabaseOperation(
      () async {
        // Get all transactions
        final transactions = await db.select(db.transactions).get();
        
        if (transactions.isEmpty) {
          throw Exception('No transactions to export');
        }

        // Convert to CSV format
        final csvData = [
          ['Date', 'Account', 'Category', 'Title', 'Amount', 'Type', 'Status', 'Notes']
        ];

        for (final transaction in transactions) {
          csvData.add([
            transaction.date.toIso8601String(),
            transaction.accountID,
            transaction.categoryID ?? '',
            transaction.title ?? '',
            transaction.value.toString(),
            transaction.type ?? 'E',
            transaction.status ?? '',
            transaction.notes ?? '',
          ]);
        }

        final csvString = const CsvToListConverter().convert(csvData);
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Export Transactions',
          fileName: 'intellicash_transactions_${DateTime.now().millisecondsSinceEpoch}.csv',
        );

        if (result != null) {
          await File(result).writeAsString(csvString.toString());
          Logger.printDebug('Transactions exported to CSV: $result');
          return true;
        }

        return false;
      },
      context: 'Exporting transactions to CSV',
      defaultValue: false,
    );
  }

  Future<bool> importFromCsv() async {
    return errorHandler.handleDatabaseOperation(
      () async {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['csv'],
        );

        if (result == null || result.files.single.path == null) {
          return false;
        }

        final file = File(result.files.single.path!);
        final csvData = await file.readAsString();
        final rows = await processCsv(csvData);

        if (rows.length < 2) {
          throw Exception('CSV file is empty or invalid');
        }

        // Skip header row and process data
        int importedCount = 0;
        for (int i = 1; i < rows.length; i++) {
          try {
            final row = rows[i];
            if (row.length < 5) continue; // Skip invalid rows

            // Parse transaction data
            final date = DateTime.parse(row[0].toString());
            final accountId = row[1].toString();
            final categoryId = row[2].toString().isNotEmpty ? row[2].toString() : null;
            final title = row[3].toString();
            final amount = double.parse(row[4].toString());
            final type = row.length > 5 ? row[5].toString() : 'E';
            final status = row.length > 6 ? row[6].toString() : null;
            final notes = row.length > 7 ? row[7].toString() : null;

            // Insert transaction
            await db.into(db.transactions).insert(
              TransactionsCompanion.insert(
                id: const Value.absent(), // Auto-generated
                date: date,
                accountID: accountId,
                categoryID: Value(categoryId),
                title: Value(title),
                value: amount,
                type: Value(type),
                status: Value(status),
                notes: Value(notes),
                isHidden: const Value(false),
              ),
            );

            importedCount++;
          } catch (e) {
            Logger.printDebug('Failed to import row $i: $e');
            // Continue with other rows
          }
        }

        Logger.printDebug('Imported $importedCount transactions from CSV');
        return importedCount > 0;
      },
      context: 'Importing transactions from CSV',
      defaultValue: false,
    );
  }
}

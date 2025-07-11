import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:intellicash/core/database/app_db.dart';
import 'package:intellicash/core/database/services/app-data/app_data_service.dart';
import 'package:intellicash/core/models/transaction/transaction.dart';
import 'package:intellicash/core/utils/logger.dart';
import 'package:path/path.dart' as path;

class BackupDatabaseService {
  AppDB db = AppDB.instance;

  Future<void> exportDatabaseFile(String exportPath) async {
    List<int> dbFileInBytes = await File(await db.databasePath).readAsBytes();

    exportPath = path.join(
      exportPath,
      "monekin-${DateFormat('yyyyMMdd-Hms').format(DateTime.now())}.db",
    );

    File downloadFile = File(exportPath);

    await downloadFile.writeAsBytes(dbFileInBytes);
  }

  Future<String> exportSpreadsheet(
    String exportPath,
    List<MoneyTransaction> data, {
    String format = 'csv',
    String separator = ',',
  }) async {
    var csvData = '';

    var keys = [
      'ID',
      'Amount',
      'Date',
      'Title',
      'Note',
      'Account',
      'Currency',
      'Category',
      'Subcategory',
    ];

    if (data.isNotEmpty) {
      for (final key in keys) {
        csvData += key + separator;
      }
    }

    csvData += '\n';

    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    for (final transaction in data) {
      final toAdd = [
        transaction.id,
        transaction.value.toStringAsFixed(2),
        dateFormatter.format(transaction.date),
        transaction.title ?? '',
        transaction.notes ?? '',
        transaction.account.name,
        transaction.account.currencyId,
        if (transaction.isIncomeOrExpense)
          (transaction.category!.parentCategory != null
              ? transaction.category!.parentCategory!.name
              : transaction.category!.name),
        if (transaction.isTransfer) 'TRANSFER',
        (transaction.category?.parentCategory != null
            ? transaction.category?.name
            : '')
      ];

      csvData += toAdd.join(separator);

      csvData += '\n';

      if (transaction.isTransfer) {
        csvData += toAdd.join(separator);

        csvData += '\n';
      }
    }

    exportPath =
        '${exportPath}Transactions-${DateFormat('yyyyMMdd-Hms').format(DateTime.now())}.csv';

    File exportFile = File(exportPath);

    await exportFile.writeAsString(csvData);

    return exportPath;
  }

  Future<bool> importDatabase() async {
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: Platform.isWindows ? FileType.custom : FileType.any,
        allowedExtensions: Platform.isWindows ? ['db'] : null,
        allowMultiple: false,
      );
    } catch (e) {
      throw Exception(e.toString());
    }

    if (result != null) {
      File selectedFile = File(result.files.single.path!);

      // Delete the previous database
      String dbPath = await db.databasePath;

      final currentDBContent = await File(dbPath).readAsBytes();

      // Load the new database
      await File(dbPath)
          .writeAsBytes(await selectedFile.readAsBytes(), mode: FileMode.write);

      try {
        final dbVersion = int.parse((await AppDataService.instance
            .getAppDataItem(AppDataKey.dbVersion)
            .first)!);

        if (dbVersion < db.schemaVersion) {
          await db.migrateDB(dbVersion, db.schemaVersion);
        }

        db.markTablesUpdated(db.allTables);
      } catch (e) {
        // Reset the DB as it was
        await File(dbPath).writeAsBytes(currentDBContent, mode: FileMode.write);
        db.markTablesUpdated(db.allTables);

        Logger.printDebug('Error\n: $e');

        throw Exception('The database is invalid or could not be readed');
      }

      return true;
    }

    return false;
  }

  Future<File?> readFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      return File(result.files.single.path!);
    }

    return null;
  }

  Future<List<List<dynamic>>> processCsv(String csvData) async {
    return const CsvToListConverter().convert(csvData, eol: '\n');
  }
}

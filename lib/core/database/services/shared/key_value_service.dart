import 'package:drift/drift.dart';
import 'package:intellicash/core/database/app_db.dart';
import 'package:intellicash/core/database/services/shared/key_value_pair.dart';
import 'package:intellicash/core/utils/error_handler.dart';
import 'package:intellicash/main.dart';

/// Base service to handle key-value pairs for any table
abstract class KeyValueService<KeyType extends Enum, TableType extends Table,
    RowType> {
  final AppDB db;
  final TableInfo<TableType, RowType> table;
  final Map<KeyType, String?> globalStateMap;
  final KeyValuePairInDB<KeyType> Function(RowType) rowToKeyPairInstance;
  final Insertable<RowType> Function(KeyValuePairInDB<KeyType>) toDbRow;

  KeyValueService({
    required this.db,
    required this.table,
    required this.globalStateMap,
    required this.rowToKeyPairInstance,
    required this.toDbRow,
  });

  Future<void> initializeGlobalStateMap() async {
    return errorHandler.handleDatabaseOperation(
      () async {
        final savedSettings = await db.select(table).watch().first;

        for (final savedSetting in savedSettings.map(rowToKeyPairInstance)) {
          globalStateMap[savedSetting.key] = savedSetting.value;
        }
      },
      context: 'Initializing global state map',
    );
  }

  Future<bool> setItem(
    KeyType itemKey,
    String? itemValue, {
    bool updateGlobalState = false,
  }) async {
    return errorHandler.handleDatabaseOperation(
      () async {
        final previousValue = globalStateMap[itemKey];

        if (previousValue == itemValue) {
          return false;
        }

        globalStateMap[itemKey] = itemValue;

        try {
          await db.into(table).insert(
                toDbRow(KeyValuePairInDB(key: itemKey, value: itemValue)),
                mode: InsertMode.insertOrReplace,
              );

          if (updateGlobalState == true) {
            appStateKey.currentState?.refreshAppState();
          }

          return true;
        } catch (e) {
          // Restore previous value on error
          globalStateMap[itemKey] = previousValue;
          throw Exception('Failed to save setting: $e');
        }
      },
      context: 'Setting item: $itemKey',
      defaultValue: false,
    );
  }

  Stream<List<RowType>> getItemsFromDB(
      Expression<bool> Function(TableType) filter) {
    return errorHandler.handleValidation(
      () {
        try {
          return (db.select(table)..where(filter)).watch();
        } catch (e) {
          throw Exception('Failed to retrieve items from database: $e');
        }
      },
      context: 'Getting items from database',
    ) ?? Stream.value([]);
  }

  /// Safely get an item with error handling
  Future<String?> getItem(KeyType itemKey) async {
    return errorHandler.handleDatabaseOperation(
      () async {
        return globalStateMap[itemKey];
      },
      context: 'Getting item: $itemKey',
      defaultValue: null,
    );
  }

  /// Safely check if an item exists
  bool hasItem(KeyType itemKey) {
    return errorHandler.handleValidation(
      () {
        return globalStateMap.containsKey(itemKey) && globalStateMap[itemKey] != null;
      },
      context: 'Checking if item exists: $itemKey',
      showUserMessage: false,
    ) ?? false;
  }

  /// Safely remove an item
  Future<bool> removeItem(KeyType itemKey) async {
    return errorHandler.handleDatabaseOperation(
      () async {
        final previousValue = globalStateMap[itemKey];
        
        if (previousValue == null) {
          return false; // Item doesn't exist
        }

        globalStateMap.remove(itemKey);

        try {
          await (db.delete(table)..where((tbl) => tbl.key.equals(itemKey.name))).go();
          return true;
        } catch (e) {
          // Restore previous value on error
          globalStateMap[itemKey] = previousValue;
          throw Exception('Failed to remove item: $e');
        }
      },
      context: 'Removing item: $itemKey',
      defaultValue: false,
    );
  }

  /// Clear all items with error handling
  Future<bool> clearAll() async {
    return errorHandler.handleDatabaseOperation(
      () async {
        final previousState = Map<KeyType, String?>.from(globalStateMap);
        
        try {
          globalStateMap.clear();
          await db.delete(table).go();
          return true;
        } catch (e) {
          // Restore previous state on error
          globalStateMap.addAll(previousState);
          throw Exception('Failed to clear all items: $e');
        }
      },
      context: 'Clearing all items',
      defaultValue: false,
    );
  }

  /// Get all items as a map
  Map<KeyType, String?> getAllItems() {
    return errorHandler.handleValidation(
      () {
        return Map<KeyType, String?>.from(globalStateMap);
      },
      context: 'Getting all items',
      showUserMessage: false,
    ) ?? <KeyType, String?>{};
  }

  /// Batch update multiple items
  Future<bool> batchUpdate(Map<KeyType, String?> updates) async {
    return errorHandler.handleDatabaseOperation(
      () async {
        final previousState = Map<KeyType, String?>.from(globalStateMap);
        
        try {
          for (final entry in updates.entries) {
            globalStateMap[entry.key] = entry.value;
          }

          // Batch insert/update
          final batch = db.batch();
          for (final entry in updates.entries) {
            batch.insert(
              table,
              toDbRow(KeyValuePairInDB(key: entry.key, value: entry.value)),
              mode: InsertMode.insertOrReplace,
            );
          }
          await batch.commit();

          return true;
        } catch (e) {
          // Restore previous state on error
          globalStateMap.clear();
          globalStateMap.addAll(previousState);
          throw Exception('Failed to batch update items: $e');
        }
      },
      context: 'Batch updating items',
      defaultValue: false,
    );
  }
}

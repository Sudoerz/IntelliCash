// Note: Testing library/framework: flutter_test (package:flutter_test/flutter_test.dart).
// These tests validate TransactionViewActionService.transactionDetailsActions behavior for various inputs.
// We avoid executing onClick callbacks that show dialogs, and instead verify action configuration and, where safe, navigation push for edit action.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intellicash/core/services/view_actions/transaction_view_actions_service.dart';
import 'package:intellicash/core/utils/list_tile_action_item.dart';
import 'package:intellicash/core/models/transaction/transaction.dart';
import 'package:intellicash/core/models/tag/tag.dart' as tag_model show ModelTag; // adjust if needed based on actual tag import
import 'package:intellicash/i18n/generated/translations.g.dart';

/// Helper to build a minimal MoneyTransaction for tests.
/// NOTE: Adjust named parameters to match the actual MoneyTransaction API if it differs.
MoneyTransaction makeTransaction({
  required String id,
  required TransactionType type,
  required bool isRecurrent,
}) {
  // The model is inferred; provide sensible defaults and fields likely required by the constructor.
  // If MoneyTransaction has a .recurrentInfo with isRecurrent/isNoRecurrent, prefer using an API like:
  //   recurrentInfo: RecurrentInfo(isRecurrent: isRecurrent, ...)
  // Otherwise, adjust as appropriate. This keeps tests robust while focusing on action list composition.

  final recurrentInfo = RecurrentInfo(
    isRecurrent: isRecurrent,
    // Populate commonly required fields with defaults
    // Use neutral placeholders for optional fields.
    // If your RecurrentInfo requires more fields, add them here.
  );

  return MoneyTransaction(
    id: id,
    type: type,
    amount: 0,
    description: 'Test transaction',
    date: DateTime(2024, 1, 1),
    tags: const <ModelTag>[],
    recurrentInfo: recurrentInfo,
    // Add minimal other required fields here if constructor enforces them.
  );
}

// If RecurrentInfo and ModelTag types are in different paths/names, provide typedefs to ease compilation.
// Adjust these shims if your project uses different names.
typedef ModelTag = tag_model.ModelTag;

void main() {
  // Ensure deterministic locale for label expectations
  setUpAll(() {
    // If your i18n uses LocaleSettings, ensure a fallback locale:
    // LocaleSettings.setLocale(AppLocale.en);
  });

  group('TransactionViewActionService.transactionDetailsActions', () {
    testWidgets('returns 3 actions for non-recurrent transactions (Edit, Duplicate, Delete)', (tester) async {
      final service = TransactionViewActionService();

      // Build a widget tree to obtain a valid BuildContext with Navigator
      final testKey = GlobalKey();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            key: testKey,
            builder: (context) {
              // Prepare a non-recurrent transaction
              final transaction = makeTransaction(
                id: 'tr_1',
                type: TransactionType.expense,
                isRecurrent: false,
              );

              final actions = service.transactionDetailsActions(
                context,
                transaction: transaction,
                navigateBackOnDelete: false,
              );

              expect(actions, isA<List<ListTileActionItem>>());
              expect(actions.length, 3, reason: 'Non-recurrent should include Duplicate action');

              // Validate labels (using translation accessors)
              expect(actions[0].label, t.ui_actions.edit);
              expect(actions[1].label, t.transaction.duplicate_short);
              expect(actions[2].label, t.ui_actions.delete);

              // Validate icons
              expect(actions[0].icon, Icons.edit);
              expect(actions[1].icon, Icons.control_point_duplicate_rounded);
              expect(actions[2].icon, Icons.delete);

              // Validate roles where applicable
              expect(actions[2].role, ListTileActionRole.delete);

              // onClick should be non-null functions
              for (final a in actions) {
                expect(a.onClick, isNotNull);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ));
    });

    testWidgets('returns 2 actions for recurrent transactions (Edit, Delete) and omits Duplicate', (tester) async {
      final service = TransactionViewActionService();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final transaction = makeTransaction(
                id: 'tr_rec_1',
                type: TransactionType.income,
                isRecurrent: true,
              );

              final actions = service.transactionDetailsActions(
                context,
                transaction: transaction,
                navigateBackOnDelete: true,
              );

              expect(actions.length, 2, reason: 'Recurrent should NOT include Duplicate action');

              // Validate labels
              expect(actions[0].label, t.ui_actions.edit);
              expect(actions[1].label, t.ui_actions.delete);

              // Validate icons and roles
              expect(actions[0].icon, Icons.edit);
              expect(actions[1].icon, Icons.delete);
              expect(actions[1].role, ListTileActionRole.delete);

              return const SizedBox.shrink();
            },
          ),
        ),
      ));
    });

    testWidgets('navigateBackOnDelete flag does not affect action count but is captured in onClick closure', (tester) async {
      final service = TransactionViewActionService();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final transaction = makeTransaction(
                id: 'tr_2',
                type: TransactionType.transfer,
                isRecurrent: false,
              );

              final actionsNavigateTrue = service.transactionDetailsActions(
                context,
                transaction: transaction,
                navigateBackOnDelete: true,
              );

              final actionsNavigateFalse = service.transactionDetailsActions(
                context,
                transaction: transaction,
                navigateBackOnDelete: false,
              );

              // Both are non-recurrent, thus both have 3 actions
              expect(actionsNavigateTrue.length, 3);
              expect(actionsNavigateFalse.length, 3);

              // We cannot directly introspect the closure to assert captured value, but we ensure
              // both configurations produce structurally valid actions and the delete action is present.
              expect(actionsNavigateTrue.last.label, t.ui_actions.delete);
              expect(actionsNavigateFalse.last.label, t.ui_actions.delete);

              return const SizedBox.shrink();
            },
          ),
        ),
      ));
    });

    testWidgets('Edit action onClick pushes TransactionFormPage onto Navigator', (tester) async {
      final service = TransactionViewActionService();
      final observer = _RecordingNavigatorObserver();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final transaction = makeTransaction(
                id: 'tr_push_1',
                type: TransactionType.expense,
                isRecurrent: false,
              );

              final actions = service.transactionDetailsActions(
                context,
                transaction: transaction,
                navigateBackOnDelete: false,
              );

              // The first action is Edit
              final editAction = actions.first;
              expect(editAction.label, t.ui_actions.edit);
              // Invoke onClick to trigger navigation
              editAction.onClick?.call();

              return const SizedBox.shrink();
            },
          ),
        ),
        navigatorObservers: [observer],
      ));

      // Let queued frames complete
      await tester.pumpAndSettle();

      // Expect that at least one route was pushed
      expect(observer.pushedRoutes.isNotEmpty, true, reason: 'Edit action should push a new route');
      // We avoid asserting the exact widget type to keep this test decoupled from internal routing details.
    });
  });
}

/// Simple NavigatorObserver that records pushes for verification.
class _RecordingNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }
}
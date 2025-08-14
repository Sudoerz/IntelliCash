import 'package:flutter/material.dart';
import 'package:intellicash/app/accounts/account_form.dart';
import 'package:intellicash/app/transactions/form/transaction_form.page.dart';
import 'package:intellicash/core/database/services/transaction/transaction_service.dart';
import 'package:intellicash/core/presentation/animations/animated_expanded.dart';
import 'package:intellicash/core/presentation/widgets/confirm_dialog.dart';
import 'package:intellicash/core/routes/route_utils.dart';
import 'package:intellicash/i18n/generated/translations.g.dart';

class NewTransactionButton extends StatelessWidget {
  const NewTransactionButton({
    super.key,
    this.isExtended = true,
  });

  final bool isExtended;

  _showShouldCreateAccountWarn(BuildContext context) {
    final t = Translations.of(context);

    confirmDialog(
      context,
      dialogTitle: t.home.should_create_account_header,
      contentParagraphs: [Text(t.home.should_create_account_message)],
      confirmationText: t.ui_actions.continue_text,
    ).then((value) {
      if (value != true) return;
      if (!context.mounted) return;
      RouteUtils.pushRoute(context, const AccountFormPage());
    });
  }

  _onPressed(BuildContext context) {
    TransactionService.instance
        .checkIfCreateTransactionIsPossible()
        .first
        .then((value) {
      if (!value) {
        if (!context.mounted) return;
        _showShouldCreateAccountWarn(context);
      } else {
        if (!context.mounted) return;
        RouteUtils.pushRoute(context, const TransactionFormPage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return FloatingActionButton.extended(
      heroTag: null,
      onPressed: () => _onPressed(context),
      icon: const Icon(Icons.add_rounded),
      extendedPadding: const EdgeInsetsDirectional.only(start: 16, end: 16),
      extendedIconLabelSpacing: isExtended ? 8 : 0,
      label: AnimatedExpanded(
        duration: const Duration(milliseconds: 250),
        expand: isExtended,
        axis: Axis.horizontal,
        child: Text(t.transaction.create),
      ),
    );
  }
}

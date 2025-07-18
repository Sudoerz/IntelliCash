// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intellicash/app/transactions/widgets/transaction_list.dart';
import 'package:intellicash/core/database/services/transaction/transaction_service.dart';
import 'package:intellicash/core/models/date-utils/periodicity.dart';
import 'package:intellicash/core/presentation/responsive/breakpoints.dart';
import 'package:intellicash/core/presentation/widgets/no_results.dart';
import 'package:intellicash/core/presentation/widgets/number_ui_formatters/currency_displayer.dart';
import 'package:intellicash/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:intellicash/i18n/generated/translations.g.dart';

class RecurrentTransactionPage extends StatefulWidget {
  const RecurrentTransactionPage({super.key});

  @override
  State<RecurrentTransactionPage> createState() =>
      _RecurrentTransactionPageState();
}

class _RecurrentTransactionPageState extends State<RecurrentTransactionPage> {
  Periodicity periodicity = Periodicity.month;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.recurrent_transactions.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: StreamBuilder(
                stream: TransactionService.instance.countTransactions(
                  convertToPreferredCurrency: false,
                  predicate: const TransactionFilters(isRecurrent: true),
                ),
                builder: (context, snapshot) {
                  final nOfRes = snapshot.data?.numberOfRes ?? 0;

                  return Text(
                    '${nOfRes} ${t.transaction.display(n: nOfRes)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  );
                }),
          ),
          Expanded(
            child: TransactionListComponent(
              filters: const TransactionFilters(isRecurrent: true),
              prevPage: const RecurrentTransactionPage(),
              periodicityInfo: periodicity,
              showGroupDivider: false,
              heroTagBuilder: (tr) =>
                  'recurrent-transactions-page__tr-icon-${tr.id}',
              onEmptyList: Center(
                child: NoResults(
                    title: t.general.empty_warn,
                    description: t.recurrent_transactions.empty),
              ),
            ),
          ),
          //
          // --------**---------- FOOTER ----------**---------
          //
          const Divider(endIndent: 16, indent: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: () {
                  periodicity = Periodicity.values.firstWhereOrNull(
                        (element) => element.index == periodicity.index + 1,
                      ) ??
                      Periodicity.day;

                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.recurrent_transactions.total_expense_title,
                              style: Theme.of(context).textTheme.titleMedium!,
                            ),
                            Text(
                              t.recurrent_transactions.total_expense_descr,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(fontWeight: FontWeight.w300),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StreamBuilder(
                              stream: TransactionService.instance
                                  .getTransactions(
                                    filters: const TransactionFilters(
                                      isRecurrent: true,
                                    ),
                                  )
                                  .map(
                                    (event) => event
                                        .map(
                                          (transaction) => transaction
                                              .getUnifiedMoneyForAPeriod(
                                                  periodicity: periodicity),
                                        )
                                        .sum,
                                  ),
                              initialData: 0.0,
                              builder: (context, snapshot) {
                                return CurrencyDisplayer(
                                  amountToConvert: snapshot.data!,
                                  compactView: snapshot.data! <= 10000000000 &&
                                          BreakPoint.of(context)
                                              .isLargerOrEqualTo(
                                                  BreakpointID.xl)
                                      ? false
                                      : true,
                                  integerStyle:
                                      Theme.of(context).textTheme.titleLarge!,
                                );
                              }),
                          Text(
                            t.general.time.ranges.each_range(
                              n: 1,
                              range: periodicity
                                  .periodText(context, isPlural: false)
                                  .toLowerCase(),
                            ),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                      const Icon(Icons.swap_vert_rounded)
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

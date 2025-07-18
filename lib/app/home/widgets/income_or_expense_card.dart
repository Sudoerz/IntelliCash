import 'package:flutter/material.dart';
import 'package:intellicash/core/database/services/account/account_service.dart';
import 'package:intellicash/core/presentation/widgets/number_ui_formatters/currency_displayer.dart';
import 'package:intellicash/core/presentation/widgets/skeleton.dart';
import 'package:intellicash/core/presentation/widgets/transaction_filter/transaction_filters.dart';

import '../../../core/models/transaction/transaction_type.enum.dart';
import '../../../core/presentation/app_colors.dart';

class IncomeOrExpenseCard extends StatelessWidget {
  const IncomeOrExpenseCard(
      {super.key,
      required this.type,
      required this.startDate,
      required this.endDate,
      this.filters});

  final TransactionType type;
  final DateTime? startDate;
  final DateTime? endDate;

  final TransactionFilters? filters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: type.color(context),
              borderRadius: BorderRadius.circular(80),
            ),
            child: Icon(
              type.icon,
              color: Theme.of(context).colorScheme.surface,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type.displayName(context),
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: AppColors.of(context)
                        .onConsistentPrimary
                        .withOpacity(0.85)),
              ),
              StreamBuilder(
                  stream: AccountService.instance.getAccountsBalance(
                    filters: TransactionFilters(
                      accountsIDs: filters?.accountsIDs,
                      categories: filters?.categories,
                      minDate: startDate,
                      maxDate: endDate,
                      transactionTypes: [type],
                    ),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Skeleton(width: 26, height: 18);
                    }

                    return CurrencyDisplayer(
                      amountToConvert: snapshot.data!.abs(),
                      compactView: true,
                      showDecimals: false,
                      integerStyle: TextStyle(
                          fontSize: 18,
                          color: AppColors.of(context).onConsistentPrimary),
                    );
                  })
            ],
          )
        ],
      ),
    );
  }
}

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intellicash/app/stats/widgets/movements_distribution/category_stats_modal.dart';
import 'package:intellicash/app/stats/widgets/movements_distribution/tr_distribution_chart_item.dart';
import 'package:intellicash/core/database/services/category/category_service.dart';
import 'package:intellicash/core/database/services/transaction/transaction_service.dart';
import 'package:intellicash/core/extensions/color.extensions.dart';
import 'package:intellicash/core/extensions/lists.extensions.dart';
import 'package:intellicash/core/models/category/category.dart';
import 'package:intellicash/core/models/date-utils/date_period_state.dart';
import 'package:intellicash/core/models/supported-icon/icon_displayer.dart';
import 'package:intellicash/core/models/transaction/transaction.dart';
import 'package:intellicash/core/models/transaction/transaction_status.enum.dart';
import 'package:intellicash/core/presentation/widgets/number_ui_formatters/currency_displayer.dart';
import 'package:intellicash/core/presentation/widgets/number_ui_formatters/ui_number_formatter.dart';
import 'package:intellicash/core/presentation/widgets/transaction_filter/transaction_filters.dart';
import 'package:intellicash/i18n/generated/translations.g.dart';

import '../../../../core/models/transaction/transaction_type.enum.dart';

class PieChartByCategories extends StatefulWidget {
  const PieChartByCategories(
      {super.key,
      required this.datePeriodState,
      this.showList = false,
      this.initialSelectedType = TransactionType.E,
      this.filters = const TransactionFilters()});

  final DatePeriodState datePeriodState;

  final bool showList;

  final TransactionType initialSelectedType;

  final TransactionFilters filters;

  @override
  State<PieChartByCategories> createState() => _PieChartByCategoriesState();
}

class _PieChartByCategoriesState extends State<PieChartByCategories> {
  int touchedIndex = -1;
  late TransactionType transactionsType;

  final centerRadius = 35;

  TransactionFilters _getTransactionFilters() {
    return widget.filters.copyWith(
      status:
          TransactionStatus.getStatusThatCountsForStats(widget.filters.status),
      transactionTypes: [transactionsType]
          .intersectionWithNullable(widget.filters.transactionTypes)
          .toList(),
      minDate: widget.datePeriodState.startDate,
      maxDate: widget.datePeriodState.endDate,
    );
  }

  Future<List<TrDistributionChartItem<Category>>> getEvolutionData(
      BuildContext context, List<MoneyTransaction> transactions) async {
    final data = <TrDistributionChartItem<Category>>[];

    for (final transaction in transactions) {
      final trValue = transaction.currentValueInPreferredCurrency *
          (transactionsType == TransactionType.E ? -1 : 1);

      final categoryToEdit = data.firstWhereOrNull((cat) =>
          cat.category.id == transaction.category?.id ||
          cat.category.id == transaction.category?.parentCategoryID);

      if (categoryToEdit != null) {
        categoryToEdit.value += trValue;
        categoryToEdit.transactions.add(transaction);
      } else {
        data.add(
          TrDistributionChartItem(
            category: transaction.category!.parentCategoryID == null
                ? Category.fromDB(transaction.category!, null)
                : (await CategoryService.instance
                    .getCategoryById(transaction.category!.parentCategoryID!)
                    .first)!,
            transactions: [transaction],
            value: trValue,
          ),
        );
      }
    }

    return data
        .where((element) => element.value > 0)
        .sorted((a, b) => b.value.compareTo(a.value));
  }

  /// Returns a value between 0 and 1
  double getElementPercentageInTotal(
      double elementValue, List<TrDistributionChartItem> items) {
    return (elementValue / items.map((e) => e.value).sum);
  }

  List<PieChartSectionData> showingSections(
      List<TrDistributionChartItem<Category>> data) {
    if (data.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey.withOpacity(0.175),
          value: 100,
          radius: 50,
          showTitle: false,
        )
      ];
    }

    double totalPercentAccumulated = 0;

    return data.mapIndexed(
      (index, element) {
        final isTouched = index == touchedIndex;
        final radius = isTouched ? 60.0 : 50.0;

        final percentage = getElementPercentageInTotal(element.value, data);
        totalPercentAccumulated = totalPercentAccumulated + percentage;

        final showIcon = percentage > 0.05;

        return PieChartSectionData(
          color: ColorHex.get(element.category.color),
          value: percentage,
          title: '',
          radius: radius,
          titlePositionPercentageOffset: 1.4,
          badgePositionPercentageOffset: .98,
          badgeWidget: !showIcon
              ? null
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isTouched ? 1 : 0,
                      child: Center(
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            // Prevent overlapping labels when displayed on top
                            // Divider percent by 2, because the label is in the middle
                            // This means any label location that is past 50% will change orientation
                            totalPercentAccumulated - percentage / 2 < 0.5
                                ? -34
                                : 34,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: ColorHex.get(element.category.color),
                                width: 1.5,
                              ),
                              color: Theme.of(context).canvasColor,
                            ),
                            child: UINumberFormatter.percentage(
                              amountToConvert: percentage,
                              showDecimals: false,
                              integerStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ).getTextWidget(context),
                          ),
                        ),
                      ),
                    ),
                    Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).canvasColor,
                            border: Border.all(
                              width: 2,
                              color: ColorHex.get(element.category.color),
                            )),
                        padding: const EdgeInsets.all(6),
                        child: element.category.icon.display(
                            color: ColorHex.get(element.category.color))),
                  ],
                ),
        );
      },
    ).toList();
  }

  @override
  void initState() {
    super.initState();

    transactionsType = widget.initialSelectedType;

    if (transactionsType.isTransfer) {
      throw 'Can not draw the categories pie chart of transfers';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return StreamBuilder(
      stream: TransactionService.instance
          .getTransactions(filters: _getTransactionFilters())
          .asyncMap((data) => getEvolutionData(context, data)),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LinearProgressIndicator();
        }

        final dataItems = snapshot.data!;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SegmentedButton(
                segments: [
                  ButtonSegment(
                    value: TransactionType.E,
                    label: Text(t.transaction.types.expense(n: 1)),
                  ),
                  ButtonSegment(
                    value: TransactionType.I,
                    label: Text(t.transaction.types.income(n: 1)),
                  ),
                ],
                showSelectedIcon: false,
                selected: {transactionsType},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    transactionsType = newSelection.first;
                  });
                },
              ),
            ),
            SizedBox(
              height: 260,
              child: Stack(
                children: [
                  PieChart(
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 250),
                    PieChartData(
                      startDegreeOffset: -45,
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: centerRadius.toDouble(),
                      sections: showingSections(dataItems),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: centerRadius * 2.25,
                          height: centerRadius * 2.25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.1),
                          ),
                        )),
                  ),
                  if (snapshot.data!.isEmpty)
                    Positioned.fill(
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            t.general.insufficient_data,
                            style: Theme.of(context).textTheme.titleLarge,
                          )),
                    ),
                ],
              ),
            ),

            /* ----------------------------- */
            /* ------ Info in a list ------- */
            /* ----------------------------- */

            if (widget.showList)
              ListView.builder(
                itemCount: snapshot.data!.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final dataCategory = snapshot.data![index];

                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dataCategory.category.name),
                        CurrencyDisplayer(amountToConvert: dataCategory.value)
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${dataCategory.transactions.length} ${t.transaction.display(n: dataCategory.transactions.length)}'
                              .toLowerCase(),
                        ),
                        Text(
                            NumberFormat.decimalPercentPattern(decimalDigits: 2)
                                .format(getElementPercentageInTotal(
                                    dataCategory.value, snapshot.data!)))
                      ],
                    ),
                    leading: IconDisplayer.fromCategory(
                      context,
                      category: dataCategory.category,
                      size: 25,
                    ),
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return CategoryStatsModal(
                              categoryData: dataCategory,
                              dateRangeText:
                                  widget.datePeriodState.getText(context),
                              filters: _getTransactionFilters(),
                            );
                          });
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

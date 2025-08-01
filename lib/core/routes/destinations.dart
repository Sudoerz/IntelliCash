import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intellicash/app/budgets/budgets_page.dart';
import 'package:intellicash/app/home/dashboard.page.dart';
import 'package:intellicash/app/settings/settings.page.dart';
import 'package:intellicash/app/stats/stats_page.dart';
import 'package:intellicash/app/transactions/transactions.page.dart';
import 'package:intellicash/core/presentation/responsive/breakpoints.dart';
import 'package:intellicash/i18n/generated/translations.g.dart';
import 'package:intellicash/app/ai/ai_page.dart';

enum AppMenuDestinationsID {
  dashboard,
  budgets,
  transactions,
  recurrentTransactions,
  accounts,
  stats,
  settings,
  categories,
  ai,
}

class MainMenuDestination {
  const MainMenuDestination(
    this.id, {
    required this.destination,
    required this.label,
    required this.icon,
    this.selectedIcon,
  });

  final AppMenuDestinationsID id;
  final String label;
  final IconData icon;
  final IconData? selectedIcon;

  final Widget destination;

  NavigationDestination toNavigationDestinationWidget(BuildContext context) {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Icon(
        selectedIcon ?? icon,
      ),
      label: label,
    );
  }

  NavigationDrawerDestination toNavigationDrawerDestinationWidget() {
    return NavigationDrawerDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon ?? icon),
      label: Text(label),
    );
  }

  NavigationRailDestination toNavigationRailDestinationWidget() {
    return NavigationRailDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon ?? icon),
      label: Text(
        label,
        textAlign: TextAlign.center,
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
    );
  }
}

List<MainMenuDestination> getAllDestinations(
  BuildContext context, {
  required bool shortLabels,
}) {
  final t = Translations.of(context);

  return <MainMenuDestination>[
    MainMenuDestination(
      AppMenuDestinationsID.dashboard,
      label: t.home.title,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      destination: const DashboardPage(),
    ),
    MainMenuDestination(
      AppMenuDestinationsID.budgets,
      label: t.budgets.title,
      icon: Icons.calculate_outlined,
      selectedIcon: Icons.calculate,
      destination: const BudgetsPage(),
    ),

    MainMenuDestination( //TODO : AI implementation screen here
      AppMenuDestinationsID.ai,
      label: t.general.ai,
      icon: CupertinoIcons.sparkles,
      destination: const AiPage(),
    ),

    MainMenuDestination(
      AppMenuDestinationsID.transactions,
      label: t.transaction.display(n: 10),
      icon: Icons.list,
      destination: const TransactionsPage(),
    ),
    /*   MainMenuDestination(
      AppMenuDestinationsID.recurrentTransactions,
      label: shortLabels
          ? t.recurrent_transactions.title_short
          : t.recurrent_transactions.title,
      icon: Icons.auto_mode_rounded,
      destination: const RecurrentTransactionPage(),
    ), */
    MainMenuDestination(
      AppMenuDestinationsID.stats,
      label: t.stats.title,
      icon: Icons.auto_graph_rounded,
      destination: const StatsPage(),
    ),
    MainMenuDestination(
      AppMenuDestinationsID.settings,
      label: t.more.title,
      selectedIcon: Icons.more_horiz_rounded,
      icon: Icons.more_horiz_rounded,
      destination: const SettingsPage(),
    ),
  ];
}

List<MainMenuDestination> getDestinations(
  BuildContext context, {
  required bool shortLabels,
  bool showHome = true,
}) {
  final bool isMobileMode =
      BreakPoint.of(context).isSmallerThan(BreakpointID.md);

  var toReturn = getAllDestinations(context, shortLabels: shortLabels);

  if (!showHome) {
    toReturn = toReturn
        .where((element) => element.id != AppMenuDestinationsID.dashboard)
        .toList();
  }

  if (isMobileMode) {
    toReturn = toReturn
        .where((element) => [
              AppMenuDestinationsID.ai,
              AppMenuDestinationsID.dashboard,
              AppMenuDestinationsID.transactions,
              AppMenuDestinationsID.settings,
            ].contains(element.id))
        .toList();
  }

  return toReturn;
}

import 'package:flutter/material.dart';
import 'package:intellicash/core/presentation/app_colors.dart';
import 'package:intellicash/i18n/generated/translations.g.dart';

enum NextPayStatus {
  /// The payment date has not yet arrived, but it is very close
  comingSoon,

  /// The payment should have already been made, that is, it was scheduled before the current date
  delayed,

  /// The payment date has not yet arrived nor is it close
  planified;

  Color color(BuildContext context) {
    if (this == planified) {
      return Theme.of(context).colorScheme.primary;
    } else if (this == delayed) {
      return AppColors.of(context).danger;
    }

    return Colors.amber;
  }

  IconData get icon {
    if (this == planified) {
      return Icons.event_rounded;
    } else if (this == delayed) {
      return Icons.warning_rounded;
    }

    return Icons.upcoming;
  }

  String displayDaysToPay(BuildContext context, int days) {
    final t = Translations.of(context);

    if (days == 0) {
      return t.general.today;
    }

    if (this == delayed) {
      return t.recurrent_transactions.status.delayed_by(x: days.abs());
    }

    return t.recurrent_transactions.status.coming_in(x: days.abs());
  }
}

import 'package:flutter/material.dart';
import 'package:intellicash/i18n/generated/translations.g.dart';

/// The radius of the `CardWithHeader` widget, a very useful widget through the app
const cardWithHeaderRadius = 12.0;

class CardWithHeader extends StatelessWidget {
  const CardWithHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.bodyPadding = const EdgeInsets.all(0),
    this.footer,
  });

  final Widget body;
  final Widget? footer;

  final String title;
  final String? subtitle;

  final EdgeInsets bodyPadding;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(0),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.fromLTRB(16, 12, 2, 4),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              // color: AppColors.of(context).light,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontSize: 18)),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall!,
                      ),
                  ],
                ),
              ],
            ),
          ),
          Material(
            type: MaterialType.transparency,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Padding(
              padding: bodyPadding,
              child: body,
            ),
          ),
          if (footer != null) footer!
        ],
      ),
    );
  }
}

class CardFooterWithSingleButton extends StatelessWidget {
  const CardFooterWithSingleButton({super.key, this.text, this.onButtonClick});

  final String? text;
  final VoidCallback? onButtonClick;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(
          thickness: 2,
          indent: 16,
          endIndent: 16,
        ),
        Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.fromLTRB(2, 4, 2, 4),
          child: TextButton.icon(
            onPressed: onButtonClick,
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            label: Text(text ?? t.ui_actions.see_more),
          ),
        )
      ],
    );
  }
}

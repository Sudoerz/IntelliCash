import 'package:flutter/material.dart';
import 'package:intellicash/core/models/supported-icon/icon_displayer.dart';
import 'package:intellicash/core/models/supported-icon/supported_icon.dart';
import 'package:intellicash/core/presentation/app_colors.dart';
import 'package:intellicash/core/presentation/widgets/bottomSheetFooter.dart';
import 'package:intellicash/core/presentation/widgets/scrollable_with_bottom_gradient.dart';
import 'package:intellicash/core/services/supported_icon/supported_icon_service.dart';
import 'package:intellicash/i18n/generated/translations.g.dart';

showIconSelectorModal(BuildContext context, IconSelectorModal component) {
  return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return component;
      });
}

class IconSelectorModal extends StatefulWidget {
  const IconSelectorModal({
    super.key,
    required this.preselectedIconID,
    this.onIconSelected,
    required this.subtitle,
  });

  final String preselectedIconID;
  final String? subtitle;

  final void Function(SupportedIcon selectedIcon)? onIconSelected;

  @override
  State<IconSelectorModal> createState() => _IconSelectorModalState();
}

class _IconSelectorModalState extends State<IconSelectorModal> {
  SupportedIcon? _selectedIcon;

  @override
  void initState() {
    super.initState();

    _selectedIcon =
        SupportedIconService.instance.getIconByID(widget.preselectedIconID);
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.85,
        minChildSize: 0.625,
        initialChildSize: 0.85,
        builder: (context, scrollController) {
          final iconsByScope = SupportedIconService.instance.getIconsByScope();

          return Scaffold(
            backgroundColor: AppColors.of(context).modalBackground,
            body: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.icon_selector.select_icon,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        if (widget.subtitle != null) Text(widget.subtitle!),
                      ],
                    ),
                    Chip(
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2),
                      //  backgroundColor: Theme.of(context).colorScheme.primaryLight,
                      label: _selectedIcon!.display(
                          size: 34,
                          color: Theme.of(context).colorScheme.onSurface),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ScrollableWithBottomGradient(
                  gradientColor: AppColors.of(context).modalBackground,
                  controller: scrollController,
                  child: Column(
                      children: iconsByScope.keys.toList().map((scope) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            const Divider(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 16),
                              color: AppColors.of(context).modalBackground,
                              child: Text(t[
                                  'icon_selector.scopes.${scope.replaceAll("/", "_")}']),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Wrap(
                            spacing: 8, // gap between adjacent cards
                            runSpacing: 12, // gap between lines
                            children: iconsByScope[scope]!
                                .map((e) => Card(
                                      elevation: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? 4
                                          : 1,
                                      clipBehavior: Clip.antiAlias,
                                      color: _selectedIcon?.id == e.id
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : null,
                                      child: IconDisplayer(
                                          supportedIcon: e,
                                          onTap: () {
                                            setState(() {
                                              _selectedIcon = e;
                                            });
                                          },
                                          size: 32,
                                          secondaryColor: Colors.transparent,
                                          isOutline: _selectedIcon?.id == e.id,
                                          mainColor: _selectedIcon?.id == e.id
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface),
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(
                          // Margin between the icon groups
                          height: 10,
                        )
                      ],
                    );
                  }).toList()),
                ),
              ),
              BottomSheetFooter(
                submitIcon: Icons.check,
                submitText: t.ui_actions.select,
                onSaved: () {
                  widget.onIconSelected!(_selectedIcon!);
                  Navigator.pop(context);
                },
              )
            ]),
          );
        });
  }
}

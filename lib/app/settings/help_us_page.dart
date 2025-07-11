import 'package:flutter/material.dart';
import 'package:intellicash/app/settings/purchases/donate_button.dart';
import 'package:intellicash/app/settings/purchases/in_app_purchase.dart';
import 'package:intellicash/app/settings/widgets/display_app_icon.dart';
import 'package:intellicash/app/settings/widgets/setting_card_item.dart';
import 'package:intellicash/core/utils/open_external_url.dart';
import 'package:intellicash/i18n/generated/translations.g.dart';
import 'package:share_plus/share_plus.dart';

class HelpUsPage extends StatelessWidget {
  const HelpUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final iapConnection = IAPConnection.instance;

    return Scaffold(
      appBar: AppBar(title: Text(t.more.help_us.display)),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const DisplayAppIcon(height: 80),
                  const SizedBox(height: 18),
                  Text(
                    t.more.help_us.thanks,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.more.help_us.thanks_long,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SettingCardItem(
                      title: t.more.help_us.rate_us,
                      subtitle: t.more.help_us.rate_us_descr,
                      icon: Icons.star_rounded,
                      mainAxis: Axis.horizontal,
                      onTap: () {
                        openExternalURL(context,
                            'https://github.com/Sudoerz/');
                      }),
                  const SizedBox(height: 8),
                  SettingCardItem(
                      title: t.more.help_us.share,
                      subtitle: t.more.help_us.share_descr,
                      icon: Icons.share,
                      mainAxis: Axis.horizontal,
                      onTap: () {
                        Share.share(
                            '${t.more.help_us.share_text}: https://github.com/Sudoerz/');
                      }),
                  const SizedBox(height: 8),
                  SettingCardItem(
                      title: t.more.help_us.report,
                      icon: Icons.rate_review_outlined,
                      mainAxis: Axis.horizontal,
                      onTap: () {
                        openExternalURL(context,
                            'https://github.com/Sudoerz/');
                      }),
                ],
              ),
            ),
            DonateButton(iapConnection: iapConnection)
          ],
        ),
      ),
    );
  }
}

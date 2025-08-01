import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intellicash/app/layout/navigation_sidebar.dart';
import 'package:intellicash/app/layout/tabs.dart';
import 'package:intellicash/app/onboarding/intro.page.dart';
import 'package:intellicash/core/database/services/app-data/app_data_service.dart';
import 'package:intellicash/core/database/services/user-setting/private_mode_service.dart';
import 'package:intellicash/core/database/services/user-setting/user_setting_service.dart';
import 'package:intellicash/core/database/services/user-setting/utils/get_theme_from_string.dart';
import 'package:intellicash/core/presentation/theme.dart';
import 'package:intellicash/core/routes/root_navigator_observer.dart';
import 'package:intellicash/core/utils/logger.dart';
import 'package:intellicash/core/utils/scroll_behavior_override.dart';
import 'package:intellicash/firebase_options.dart';
import 'package:intellicash/i18n/generated/translations.g.dart';
import 'package:intl/intl.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await UserSettingService.instance.initializeGlobalStateMap();
  await AppDataService.instance.initializeGlobalStateMap();

  PrivateModeService.instance
      .setPrivateMode(appStateSettings[SettingKey.privateModeAtLaunch] == '1');

  // Set plural resolver for Turkish
  await LocaleSettings.setPluralResolver(
    language: 'tr',
    cardinalResolver: (n,
        {String? few,
        String? many,
        String? one,
        String? other,
        String? two,
        String? zero}) {
      if (n == 1) return 'one';
      return 'other';
    },
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  runApp(InitializeApp(key: appStateKey));
}

final GlobalKey<TabsPageState> tabsPageKey = GlobalKey();
final GlobalKey<NavigationSidebarState> navigationSidebarKey = GlobalKey();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ignore: library_private_types_in_public_api
GlobalKey<_InitializeAppState> appStateKey = GlobalKey();

class InitializeApp extends StatefulWidget {
  const InitializeApp({super.key});

  @override
  State<InitializeApp> createState() => _InitializeAppState();
}

class _InitializeAppState extends State<InitializeApp> {
  void refreshAppState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return MonekinAppEntryPoint(key: const ValueKey('App Entry Point'));
  }
}

class MonekinAppEntryPoint extends StatelessWidget {
  const MonekinAppEntryPoint({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Logger.printDebug('------------------ APP ENTRY POINT ------------------');

    final lang = appStateSettings[SettingKey.appLanguage];

    if (lang != null) {
      Logger.printDebug('App language found. Setting the locale to `$lang`...');
      LocaleSettings.setLocaleRaw(lang);
    } else {
      Logger.printDebug(
          'App language not found. Setting the user device language...');

      LocaleSettings.useDeviceLocale();

      // We have nothing to worry here since the useDeviceLocale() func will set the default lang (english in our case) if
      // the user is using a non-supported language in his device

      UserSettingService.instance
          .setItem(
            SettingKey.appLanguage,
            LocaleSettings.currentLocale.languageTag,
          )
          .then((value) => null);
    }

    return TranslationProvider(
      child: MaterialAppContainer(
        introSeen: appStateData[AppDataKey.introSeen] == '1',
        amoledMode: appStateSettings[SettingKey.amoledMode]! == '1',
        accentColor: appStateSettings[SettingKey.accentColor]!,
        themeMode: getThemeFromString(appStateSettings[SettingKey.themeMode]!),
      ),
    );
  }
}

class MaterialAppContainer extends StatelessWidget {
  const MaterialAppContainer(
      {super.key,
      required this.themeMode,
      required this.accentColor,
      required this.amoledMode,
      required this.introSeen});

  final ThemeMode themeMode;
  final String accentColor;
  final bool amoledMode;

  final bool introSeen;

  @override
  Widget build(BuildContext context) {
    // Get the language of the Intl in each rebuild of the TranslationProvider:
    Intl.defaultLocale = LocaleSettings.currentLocale.languageTag;

    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return MaterialApp(
        title: 'Intellicash',
        debugShowCheckedModeBanner: false,
        locale: TranslationProvider.of(context).flutterLocale,
        scrollBehavior: ScrollBehaviorOverride(),
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: getThemeData(context,
            isDark: false,
            amoledMode: amoledMode,
            lightDynamic: lightDynamic,
            darkDynamic: darkDynamic,
            accentColor: accentColor),
        darkTheme: getThemeData(context,
            isDark: true,
            amoledMode: amoledMode,
            lightDynamic: lightDynamic,
            darkDynamic: darkDynamic,
            accentColor: accentColor),
        themeMode: themeMode,
        navigatorKey: navigatorKey,
        navigatorObservers: [MainLayoutNavObserver()],
        builder: (context, child) {
          return Overlay(initialEntries: [
            OverlayEntry(
              builder: (context) => Stack(
                children: [
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOutCubicEmphasized,
                        width:
                            introSeen ? getNavigationSidebarWidth(context) : 0,
                        color: Theme.of(context).canvasColor,
                      ),
                      Expanded(child: child ?? const SizedBox.shrink()),
                    ],
                  ),
                  if (introSeen) NavigationSidebar(key: navigationSidebarKey)
                ],
              ),
            ),
          ]);
        },
        home: introSeen ? TabsPage(key: tabsPageKey) : const IntroPage(),
      );
    });
  }
}

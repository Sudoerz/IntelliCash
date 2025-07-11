import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intellicash/app/home/dashboard.page.dart';
import 'package:intellicash/app/onboarding/onboarding.dart';
import 'package:intellicash/app/settings/settings.page.dart';
import 'package:intellicash/core/database/services/app-data/app_data_service.dart';
import 'package:intellicash/core/database/services/user-setting/user_setting_service.dart';
import 'package:intellicash/i18n/generated/translations.g.dart';
import 'package:intellicash/main.dart';

Future<void> setupMonekin() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await UserSettingService.instance.initializeGlobalStateMap();
  await AppDataService.instance.initializeGlobalStateMap();
}

Future<void> startMonekin(WidgetTester tester) async {
  await tester.pumpWidget(const MonekinAppEntryPoint());
  await tester.pumpAndSettle();
  expect(find.byType(MonekinAppEntryPoint), findsOneWidget);
  await tester.tap(find.text(t.intro.offline_start));

  await tester.pumpAndSettle();
  expect(find.byType(OnboardingPage), findsOneWidget);
  await tester.tap(find.text(t.intro.skip));

  await LocaleSettings.setLocale(AppLocale.en, listenToDeviceLocale: true);

  await tester.pumpAndSettle();
  expect(find.byType(DashboardPage), findsOneWidget);
}

Future<void> openMorePage(WidgetTester tester) async {
  await tester.tap(find.text(t.more.title));
  await tester.pumpAndSettle();

  expect(find.byType(SettingsPage), findsOneWidget);
}

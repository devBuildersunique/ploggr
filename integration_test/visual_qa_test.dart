import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ploggr/app.dart';
import 'package:ploggr/routes/app_router.dart';
import 'package:ploggr/features/plogging/application/session_controller.dart';
import 'package:ploggr/features/litter/application/litter_controller.dart';
import 'package:ploggr/features/cleanups/cleanup_controller.dart';

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android screenshots of all 18 reference screens', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const PloggrApp()),
    );
    await binding.convertFlutterSurfaceToImage();
    await tester.pump(const Duration(milliseconds: 100));
    await binding.takeScreenshot('01-splash');
    final routes = <String, String>{
      '02-onboarding-plog': '/onboarding',
      '03-onboarding-rewards': '/onboarding?page=1',
      '04-onboarding-report': '/onboarding?page=2',
      '05-login': '/login',
      '06-signup': '/signup',
      '07-home': '/home',
      '08-scan': '/scan',
      '09-report': '/report',
      '10-map': '/map',
      '11-session': '/session',
      '12-summary': '/session/summary',
      '13-cleanups': '/cleanups',
      '14-challenges': '/challenges',
      '15-leaderboard': '/leaderboard',
      '16-badges': '/badges',
      '17-community': '/community',
      '18-profile': '/profile',
    };
    for (final route in routes.entries) {
      // Leave the current route so each onboarding page gets its initial state.
      container.read(appRouterProvider).go('/home');
      await tester.pumpAndSettle();
      container.read(appRouterProvider).go(route.value);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: route.key);
      await binding.takeScreenshot(route.key);
    }
  });

  testWidgets('Android navigation and preview state work end to end', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [initialLocationProvider.overrideWithValue('/home')],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const PloggrApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Plog Session'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Pause session'));
    await tester.pumpAndSettle();
    expect(container.read(sessionProvider).paused, isTrue);
    await tester.tap(find.byTooltip('End session'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Increase litter weight'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Session'));
    await tester.pumpAndSettle();
    expect(container.read(impactProvider).sessions, 19);
    await tester.tap(find.text('Scan Litter'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Capture sample photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Glass'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to Litter Map'));
    await tester.pumpAndSettle();
    expect(container.read(litterProvider).first.type, 'Glass');
    expect(find.text('Glass Litter'), findsOneWidget);
    await tester.tap(find.text('Clean-ups'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Join'));
    await tester.pumpAndSettle();
    expect(container.read(joinedCleanupsProvider), contains('city'));
    await tester.tap(find.text('List'));
    await tester.pumpAndSettle();
    expect(find.text('Green Park Plog'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Community'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Posts'));
    await tester.pumpAndSettle();
    expect(find.text('Ananya P.'), findsNothing);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Vipul Reddy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

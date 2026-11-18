import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ploggr/app.dart';
import 'package:ploggr/routes/app_router.dart';
import 'package:ploggr/routes/app_routes.dart';
import 'package:ploggr/features/onboarding/onboarding_page.dart';
import 'package:ploggr/features/plogging/application/session_controller.dart';
import 'package:ploggr/features/litter/application/litter_controller.dart';
import 'package:ploggr/features/community/community_controller.dart';
import 'package:ploggr/shared/widgets/ploggr_ui.dart';

const screenRoutes = [
  '/',
  '/onboarding',
  '/onboarding?page=1',
  '/onboarding?page=2',
  '/login',
  '/signup',
  '/home',
  '/scan',
  '/report',
  '/map',
  '/session',
  '/session/summary',
  '/cleanups',
  '/challenges',
  '/leaderboard',
  '/badges',
  '/community',
  '/profile',
  '/profile/activity',
  '/profile/saved',
  '/profile/settings',
  '/profile/settings/connection',
  '/profile/help',
  '/profile/about',
];

Future<ProviderContainer> openApp(
  WidgetTester tester,
  String route, {
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  final container = ProviderContainer(
    overrides: [initialLocationProvider.overrideWithValue(route)],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: const PloggrApp(),
      ),
    ),
  );
  await tester.pump();
  if (route != '/') await tester.pumpAndSettle();
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('NunitoSans')
      ..addFont(rootBundle.load('assets/fonts/NunitoSans.ttf'));
    await font.load();
  });
  WidgetController.hitTestWarningShouldBeFatal = true;
  for (final size in [
    const Size(320, 568),
    const Size(320, 640),
    const Size(390, 844),
    const Size(480, 960),
  ]) {
    for (final route in screenRoutes) {
      testWidgets(
        'renders $route at ${size.width.toInt()}px without overflow',
        (tester) async {
          await openApp(tester, route, size: size);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  for (final route in screenRoutes.where((r) => r != '/')) {
    testWidgets('large text remains usable on $route', (tester) async {
      await openApp(tester, route, size: const Size(320, 640), textScale: 1.6);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'splash advances to onboarding and all three pages lead to login',
    (tester) async {
      await openApp(tester, '/');
      await tester.pump(const Duration(milliseconds: 2300));
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingPage), findsOneWidget);
      await tester.tap(find.byTooltip('Next onboarding page'));
      await tester.pumpAndSettle();
      expect(find.text('Take Challenges\n& Earn Rewards'), findsOneWidget);
      await tester.tap(find.byTooltip('Next onboarding page'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome back!'), findsOneWidget);
    },
  );

  testWidgets(
    'login validates, toggles visibility and allows an explicit preview',
    (tester) async {
      await openApp(tester, '/login');
      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.text('Enter an email or phone number'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).first,
        'demo@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'samplepass');
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isFalse,
      );
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Login'));
      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.text('Hi, Vipul! 👋'), findsOneWidget);
    },
  );

  testWidgets('signup requires valid fields and matching passwords', (
    tester,
  ) async {
    await openApp(tester, '/signup');
    final fields = find.byType(TextFormField);
    for (final pair in [
      (0, 'Preview Person'),
      (1, 'preview@example.com'),
      (2, '9999999999'),
      (3, 'samplepass'),
      (4, 'different'),
    ]) {
      await tester.enterText(fields.at(pair.$1), pair.$2);
    }
    await tester.ensureVisible(find.text('Create Account'));
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();
    expect(find.text('Passwords must match'), findsOneWidget);
    await tester.enterText(fields.last, 'samplepass');
    await tester.ensureVisible(find.text('Create Account'));
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();
    expect(find.text('Hi, Vipul! 👋'), findsOneWidget);
  });

  testWidgets('a session can pause, finish, change weight and save once', (
    tester,
  ) async {
    final container = await openApp(tester, '/home');
    await tester.tap(find.text('Start Plog Session'));
    await tester.pumpAndSettle();
    final beforePause = container.read(sessionProvider).seconds;
    await tester.tap(find.byTooltip('Pause session'));
    await tester.pump(const Duration(seconds: 3));
    expect(container.read(sessionProvider).seconds, beforePause);
    await tester.tap(find.byTooltip('Resume session'));
    await tester.pump(const Duration(seconds: 2));
    expect(container.read(sessionProvider).seconds, greaterThan(beforePause));
    await tester.ensureVisible(find.byTooltip('End session'));
    await tester.tap(find.byTooltip('End session'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Increase litter weight'));
    await tester.pump();
    expect(find.text('3.0 kg'), findsOneWidget);
    await tester.tap(find.text('Save Session'));
    await tester.pumpAndSettle();
    expect(container.read(impactProvider).sessions, 19);
    expect(container.read(impactProvider).kg, closeTo(15.4, .001));
    expect(container.read(sessionProvider.notifier).save(), isFalse);
    expect(container.read(impactProvider).sessions, 19);
  });

  testWidgets('saved-session feedback does not cover the next camera shutter', (
    tester,
  ) async {
    await openApp(tester, '/session/summary');
    await tester.tap(find.text('Save Session'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scan Litter'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
    await tester.tap(find.bySemanticsLabel('Capture sample photo'));
    await tester.pumpAndSettle();
    expect(find.text('Glass'), findsOneWidget);
  });

  testWidgets('an unsaved session resumes when returning from its summary', (
    tester,
  ) async {
    final container = await openApp(tester, '/home');
    await tester.tap(find.text('Start Plog Session'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('End session'));
    await tester.pumpAndSettle();
    final stoppedAt = container.read(sessionProvider).seconds;
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Resume session'));
    await tester.pump(const Duration(seconds: 2));
    expect(container.read(sessionProvider).seconds, greaterThan(stoppedAt));
    expect(container.read(sessionProvider).active, isTrue);
  });

  testWidgets(
    'litter report retains the chosen type and description on the map',
    (tester) async {
      final container = await openApp(tester, '/scan');
      await tester.tap(find.bySemanticsLabel('Capture sample photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Glass'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Near the lake');
      await tester.tap(find.text('Add to Litter Map'));
      await tester.pumpAndSettle();
      expect(find.text('Glass Litter'), findsOneWidget);
      expect(container.read(litterProvider).first.description, 'Near the lake');
    },
  );

  testWidgets('challenge and leaderboard filters display different data', (
    tester,
  ) async {
    final container = await openApp(tester, '/challenges');
    await tester.tap(find.text('Upcoming'));
    await tester.pumpAndSettle();
    expect(find.text('Lakeside Together'), findsOneWidget);
    expect(find.text('Campus Clean-up'), findsNothing);
    await tester.tap(find.text('Completed'));
    await tester.pumpAndSettle();
    expect(find.text('First Five'), findsOneWidget);
    container.read(appRouterProvider).go(AppRoutes.leaderboard);
    await tester.pumpAndSettle();
    await tester.tap(find.text('This Week'));
    await tester.pumpAndSettle();
    expect(find.text('8.2 kg'), findsOneWidget);
    await tester.tap(find.text('All Time'));
    await tester.pumpAndSettle();
    expect(find.text('142.8 kg'), findsOneWidget);
  });

  testWidgets('bottom navigation and local community compose work', (
    tester,
  ) async {
    final container = await openApp(tester, '/home');
    await tester.tap(find.text('Community'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Write a preview post'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'A lovely sample plog');
    await tester.pump();
    await tester.tap(find.text('Add Post'));
    await tester.pumpAndSettle();
    expect(
      container.read(communityProvider).first.text,
      'A lovely sample plog',
    );
    await tester.tap(find.text('My Posts'));
    await tester.pumpAndSettle();
    expect(find.text('A lovely sample plog'), findsOneWidget);
    expect(find.text('Ananya P.'), findsNothing);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Vipul Reddy'), findsOneWidget);
    await tester.tap(find.text('My Activity'));
    await tester.pumpAndSettle();
    expect(find.text('18 sessions. A lasting impact.'), findsOneWidget);
  });

  testWidgets('forms remain scrollable with keyboard insets', (tester) async {
    await openApp(tester, '/signup', size: const Size(320, 640));
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetViewInsets);
    await tester.tap(find.byType(AppField).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create Account'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

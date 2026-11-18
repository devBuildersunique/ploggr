import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ploggr/app.dart';
import 'package:ploggr/core/config/app_config.dart';
import 'package:ploggr/core/config/app_config_provider.dart';
import 'package:ploggr/routes/app_router.dart';
import 'package:ploggr/routes/app_routes.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('manual connection check uses Dio and the real backend/database', (
    tester,
  ) async {
    final config = AppConfig.fromEnvironment();
    expect(
      config.apiBaseUrl,
      isNotNull,
      reason: 'Supply API_BASE_URL for this opt-in integration test.',
    );
    final container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        initialLocationProvider.overrideWithValue(AppRoutes.settings),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const PloggrApp()),
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    });
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Connection check'));
    await tester.tap(find.text('Connection check'));
    await tester.pumpAndSettle();
    expect(find.text('Ready to check'), findsOneWidget);
    await tester.tap(find.text('Check connection'));

    const unavailable = bool.fromEnvironment('EXPECT_DATABASE_UNAVAILABLE');
    final result = find.text(
      unavailable ? 'Database unavailable' : 'Connected',
    );
    final deadline = DateTime.now().add(const Duration(seconds: 25));
    // Do not pumpAndSettle while an indeterminate loading indicator is animating.
    while (result.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(result, findsOneWidget);
    expect(find.text('Check again'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

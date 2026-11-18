import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ploggr/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('startup, preview navigation and manual connection check', (
    tester,
  ) async {
    Future<void> waitForText(String label) async {
      final deadline = DateTime.now().add(const Duration(seconds: 30));
      while (find.text(label).evaluate().isEmpty &&
          DateTime.now().isBefore(deadline)) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text(label), findsOneWidget);
    }

    Future<void> tap(String label) async {
      final target = find.text(label);
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    Future<void> check(String button, String expected) async {
      await tester.tap(find.text(button));
      // The spinner keeps animating while Dio awaits the readiness query.
      await waitForText(expected);
      expect(find.text('Check again'), findsOneWidget);
    }

    app.main();
    await waitForText('Skip');
    await tap('Skip');
    await tap('Explore the preview');
    await tap('Profile');
    await tap('Settings');
    await tap('Connection check');

    if (const bool.fromEnvironment('EXPECT_OFFLINE')) {
      expect(find.text('No server configured'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      return;
    }

    expect(find.text('Ready to check'), findsOneWidget);
    const unavailable = bool.fromEnvironment('EXPECT_DATABASE_UNAVAILABLE');
    await check(
      'Check connection',
      unavailable ? 'Database unavailable' : 'Connected',
    );

    // The Linux runner controls its own services. Standalone device tests
    // perform just the check above against the developer's configured stack.
    const directory = String.fromEnvironment('FOUNDATION_SYNC_DIR');
    if (directory.isNotEmpty) {
      for (final (action, expected) in [
        ('stop-database', 'Database unavailable'),
        ('restore-database', 'Connected'),
        ('stop-api', 'Server unavailable'),
        ('restore-api', 'Connected'),
      ]) {
        await File('$directory/$action').create();
        final completed = File('$directory/$action.done');
        final deadline = DateTime.now().add(const Duration(seconds: 120));
        while (!await completed.exists() && DateTime.now().isBefore(deadline)) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(
          await completed.exists(),
          isTrue,
          reason: 'Host timed out during $action',
        );
        await check('Check again', expected);
      }
    }
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(minutes: 8)));
}

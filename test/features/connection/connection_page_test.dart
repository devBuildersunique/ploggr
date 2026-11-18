import 'dart:async';

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ploggr/app.dart';
import 'package:ploggr/core/config/app_config.dart';
import 'package:ploggr/core/config/app_config_provider.dart';
import 'package:ploggr/features/connection/connection_service.dart';
import 'package:ploggr/routes/app_router.dart';
import 'package:ploggr/routes/app_routes.dart';

class PendingService extends ConnectionService {
  PendingService() : super(null);
  final requests = <Completer<ConnectionCheckStatus>>[];
  CancelToken? token;

  @override
  Future<ConnectionCheckStatus> check({CancelToken? cancelToken}) {
    token = cancelToken;
    final pending = Completer<ConnectionCheckStatus>();
    requests.add(pending);
    return pending.future;
  }
}

void main() {
  late PendingService service;

  Future<void> openSettings(
    WidgetTester tester, {
    bool configured = true,
  }) async {
    service = PendingService();
    final container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(
          AppConfig.fromValues(
            apiBaseUrl: configured ? 'http://localhost:3000/api/' : null,
          ),
        ),
        connectionServiceProvider.overrideWithValue(service),
        initialLocationProvider.overrideWithValue(AppRoutes.settings),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const PloggrApp()),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Connection check'));
    await tester.tap(find.text('Connection check'));
    await tester.pumpAndSettle();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    });
  }

  testWidgets(
    'unconfigured preview has no network activity and disables the check',
    (tester) async {
      await openSettings(tester, configured: false);
      expect(find.text('No server configured'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(service.requests, isEmpty);
    },
  );

  testWidgets(
    'starts idle, disables duplicate submissions, then supports another check',
    (tester) async {
      await openSettings(tester);
      expect(find.text('Ready to check'), findsOneWidget);
      expect(service.requests, isEmpty);
      await tester.tap(find.text('Check connection'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(service.requests, hasLength(1));
      service.requests.single.complete(ConnectionCheckStatus.connected);
      await tester.pumpAndSettle();
      expect(find.text('Connected'), findsOneWidget);
      await tester.tap(find.text('Check again'));
      await tester.pump();
      expect(service.requests, hasLength(2));
      service.requests.last.complete(ConnectionCheckStatus.databaseUnavailable);
      await tester.pumpAndSettle();
      expect(find.text('Database unavailable'), findsOneWidget);
      expect(find.text('Connected'), findsNothing);
    },
  );

  for (final failure in {
    ConnectionCheckStatus.unreachable: 'Server unavailable',
    ConnectionCheckStatus.timedOut: 'Connection timed out',
    ConnectionCheckStatus.invalidResponse: 'Unexpected server response',
    ConnectionCheckStatus.httpError: 'Server check failed',
  }.entries) {
    testWidgets('shows ${failure.value} with a retry action', (tester) async {
      await openSettings(tester);
      await tester.tap(find.text('Check connection'));
      await tester.pump();
      service.requests.single.complete(failure.key);
      await tester.pumpAndSettle();
      expect(find.text(failure.value), findsOneWidget);
      expect(find.text('Check again'), findsOneWidget);
      expect(find.text('Connected'), findsNothing);
    });
  }

  testWidgets('leaving cancels the request and ignores its late result', (
    tester,
  ) async {
    await openSettings(tester);
    await tester.tap(find.text('Check connection'));
    await tester.pump();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(service.token!.isCancelled, isTrue);
    service.requests.single.complete(ConnectionCheckStatus.connected);
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Connected'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ploggr/core/config/app_config.dart';
import 'package:ploggr/core/config/app_config_provider.dart';
import 'package:ploggr/core/network/api_client_provider.dart';
import 'package:ploggr/features/connection/connection_service.dart';

class StubAdapter implements HttpClientAdapter {
  StubAdapter(this.respond);
  final FutureOr<ResponseBody> Function(RequestOptions) respond;
  bool closed = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => respond(options);

  @override
  void close({bool force = false}) => closed = true;
}

void main() {
  late Dio client;
  late ConnectionService service;

  setUp(() {
    client = Dio(BaseOptions(baseUrl: 'http://localhost:3000/api/'));
    service = ConnectionService(client);
  });
  tearDown(() => client.close(force: true));

  void response(
    String body, {
    int status = 200,
    String type = 'application/json',
  }) {
    client.httpClientAdapter = StubAdapter(
      (_) => ResponseBody.fromString(
        body,
        status,
        headers: {
          Headers.contentTypeHeader: [type],
        },
      ),
    );
  }

  test('missing configuration never attempts a request', () async {
    expect(
      await ConnectionService(null).check(),
      ConnectionCheckStatus.notConfigured,
    );
  });

  test(
    'uses the configured API prefix and requires all readiness fields',
    () async {
      client.httpClientAdapter = StubAdapter((options) {
        expect(
          options.uri.toString(),
          'http://localhost:3000/api/health/ready',
        );
        expect(options.method, 'GET');
        return ResponseBody.fromString(
          '{"status":"ok","database":"up","postgis":"up"}',
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      });
      expect(await service.check(), ConnectionCheckStatus.connected);
    },
  );

  for (final body in [
    '{}',
    '{"status":"ok"}',
    '{"status":"ok","database":"up","postgis":"down"}',
    '[]',
    'null',
    '{invalid json',
  ]) {
    test('rejects an invalid successful payload: $body', () async {
      response(body);
      expect(await service.check(), ConnectionCheckStatus.invalidResponse);
    });
  }

  test('does not treat an HTML page as a working API', () async {
    response('<html>Not the API</html>', type: 'text/html');
    expect(await service.check(), ConnectionCheckStatus.invalidResponse);
  });

  for (final status in [404, 500, 503]) {
    test('maps HTTP $status without relying on the error body', () async {
      response('{"message":"private driver detail"}', status: status);
      expect(
        await service.check(),
        status == 503
            ? ConnectionCheckStatus.databaseUnavailable
            : ConnectionCheckStatus.httpError,
      );
    });
  }

  for (final type in [
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.transformTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.connectionError,
    DioExceptionType.badCertificate,
  ]) {
    test('maps transport failure $type', () async {
      client.httpClientAdapter = StubAdapter((options) {
        throw DioException(requestOptions: options, type: type);
      });
      expect(
        await service.check(),
        type == DioExceptionType.connectionError ||
                type == DioExceptionType.badCertificate
            ? ConnectionCheckStatus.unreachable
            : ConnectionCheckStatus.timedOut,
      );
    });
  }

  test('cancels an in-flight request', () async {
    final started = Completer<void>();
    final pending = Completer<ResponseBody>();
    client.httpClientAdapter = StubAdapter((_) {
      started.complete();
      return pending.future;
    });
    final token = CancelToken();
    final result = service.check(cancelToken: token);
    await started.future;
    token.cancel();
    expect(await result, ConnectionCheckStatus.cancelled);
    pending.complete(ResponseBody.fromString('{}', 200));
  });

  test('provider uses configured timeouts and closes its owned client', () {
    final container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(
          AppConfig.fromValues(apiBaseUrl: 'https://api.example.com/api/'),
        ),
      ],
    );
    final owned = container.read(apiClientProvider)!;
    expect(owned.options.baseUrl, 'https://api.example.com/api/');
    expect(owned.options.connectTimeout, const Duration(seconds: 5));
    expect(owned.options.receiveTimeout, const Duration(seconds: 15));
    final adapter = StubAdapter((_) => ResponseBody.fromString('{}', 200));
    owned.httpClientAdapter = adapter;
    container.dispose();
    expect(adapter.closed, isTrue);
  });
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client_provider.dart';

enum ConnectionCheckStatus {
  notConfigured,
  idle,
  checking,
  connected,
  unreachable,
  timedOut,
  databaseUnavailable,
  invalidResponse,
  httpError,
  cancelled,
}

final connectionServiceProvider = Provider.autoDispose<ConnectionService>(
  (ref) => ConnectionService(ref.watch(apiClientProvider)),
);

class ConnectionService {
  ConnectionService(this._client);
  final Dio? _client;

  Future<ConnectionCheckStatus> check({CancelToken? cancelToken}) async {
    final client = _client;
    if (client == null) return ConnectionCheckStatus.notConfigured;
    try {
      // Relative path preserves a configured /api/ (or reverse-proxy) prefix.
      final response = await client.get<Object?>(
        'health/ready',
        cancelToken: cancelToken,
      );
      final body = response.data;
      if (response.statusCode == 200 &&
          body is Map &&
          body['status'] == 'ok' &&
          body['database'] == 'up' &&
          body['postgis'] == 'up') {
        return ConnectionCheckStatus.connected;
      }
      return ConnectionCheckStatus.invalidResponse;
    } on DioException catch (error) {
      return switch (error.type) {
        DioExceptionType.cancel => ConnectionCheckStatus.cancelled,
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.transformTimeout ||
        DioExceptionType.receiveTimeout => ConnectionCheckStatus.timedOut,
        DioExceptionType.badResponse =>
          error.response?.statusCode == 503
              ? ConnectionCheckStatus.databaseUnavailable
              : ConnectionCheckStatus.httpError,
        DioExceptionType.connectionError ||
        DioExceptionType.badCertificate => ConnectionCheckStatus.unreachable,
        DioExceptionType.unknown =>
          error.error is FormatException
              ? ConnectionCheckStatus.invalidResponse
              : ConnectionCheckStatus.unreachable,
      };
    } on FormatException {
      return ConnectionCheckStatus.invalidResponse;
    }
  }
}

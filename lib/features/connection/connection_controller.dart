import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config_provider.dart';
import 'connection_service.dart';

final connectionCheckProvider =
    NotifierProvider.autoDispose<ConnectionController, ConnectionCheckStatus>(
      ConnectionController.new,
    );

class ConnectionController extends Notifier<ConnectionCheckStatus> {
  CancelToken? _pending;
  late ConnectionService _service;

  @override
  ConnectionCheckStatus build() {
    _service = ref.watch(connectionServiceProvider);
    ref.onDispose(() => _pending?.cancel());
    return ref.watch(appConfigProvider).apiBaseUrl == null
        ? ConnectionCheckStatus.notConfigured
        : ConnectionCheckStatus.idle;
  }

  Future<void> check() async {
    if (state == ConnectionCheckStatus.notConfigured ||
        state == ConnectionCheckStatus.checking) {
      return;
    }
    final token = CancelToken();
    _pending = token;
    state = ConnectionCheckStatus.checking;
    final result = await _service.check(cancelToken: token);
    if (!ref.mounted || token.isCancelled) return;
    state = result;
  }
}

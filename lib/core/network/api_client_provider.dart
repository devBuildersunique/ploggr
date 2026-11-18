import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config_provider.dart';

final apiClientProvider = Provider.autoDispose<Dio?>((ref) {
  final baseUrl = ref.watch(appConfigProvider).apiBaseUrl;
  if (baseUrl == null) return null;

  final client = Dio(
    BaseOptions(
      baseUrl: baseUrl.toString(),
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
      headers: {'Accept': 'application/json'},
      followRedirects: false,
    ),
  );
  ref.onDispose(() => client.close(force: true));
  return client;
});

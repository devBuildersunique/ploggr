import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ploggr/core/config/app_config.dart';
import 'package:ploggr/core/config/app_config_provider.dart';

void main() {
  test('no API configuration leaves the offline preview available', () {
    expect(AppConfig.fromValues().apiBaseUrl, isNull);
  });

  for (final url in [
    'http://127.0.0.1:3000/api/',
    'http://10.0.2.2:3000/api/',
    'https://api.example.com/api/',
    'http://[::1]:3000/api/',
  ]) {
    test('accepts $url without changing its address', () {
      expect(AppConfig.fromValues(apiBaseUrl: url).apiBaseUrl, Uri.parse(url));
    });
  }

  test(
    'normalizes a trailing slash so relative routes keep the API prefix',
    () {
      final config = AppConfig.fromValues(
        apiBaseUrl: 'https://api.example.com/api',
      );
      expect(config.apiBaseUrl.toString(), 'https://api.example.com/api/');
      expect(
        config.apiBaseUrl!.resolve('health').toString(),
        'https://api.example.com/api/health',
      );
      expect(
        AppConfig.fromValues(
          apiBaseUrl: 'http://localhost:3000',
        ).apiBaseUrl.toString(),
        'http://localhost:3000/',
      );
    },
  );

  for (final invalid in [
    '',
    ' ',
    '/api/',
    'localhost:3000/api/',
    'http:///api/',
    'ftp://localhost/api/',
    'http://localhost:0/api/',
    'http://localhost:65536/api/',
    'http://localhost:abc/api/',
    'http://user:private_password@localhost/api/',
    'http://localhost/api/?token=private_token',
    'http://localhost/api/?',
    'http://localhost/api/#fragment',
    'http://localhost/api/#',
    'http://local host/api/',
    ' http://localhost/api/',
  ]) {
    test(
      'rejects invalid configuration without including the supplied value',
      () {
        try {
          AppConfig.fromValues(apiBaseUrl: invalid);
          fail('Invalid API configuration was accepted');
        } on FormatException catch (error) {
          expect(error.message, startsWith('API_BASE_URL must be'));
          expect(error.source, isNull);
          expect(error.toString(), isNot(contains('private_password')));
          expect(error.toString(), isNot(contains('private_token')));
        }
      },
    );
  }

  test('Riverpod consumers can override configuration explicitly', () {
    final config = AppConfig.fromValues(
      apiBaseUrl: 'http://localhost:4000/api',
    );
    final container = ProviderContainer(
      overrides: [appConfigProvider.overrideWithValue(config)],
    );
    addTearDown(container.dispose);
    expect(container.read(appConfigProvider), same(config));
    expect(container.read(appConfigProvider).apiBaseUrl!.port, 4000);
  });

  test('build declarations reach both AppConfig and its default provider', () {
    // Run this suite both normally and with the committed JSON define example.
    const declared = bool.hasEnvironment('API_BASE_URL');
    const value = String.fromEnvironment('API_BASE_URL');
    final expected = declared ? Uri.parse(value) : null;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(AppConfig.fromEnvironment().apiBaseUrl, expected);
    expect(container.read(appConfigProvider).apiBaseUrl, expected);
  });
}

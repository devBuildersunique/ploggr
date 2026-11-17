/// Public build configuration. Never put credentials or private keys here.
class AppConfig {
  const AppConfig._({this.apiBaseUrl});

  /// Null when no API was configured for the offline preview.
  final Uri? apiBaseUrl;

  factory AppConfig.fromEnvironment() {
    return AppConfig.fromValues(
      apiBaseUrl: const bool.hasEnvironment('API_BASE_URL')
          ? const String.fromEnvironment('API_BASE_URL')
          : null,
    );
  }

  /// Shared parser for build declarations and explicit configuration in tests.
  factory AppConfig.fromValues({String? apiBaseUrl}) {
    if (apiBaseUrl == null) return const AppConfig._();

    // Do not include the supplied value in errors: it might contain credentials.
    const error = FormatException(
      'API_BASE_URL must be an absolute HTTP or HTTPS URL with a hostname, '
      'a valid port, and no credentials, query, or fragment.',
    );
    try {
      if (apiBaseUrl.isEmpty || RegExp(r'\s').hasMatch(apiBaseUrl)) {
        throw error;
      }
      final uri = Uri.parse(apiBaseUrl);
      if ((uri.scheme != 'http' && uri.scheme != 'https') ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty ||
          uri.hasQuery ||
          uri.hasFragment ||
          uri.port < 1 ||
          uri.port > 65535) {
        throw error;
      }
      return AppConfig._(
        apiBaseUrl: uri.replace(
          path: uri.path.endsWith('/') ? uri.path : '${uri.path}/',
        ),
      );
    } on FormatException {
      throw error;
    }
  }
}

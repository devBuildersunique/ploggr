import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config.dart';

/// The default also supports widgets mounted directly by tests, outside main().
final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);

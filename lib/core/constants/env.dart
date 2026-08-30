import 'package:flutter/foundation.dart' show kIsWeb;

/// Reads build-time configuration injected via `--dart-define-from-file`.
/// No API URL is ever hardcoded in source — see env/local.json, env/qa.json,
/// env/production.json and README.md for how to run each flavor.
class Env {
  Env._();

  /// For local development, `env/local.json` intentionally omits
  /// `API_BASE_URL` so this platform-aware default applies: `10.0.2.2` is
  /// the Android emulator's alias for the host machine and is unreachable
  /// from a browser, while Flutter Web must use `localhost`. This lets the
  /// same `env/local.json` work for both `flutter run` (Android) and
  /// `flutter run -d chrome` with no manual switching. qa/production set
  /// `API_BASE_URL` explicitly, so this default never applies to them.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kIsWeb ? 'http://localhost:8000/api' : 'http://10.0.2.2:8000/api',
  );

  static const String name = String.fromEnvironment(
    'ENV_NAME',
    defaultValue: 'local',
  );

  static bool get isProduction => name == 'production';
}

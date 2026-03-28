/// API Configuration for Django Backend
///
/// Contains base URLs and API settings for different environments.
///
/// Usage:
///   flutter run --dart-define=ENV=dev       → http://10.0.2.2:8000/api/ (Android emulator default)
///   flutter run --dart-define=ENV=staging   → http://34.72.231.118/api/ (cloud server)
///   flutter run --dart-define=ENV=prod      → https://your-backend-domain.com/api/
///   flutter run                             → staging (default, so CI and team members work out of the box)
///
/// For physical devices on LAN, you can also override the URL directly:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.2:8000/api/
library;

class ApiConfig {
  // ──────────────────────────────────────────────
  // Environment URLs
  // ──────────────────────────────────────────────

  // Development - Android emulator loopback to host machine
  static const String devBaseUrl = 'http://10.0.2.2:8000/api/';

  // Development - iOS Simulator uses localhost directly
  static const String devBaseUrlIOS = 'http://localhost:8000/api/';

  // Previous dev URLs (LAN IPs) — keep for reference:
  // static const String devBaseUrl = 'http://10.43.92.161:8000/api/';
  // static const String devBaseUrl = 'http://192.168.1.2/api/';
  // static const String devBaseUrl = 'http://localhost:8000/api/';

  // Staging - Cloud server
  static const String stagingBaseUrl = 'http://34.72.231.118/api/';

  // Production - Your deployed Django server
  static const String prodBaseUrl = 'https://your-backend-domain.com/api/';

  // ──────────────────────────────────────────────
  // Environment detection via --dart-define
  // ──────────────────────────────────────────────

  /// Read ENV from compile-time define. Defaults to 'staging'.
  static const String env = String.fromEnvironment('ENV', defaultValue: 'staging');

  /// Optional full URL override via --dart-define=API_BASE_URL=...
  static const String _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

  /// Whether we are running in production mode.
  static bool get isProduction => env == 'prod';

  /// Get the appropriate base URL based on environment.
  ///
  /// Priority:
  ///   1. Explicit API_BASE_URL override (if provided)
  ///   2. ENV-based lookup (dev / staging / prod)
  static String get baseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) return _apiBaseUrlOverride;

    switch (env) {
      case 'dev':
        return devBaseUrl;
      case 'staging':
        return stagingBaseUrl;
      case 'prod':
        return prodBaseUrl;
      default:
        return stagingBaseUrl;
    }
  }

  // API Timeouts (in milliseconds)
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // API Version
  static const String apiVersion = 'v1';
}

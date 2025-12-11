/// App-wide Configuration
///
/// Contains general app settings and constants.

class AppConfig {
  // App Info
  static const String appName = 'Flutter App';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;

  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 1);

  // Token Keys (for secure storage)
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
}

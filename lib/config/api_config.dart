/// API Configuration for Django Backend
///
/// Contains base URLs and API settings for different environments.
/// Switch between dev and prod by changing the getter.
library;

class ApiConfig {
  // Development - Use your machine's local IP for physical devices
  // Use 10.0.2.2 for Android emulator, or your LAN IP for physical devices
  static const String devBaseUrl = 'http://10.0.2.2:8000/api/';

  // Development - iOS Simulator uses localhost directly
  static const String devBaseUrlIOS = 'http://localhost:8000/api/';

  // Production - Your deployed Django server
  static const String prodBaseUrl = 'https://your-backend-domain.com/api/';

  // Current environment - change this for production
  static const bool isProduction = false;

  /// Get the appropriate base URL based on environment
  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;

  // API Timeouts (in milliseconds)
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // API Version
  static const String apiVersion = 'v1';
}

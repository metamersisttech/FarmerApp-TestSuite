/// API Helper - Class-based HTTP client
///
/// Singleton HTTP client wrapper for making API requests.
/// Similar to JS APIClient pattern.
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/config/api_config.dart';
import 'package:flutter_app/core/constants/api_endpoints.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/routes/app_routes.dart';

/// API Client Helper
/// Singleton HTTP client for making API requests
class APIClient {
  static final APIClient _instance = APIClient._internal();
  factory APIClient() => _instance;

  late final Dio _dio;
  String? _authToken;
  bool _isRedirecting = false;

  APIClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConfig.connectionTimeout),
        receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token to every request
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          
          // Enhanced logging for GET requests with query parameters
          if (kDebugMode) {
            print('┌─────────────────────────────────────────');
            print('│ 🚀 REQUEST: ${options.method} ${options.uri}');
            if (options.queryParameters.isNotEmpty) {
              print('│ 🔍 Query Params: ${options.queryParameters}');
            }
            if (options.data != null) {
              print('│ 📦 Data: ${options.data}');
            }
            print('└─────────────────────────────────────────');
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);
          return handler.next(response);
        },
        onError: (error, handler) async {
          _logError(error);

          // Handle 401 Unauthorized errors (token expired)
          if (error.response?.statusCode == 401) {
            final retryResponse = await _handle401Error(error);
            if (retryResponse != null) {
              return handler.resolve(retryResponse);
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// Handle 401 Unauthorized errors
  /// Attempts token refresh first; if that fails, clears user data and
  /// redirects to login page. Returns a [Response] if the retry succeeded.
  Future<Response?> _handle401Error(DioException error) async {
    // Prevent multiple concurrent refresh/redirect attempts
    if (_isRedirecting) return null;
    _isRedirecting = true;

    try {
      final commonHelper = CommonHelper();

      // --- Step 1: Try refreshing the access token ---
      final storedRefresh = await commonHelper.getRefreshToken();
      if (storedRefresh != null && storedRefresh.isNotEmpty) {
        try {
          // Use a bare Dio instance to avoid interceptor loops
          final refreshDio = Dio(BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            headers: {'Content-Type': 'application/json'},
          ));
          final refreshResponse = await refreshDio.post(
            ApiEndpoints.refreshToken,
            data: {'refresh': storedRefresh},
          );

          final newAccessToken = refreshResponse.data['access'] as String?;
          if (newAccessToken != null) {
            // Persist the new token
            await commonHelper.setTokens(accessToken: newAccessToken);
            setAuthorization(newAccessToken);

            // Retry the original request with the new token
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await _dio.fetch(opts);
            return retryResponse;
          }
        } catch (refreshError) {
          if (kDebugMode) {
            print('Token refresh failed: $refreshError');
          }
        }
      }

      // --- Step 2: Refresh failed or no refresh token — clear & redirect ---
      await commonHelper.clearUser();
      clearAuthorization();

      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        AppRoutes.navigateAndRemoveAll(context, AppRoutes.login);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling 401: $e');
      }
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        _isRedirecting = false;
      });
    }

    return null;
  }

  /// Set authorization token for authenticated requests
  void setAuthorization(String token) {
    _authToken = token;
  }

  /// Clear authorization token
  void clearAuthorization() {
    _authToken = null;
  }

  /// Get current auth token
  String? get authToken => _authToken;

  // ============ HTTP Methods ============

  /// GET request
  Future<Response> get(String url, {Map<String, dynamic>? params}) async {
    final response = await _dio.get(url, queryParameters: params);
    _logMethodResponse('GET', url, response);
    return response;
  }

  /// POST request
  Future<Response> post(String url, {dynamic data}) async {
    final response = await _dio.post(url, data: data);
    _logMethodResponse('POST', url, response);
    return response;
  }

  /// PUT request
  Future<Response> put(String url, {dynamic data}) async {
    final response = await _dio.put(url, data: data);
    _logMethodResponse('PUT', url, response);
    return response;
  }

  /// PATCH request
  Future<Response> patch(String url, {dynamic data}) async {
    final response = await _dio.patch(url, data: data);
    _logMethodResponse('PATCH', url, response);
    return response;
  }

  /// DELETE request
  Future<Response> delete(String url, {dynamic data}) async {
    final response = await _dio.delete(url, data: data);
    _logMethodResponse('DELETE', url, response);
    return response;
  }

  /// Log response from HTTP methods
  void _logMethodResponse(String method, String url, Response response) {
    if (kDebugMode) {
      print('[$method] $url => ${response.statusCode}: ${response.data}');
    }
  }

  /// Upload file with multipart form data
  Future<Response> uploadFile(
    String url, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalData,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      ...?additionalData,
    });
    return await _dio.post(url, data: formData);
  }

  // ============ Logging ============

  void _logResponse(Response response) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────');
      print('│ ✅ RESPONSE [${response.statusCode}]: ${response.requestOptions.path}');
      print('│ 📦 Data: ${response.data}');
      print('└─────────────────────────────────────────');
    }
  }

  void _logError(DioException error) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────');
      print('│ ❌ ERROR: ${error.type}');
      print('│ 📍 Path: ${error.requestOptions.path}');
      print('│ 💬 Message: ${error.message}');
      if (error.response != null) {
        print('│ 📦 Response: ${error.response?.data}');
      }
      print('└─────────────────────────────────────────');
    }
  }
}

/// Helper function to set authorization globally
void setAuthorization(String token) {
  APIClient().setAuthorization(token);
}

/// Helper function to get logged in user (for JS-like pattern)
Future<dynamic> getLoggedinUser() async {
  final commonHelper = CommonHelper();
  return await commonHelper.getLoggedInUser();
}

/// API Service
///
/// Base HTTP client for making requests to Django backend using Dio.
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/config/api_config.dart';
import 'package:flutter_app/core/constants/api_endpoints.dart';
import 'package:flutter_app/core/errors/exceptions.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/core/services/api_logger.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/routes/app_routes.dart';

/// API Service for HTTP requests using Dio
class ApiService {
  late final Dio _dio;

  // Store auth token
  String? _authToken;

  // Common helper for token storage
  final CommonHelper _commonHelper = CommonHelper();

  // Flag to prevent multiple redirects
  bool _isRedirecting = false;

  ApiService() {
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

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token to every request
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          _logRequest(options.method, options.path, options.data);
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
  /// Attempts token refresh first; if that fails, clears tokens and redirects
  /// to login page. Returns a [Response] if the retry succeeded.
  Future<Response?> _handle401Error(DioException error) async {
    // Prevent multiple concurrent refresh/redirect attempts
    if (_isRedirecting) return null;
    _isRedirecting = true;

    try {
      // --- Step 1: Try refreshing the access token ---
      final storedRefresh = await _commonHelper.getRefreshToken();
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
            await _commonHelper.setTokens(accessToken: newAccessToken);
            setAuthToken(newAccessToken);

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
      await _commonHelper.clearAll();
      clearAuthToken();

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

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  // ============ HTTP Methods ============

  /// GET request
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(endpoint, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PUT request
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.put(endpoint, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PATCH request
  Future<Response> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.patch(endpoint, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.delete(endpoint, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Upload file with multipart form data
  Future<Response> uploadFile(
    String endpoint, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?additionalData,
      });
      return await _dio.post(endpoint, data: formData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============ Error Handling ============

  /// Handle Dio errors and convert to custom exceptions
  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(message: 'Connection timeout. Please try again.');

      case DioExceptionType.connectionError:
        return NetworkException(message: 'No internet connection.');

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled.');

      default:
        return ApiException(
          message: error.message ?? 'An unexpected error occurred.',
        );
    }
  }

  /// Handle HTTP response errors
  ApiException _handleResponseError(Response? response) {
    if (response == null) {
      return ApiException(message: 'No response from server.');
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;
    
    // Extract error message from various Django response formats
    final message = _extractErrorMessage(data);

    switch (statusCode) {
      case 400:
        return BadRequestException(
          message: message ?? 'Bad request',
          data: data,
        );
      case 401:
        return UnauthorizedException(
          message: message ?? 'Unauthorized. Please login again.',
        );
      case 403:
        return ForbiddenException(
          message: message ?? 'Access forbidden.',
        );
      case 404:
        return NotFoundException(
          message: message ?? 'Resource not found.',
        );
      case 422:
        return ValidationException(
          message: message ?? 'Validation failed.',
          errors: data is Map ? data['errors'] as Map<String, dynamic>? : null,
        );
      default:
        if (statusCode >= 500) {
          return ServerException(
            message: message ?? 'Server error. Please try again later.',
          );
        }
        return ApiException(
          message: message ?? 'Unknown error occurred.',
          statusCode: statusCode,
        );
    }
  }

  /// Extract error message from Django response
  /// Handles various formats:
  /// - { "message": "..." }
  /// - { "detail": "..." }
  /// - { "error": "..." }
  /// - { "username": ["A user with that username already exists."] }
  /// - { "email": ["user with this email already exists."] }
  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;
    
    if (data is String) return data;
    
    if (data is Map) {
      // Check for common message fields first
      if (data['message'] != null) return data['message'].toString();
      if (data['detail'] != null) return data['detail'].toString();
      if (data['error'] != null) return data['error'].toString();
      
      // Check for field-specific validation errors (Django format)
      // { "username": ["error message"], "email": ["error message"] }
      final fieldErrors = <String>[];
      data.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          // Field error: "username": ["A user with that username already exists."]
          fieldErrors.add(value.first.toString());
        } else if (value is String) {
          // Field error: "username": "error message"
          fieldErrors.add(value);
        }
      });
      
      if (fieldErrors.isNotEmpty) {
        return fieldErrors.join('\n');
      }
    }
    
    return null;
  }

  // ============ Logging ============

  void _logRequest(String method, String path, dynamic data) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────');
      print('│ 🚀 REQUEST: $method ${ApiConfig.baseUrl}$path');
      if (data != null) {
        print('│ 📦 Data: $data');
      }
      print('└─────────────────────────────────────────');
    }
    // File logging
    ApiLogger.logRequest(method, '${ApiConfig.baseUrl}$path', data);
  }

  void _logResponse(Response response) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────');
      print('│ ✅ RESPONSE [${response.statusCode}]: ${response.requestOptions.path}');
      print('│ 📦 Data: ${response.data}');
      print('└─────────────────────────────────────────');
    }
    // File logging
    ApiLogger.logResponse(
      response.statusCode ?? 0,
      response.requestOptions.path,
      response.data,
    );
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
    // File logging
    ApiLogger.logError(
      error.type.toString(),
      error.requestOptions.path,
      error.message,
      error.response?.data,
    );
  }
}

/// API Service
///
/// Base HTTP client for making requests to Django backend using Dio.
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/config/api_config.dart';
import 'package:flutter_app/core/errors/exceptions.dart';

/// API Service for HTTP requests using Dio
class ApiService {
  late final Dio _dio;

  // Store auth token
  String? _authToken;

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
        onError: (error, handler) {
          _logError(error);
          return handler.next(error);
        },
      ),
    );
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
  }

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

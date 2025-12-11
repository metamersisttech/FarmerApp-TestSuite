/// API Service
///
/// Base HTTP client for making requests to Django backend.
/// TODO: Add 'dio' package to pubspec.yaml for full implementation.
///       Run: flutter pub add dio
///
/// For now, this is a placeholder structure. Uncomment when Dio is added.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/config/api_config.dart';
import 'package:flutter_app/core/errors/exceptions.dart';

/// API Service for HTTP requests
/// 
/// Basic implementation using dart:io HttpClient.
/// For production, consider using the 'dio' package for better features.
class ApiService {
  final String baseUrl = ApiConfig.baseUrl;

  // Store auth token
  String? _authToken;

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  /// Get default headers
  // ignore: unused_element
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  /// Handle API response and errors
  // ignore: unused_element
  dynamic _handleResponse(int statusCode, String body) {
    if (kDebugMode) {
      print('API Response [$statusCode]: $body');
    }

    final dynamic data = body.isNotEmpty ? jsonDecode(body) : null;

    switch (statusCode) {
      case 200:
      case 201:
        return data;
      case 400:
        throw BadRequestException(
          message: data?['message'] ?? 'Bad request',
          data: data,
        );
      case 401:
        throw UnauthorizedException(
          message: data?['message'] ?? 'Unauthorized',
        );
      case 403:
        throw ForbiddenException(
          message: data?['message'] ?? 'Forbidden',
        );
      case 404:
        throw NotFoundException(
          message: data?['message'] ?? 'Not found',
        );
      case 422:
        throw ValidationException(
          message: data?['message'] ?? 'Validation failed',
          errors: data?['errors'] as Map<String, dynamic>?,
        );
      default:
        if (statusCode >= 500) {
          throw ServerException(
            message: data?['message'] ?? 'Server error',
          );
        }
        throw ApiException(
          message: data?['message'] ?? 'Unknown error',
          statusCode: statusCode,
        );
    }
  }

  // ============ HTTP Methods (Placeholder) ============
  // 
  // For full implementation, add 'dio' package and use:
  //
  // final Dio _dio = Dio(BaseOptions(
  //   baseUrl: ApiConfig.baseUrl,
  //   connectTimeout: Duration(milliseconds: ApiConfig.connectionTimeout),
  //   receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
  // ));
  //
  // Future<Response> get(String endpoint) async {
  //   return await _dio.get(endpoint, options: Options(headers: _headers));
  // }
  //
  // Future<Response> post(String endpoint, Map<String, dynamic> data) async {
  //   return await _dio.post(endpoint, data: data, options: Options(headers: _headers));
  // }
  //
  // Future<Response> put(String endpoint, Map<String, dynamic> data) async {
  //   return await _dio.put(endpoint, data: data, options: Options(headers: _headers));
  // }
  //
  // Future<Response> delete(String endpoint) async {
  //   return await _dio.delete(endpoint, options: Options(headers: _headers));
  // }

  /// Log API call in debug mode
  // ignore: unused_element
  void _logRequest(String method, String endpoint, [dynamic data]) {
    if (kDebugMode) {
      print('API $method: $baseUrl$endpoint');
      if (data != null) {
        print('Data: ${jsonEncode(data)}');
      }
    }
  }
}


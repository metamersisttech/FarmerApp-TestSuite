/// Custom Exceptions for API Error Handling
///
/// Use these exceptions to handle different types of errors
/// from the Django backend.
library;

/// Base exception class for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// 400 - Bad Request
class BadRequestException extends ApiException {
  BadRequestException({super.message = 'Bad request', super.data})
      : super(statusCode: 400);
}

/// 401 - Unauthorized (Invalid or expired token)
class UnauthorizedException extends ApiException {
  UnauthorizedException({super.message = 'Unauthorized access'})
      : super(statusCode: 401);
}

/// 403 - Forbidden (No permission)
class ForbiddenException extends ApiException {
  ForbiddenException({super.message = 'Access forbidden'})
      : super(statusCode: 403);
}

/// 404 - Not Found
class NotFoundException extends ApiException {
  NotFoundException({super.message = 'Resource not found'})
      : super(statusCode: 404);
}

/// 422 - Validation Error
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException({
    super.message = 'Validation failed',
    this.errors,
  }) : super(statusCode: 422, data: errors);
}

/// 500 - Server Error
class ServerException extends ApiException {
  ServerException({super.message = 'Internal server error'})
      : super(statusCode: 500);
}

/// Network Error (No internet connection)
class NetworkException extends ApiException {
  NetworkException({super.message = 'No internet connection'})
      : super(statusCode: null);
}

/// Timeout Exception
class TimeoutException extends ApiException {
  TimeoutException({super.message = 'Request timeout'})
      : super(statusCode: null);
}

/// Cache Exception
class CacheException implements Exception {
  final String message;

  CacheException({this.message = 'Cache error'});

  @override
  String toString() => 'CacheException: $message';
}


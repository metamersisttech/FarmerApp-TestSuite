/// Custom Exceptions for API Error Handling
///
/// Use these exceptions to handle different types of errors
/// from the Django backend.

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
  BadRequestException({String message = 'Bad request', dynamic data})
      : super(message: message, statusCode: 400, data: data);
}

/// 401 - Unauthorized (Invalid or expired token)
class UnauthorizedException extends ApiException {
  UnauthorizedException({String message = 'Unauthorized access'})
      : super(message: message, statusCode: 401);
}

/// 403 - Forbidden (No permission)
class ForbiddenException extends ApiException {
  ForbiddenException({String message = 'Access forbidden'})
      : super(message: message, statusCode: 403);
}

/// 404 - Not Found
class NotFoundException extends ApiException {
  NotFoundException({String message = 'Resource not found'})
      : super(message: message, statusCode: 404);
}

/// 422 - Validation Error
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException({
    String message = 'Validation failed',
    this.errors,
  }) : super(message: message, statusCode: 422, data: errors);
}

/// 500 - Server Error
class ServerException extends ApiException {
  ServerException({String message = 'Internal server error'})
      : super(message: message, statusCode: 500);
}

/// Network Error (No internet connection)
class NetworkException extends ApiException {
  NetworkException({String message = 'No internet connection'})
      : super(message: message, statusCode: null);
}

/// Timeout Exception
class TimeoutException extends ApiException {
  TimeoutException({String message = 'Request timeout'})
      : super(message: message, statusCode: null);
}

/// Cache Exception
class CacheException implements Exception {
  final String message;

  CacheException({this.message = 'Cache error'});

  @override
  String toString() => 'CacheException: $message';
}


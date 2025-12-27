import 'package:flutter/foundation.dart';

/// Base controller with common functionality for state management
abstract class BaseController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  /// Current loading state
  bool get isLoading => _isLoading;

  /// Current error message
  String? get errorMessage => _errorMessage;

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Execute async operation with automatic loading and error handling
  Future<T?> executeAsync<T>(
    Future<T> Function() operation, {
    String? errorMessage,
  }) async {
    try {
      setLoading(true);
      clearError();
      return await operation();
    } catch (e) {
      setError(errorMessage ?? 'An error occurred');
      return null;
    } finally {
      setLoading(false);
    }
  }
}


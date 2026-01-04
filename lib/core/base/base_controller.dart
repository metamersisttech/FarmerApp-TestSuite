import 'package:flutter/foundation.dart';

/// Base controller with common functionality for state management
abstract class BaseController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;

  /// Current loading state
  bool get isLoading => _isLoading;

  /// Current error message
  String? get errorMessage => _errorMessage;

  /// Check if controller is disposed
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Set loading state (safe - checks if disposed)
  void setLoading(bool loading) {
    if (_isDisposed) return;
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message (safe - checks if disposed)
  void setError(String? error) {
    if (_isDisposed) return;
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message (safe - checks if disposed)
  void clearError() {
    if (_isDisposed) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Execute async operation with automatic loading and error handling
  Future<T?> executeAsync<T>(
    Future<T> Function() operation, {
    String? errorMessage,
  }) async {
    if (_isDisposed) return null;
    try {
      setLoading(true);
      clearError();
      return await operation();
    } catch (e) {
      if (!_isDisposed) {
        setError(errorMessage ?? 'An error occurred');
      }
      return null;
    } finally {
      if (!_isDisposed) {
        setLoading(false);
      }
    }
  }
}


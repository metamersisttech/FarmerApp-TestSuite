/// API Logger Service
///
/// File-based logging for API calls to enable easy debugging and review.
/// Writes requests, responses, and errors to a file on the device.
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// API Logger for file-based logging of API calls
class ApiLogger {
  static File? _logFile;
  static IOSink? _sink;
  static bool _initialized = false;

  /// Initialize logger - call once at app startup
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      _logFile = File('${dir.path}/api_logs.txt');

      // Clear old logs on app start
      if (await _logFile!.exists()) {
        await _logFile!.writeAsString('');
      }

      _sink = _logFile!.openWrite(mode: FileMode.append);
      _initialized = true;

      _log('=== API Logger Initialized ===');
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize ApiLogger: $e');
      }
    }
  }

  static void _log(String message) {
    if (!_initialized || _sink == null) return;

    final timestamp = DateTime.now().toIso8601String();
    final line = '[$timestamp] $message\n';
    _sink?.write(line);
  }

  /// Log API request
  static void logRequest(String method, String url, dynamic data) {
    if (!kDebugMode || !_initialized) return;

    _log('REQUEST: $method $url');
    if (data != null) {
      _log('  Body: $data');
    }
  }

  /// Log API response
  static void logResponse(int statusCode, String path, dynamic data) {
    if (!kDebugMode || !_initialized) return;

    _log('RESPONSE [$statusCode]: $path');
    _log('  Data: $data');
  }

  /// Log API error
  static void logError(String type, String path, String? message, dynamic response) {
    if (!kDebugMode || !_initialized) return;

    _log('ERROR: $type');
    _log('  Path: $path');
    _log('  Message: $message');
    if (response != null) {
      _log('  Response: $response');
    }
  }

  /// Get all logs as string (for viewing in-app)
  static Future<String> getLogs() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return 'No logs available';
    }
    await _sink?.flush();
    return await _logFile!.readAsString();
  }

  /// Clear all logs
  static Future<void> clearLogs() async {
    if (_logFile != null && await _logFile!.exists()) {
      await _sink?.flush();
      await _logFile!.writeAsString('');
      _log('=== Logs Cleared ===');
    }
  }

  /// Get log file path (for adb pull)
  static Future<String?> getLogFilePath() async {
    return _logFile?.path;
  }

  /// Dispose logger (call on app close)
  static Future<void> dispose() async {
    await _sink?.flush();
    await _sink?.close();
    _initialized = false;
  }
}

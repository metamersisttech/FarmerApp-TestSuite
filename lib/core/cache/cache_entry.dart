/// Cache entry with TTL and timestamp metadata
/// 
/// Wraps cached data with expiration logic. Used by CacheManager
/// to determine if cached data is still valid.
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration ttl;
  
  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });
  
  /// Check if cache entry has expired
  bool get isExpired {
    return DateTime.now().difference(timestamp) > ttl;
  }
  
  /// Convert to JSON for Hive storage
  Map<String, dynamic> toJson(dynamic Function(T) toJsonT) => {
    'data': toJsonT(data),
    'timestamp': timestamp.toIso8601String(),
    'ttl': ttl.inSeconds,
  };
  
  /// Create from JSON (Hive retrieval)
  /// Handles both Map<String, dynamic> and Map<dynamic, dynamic> from Hive
  factory CacheEntry.fromJson(
    dynamic json,
    T Function(dynamic) fromJsonT,
  ) {
    // Convert Map<dynamic, dynamic> to Map<String, dynamic> if needed
    final Map<String, dynamic> jsonMap = json is Map<String, dynamic>
        ? json
        : Map<String, dynamic>.from(json as Map);
    
    return CacheEntry(
      data: fromJsonT(jsonMap['data']),
      timestamp: DateTime.parse(jsonMap['timestamp'] as String),
      ttl: Duration(seconds: jsonMap['ttl'] as int),
    );
  }
}
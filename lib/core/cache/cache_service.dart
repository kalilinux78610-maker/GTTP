import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gttp/core/security/secure_storage_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service for caching API responses locally using Hive
class CacheService {
  static const String _cacheBoxName = 'gttp_cache';
  static const String _metadataBoxName = 'gttp_cache_metadata';
  
  static CacheService? _instance;
  static bool _initialized = false;

  CacheService._();

  /// Get singleton instance
  static CacheService get instance {
    _instance ??= CacheService._();
    return _instance!;
  }

  /// Initialize Hive and open cache boxes
  static Future<void> initialize() async {
    if (_initialized) return;
    
    await Hive.initFlutter();

    final secureStorage = SecureStorageService.create();
    final encryptionKey = await secureStorage.getOrCreateHiveKey();
    final cipher = HiveAesCipher(encryptionKey);

    try {
      await Hive.openBox<String>(_cacheBoxName, encryptionCipher: cipher);
      await Hive.openBox<Map>(_metadataBoxName, encryptionCipher: cipher);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Cache] Error opening box (possibly unencrypted migration): $e');
      }
      // Delete corrupted or unencrypted boxes
      await Hive.deleteBoxFromDisk(_cacheBoxName);
      await Hive.deleteBoxFromDisk(_metadataBoxName);
      // Try again
      await Hive.openBox<String>(_cacheBoxName, encryptionCipher: cipher);
      await Hive.openBox<Map>(_metadataBoxName, encryptionCipher: cipher);
    }

    _initialized = true;
    
    if (kDebugMode) {
      debugPrint('[Cache] Initialized successfully with encryption');
    }
  }

  /// Get the cache box
  Box<String> get _cacheBox => Hive.box<String>(_cacheBoxName);

  /// Cache data with a key
  Future<void> put<T>(
    String key,
    T data, {
    Duration? ttl,
  }) async {
    final cacheEntry = {
      'data': data is String ? data : jsonEncode(data),
      'cachedAt': DateTime.now().toIso8601String(),
      'ttl': ttl?.inSeconds,
      'type': T.toString(),
    };
    
    await _cacheBox.put(key, jsonEncode(cacheEntry));
    
    if (kDebugMode) {
      debugPrint('[Cache] Cached: $key (TTL: ${ttl?.inSeconds ?? 'none'}s)');
    }
  }

  /// Get cached data
  T? get<T>(
    String key, {
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    final cached = _cacheBox.get(key);
    if (cached == null) return null;
    
    try {
      final entry = jsonDecode(cached) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(entry['cachedAt'] as String);
      final ttl = entry['ttl'] as int?;
      
      // Check if expired
      if (ttl != null) {
        final expiresAt = cachedAt.add(Duration(seconds: ttl));
        if (DateTime.now().isAfter(expiresAt)) {
          if (kDebugMode) {
            debugPrint('[Cache] Expired: $key');
          }
          _cacheBox.delete(key);
          return null;
        }
      }
      
      final data = entry['data'];
      
      if (T == String) {
        return data as T;
      }
      
      if (fromJson != null && data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return fromJson(decoded);
        }
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>().map(fromJson).toList() as T;
        }
      }
      
      if (data is T) return data;
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Cache] Error reading $key: $e');
      }
      return null;
    }
  }

  /// Get cached list of items
  List<T>? getList<T>(
    String key, {
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    final cached = _cacheBox.get(key);
    if (cached == null) return null;
    
    try {
      final entry = jsonDecode(cached) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(entry['cachedAt'] as String);
      final ttl = entry['ttl'] as int?;
      
      // Check if expired
      if (ttl != null) {
        final expiresAt = cachedAt.add(Duration(seconds: ttl));
        if (DateTime.now().isAfter(expiresAt)) {
          if (kDebugMode) {
            debugPrint('[Cache] Expired: $key');
          }
          _cacheBox.delete(key);
          return null;
        }
      }
      
      final data = entry['data'];
      if (data is! String) return null;
      
      final decoded = jsonDecode(data);
      if (decoded is! List) return null;
      
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .map(fromJson)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Cache] Error reading list $key: $e');
      }
      return null;
    }
  }

  /// Cache a list of items
  Future<void> putList<T>(
    String key,
    List<T> data, {
    Duration? ttl,
  }) async {
    final cacheEntry = {
      'data': jsonEncode(data),
      'cachedAt': DateTime.now().toIso8601String(),
      'ttl': ttl?.inSeconds,
      'type': 'List<${T.toString()}>',
    };
    
    await _cacheBox.put(key, jsonEncode(cacheEntry));
    
    if (kDebugMode) {
      debugPrint('[Cache] Cached list: $key (${data.length} items, TTL: ${ttl?.inSeconds ?? 'none'}s)');
    }
  }

  /// Check if key exists and is not expired
  bool has(String key) {
    final cached = _cacheBox.get(key);
    if (cached == null) return false;
    
    try {
      final entry = jsonDecode(cached) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(entry['cachedAt'] as String);
      final ttl = entry['ttl'] as int?;
      
      if (ttl != null) {
        final expiresAt = cachedAt.add(Duration(seconds: ttl));
        return DateTime.now().isBefore(expiresAt);
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove a cached item
  Future<void> delete(String key) async {
    await _cacheBox.delete(key);
    if (kDebugMode) {
      debugPrint('[Cache] Deleted: $key');
    }
  }

  /// Clear all cache
  Future<void> clearAll() async {
    await _cacheBox.clear();
    if (kDebugMode) {
      debugPrint('[Cache] Cleared all cache');
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    final keys = _cacheBox.keys.toList();
    final totalSize = keys.fold<int>(0, (sum, key) {
      final value = _cacheBox.get(key);
      return sum + (value?.length ?? 0);
    });
    
    return {
      'totalKeys': keys.length,
      'totalSizeBytes': totalSize,
      'keys': keys,
    };
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gttp/core/network/api_client.dart';
import 'package:gttp/core/security/secure_storage_service.dart';

class SyncQueueService {
  static const String _boxName = 'gttp_sync_queue';
  
  static SyncQueueService? _instance;
  static bool _initialized = false;

  SyncQueueService._();

  static SyncQueueService get instance {
    _instance ??= SyncQueueService._();
    return _instance!;
  }

  static Future<void> initialize() async {
    if (_initialized) return;
    await Hive.initFlutter();
    
    final secureStorage = SecureStorageService.create();
    final encryptionKey = await secureStorage.getOrCreateHiveKey();
    final cipher = HiveAesCipher(encryptionKey);
    
    try {
      await Hive.openBox<String>(_boxName, encryptionCipher: cipher);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SyncQueue] Error opening box (possibly unencrypted migration): $e');
      }
      await Hive.deleteBoxFromDisk(_boxName);
      await Hive.openBox<String>(_boxName, encryptionCipher: cipher);
    }

    _initialized = true;
    if (kDebugMode) {
      debugPrint('[SyncQueue] Initialized successfully with encryption');
    }
  }

  Box<String> get _box => Hive.box<String>(_boxName);

  /// Enqueue a failed POST request
  Future<void> enqueue(String endpoint, Map<String, dynamic> payload, {bool requiresAuth = true}) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final task = {
      'id': id,
      'endpoint': endpoint,
      'payload': payload,
      'requiresAuth': requiresAuth,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    await _box.put(id, jsonEncode(task));
    
    if (kDebugMode) {
      debugPrint('[SyncQueue] Enqueued task to $endpoint (ID: $id)');
    }
  }

  /// Process the queue, sending all saved tasks
  Future<void> processQueue(ApiClient apiClient) async {
    if (_box.isEmpty) return;

    if (kDebugMode) {
      debugPrint('[SyncQueue] Processing ${_box.length} offline tasks...');
    }

    final keys = _box.keys.toList();
    
    for (final key in keys) {
      final jsonString = _box.get(key);
      if (jsonString == null) continue;

      try {
        final task = jsonDecode(jsonString) as Map<String, dynamic>;
        final endpoint = task['endpoint'] as String;
        final payload = task['payload'] as Map<String, dynamic>;
        final requiresAuth = task['requiresAuth'] as bool? ?? true;

        if (kDebugMode) {
          debugPrint('[SyncQueue] Sending task $key to $endpoint...');
        }

        // Send the request
        await apiClient.post(endpoint, data: payload, requiresAuth: requiresAuth);

        // Remove from queue on success
        await _box.delete(key);
        
        if (kDebugMode) {
          debugPrint('[SyncQueue] Successfully synced task $key');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[SyncQueue] Task $key failed to sync (will retry later): $e');
        }
        // Break out so we don't spam requests if the internet drops mid-sync
        break;
      }
    }
  }
}

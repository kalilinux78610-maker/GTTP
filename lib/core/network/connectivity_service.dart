import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for checking network connectivity
class ConnectivityService {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  List<ConnectivityResult> _currentResults = [ConnectivityResult.none];

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Check if device is currently online
  bool get isOnline =>
      _currentResults.isNotEmpty &&
      !_currentResults.contains(ConnectivityResult.none) &&
      !_currentResults.every((r) => r == ConnectivityResult.none);

  /// Check if device is offline
  bool get isOffline => !isOnline;

  /// Get current connectivity results
  List<ConnectivityResult> get currentResults => List.unmodifiable(_currentResults);

  /// Stream of connectivity changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Initialize and get current status
  Future<void> initialize() async {
    _currentResults = await _connectivity.checkConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _currentResults = results;
      if (kDebugMode) {
        debugPrint('[Connectivity] Status changed: $results');
      }
    });
    
    if (kDebugMode) {
      debugPrint('[Connectivity] Initial status: $_currentResults');
    }
  }

  /// Check connectivity manually
  Future<bool> checkConnectivity() async {
    _currentResults = await _connectivity.checkConnectivity();
    return isOnline;
  }

  /// Dispose subscription
  void dispose() {
    _subscription?.cancel();
  }
}

/// Provider for ConnectivityService
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for current online status
final isOnlineProvider = NotifierProvider<ConnectivityNotifier, bool>(() {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends Notifier<bool> {
  ConnectivityService? _connectivityService;

  @override
  bool build() {
    _connectivityService = ref.read(connectivityServiceProvider);
    _initialize();
    return false;
  }

  Future<void> _initialize() async {
    await _connectivityService!.initialize();
    state = _connectivityService!.isOnline;
    
    _connectivityService!.onConnectivityChanged.listen((results) {
      final isOnline = !results.contains(ConnectivityResult.none) &&
          results.isNotEmpty;
      state = isOnline;
    });
  }

  Future<void> checkConnectivity() async {
    state = await _connectivityService!.checkConnectivity();
  }
}

/// Provider that shows connectivity status with user-friendly message
final connectivityStatusProvider = Provider<String>((ref) {
  final isOnline = ref.watch(isOnlineProvider);
  if (isOnline) return 'Online';
  return 'Offline';
});

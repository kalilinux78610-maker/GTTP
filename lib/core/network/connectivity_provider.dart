import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  
  // Initial check
  final initialStatus = await connectivity.checkConnectivity();
  yield !initialStatus.contains(ConnectivityResult.none);

  // Listen to changes
  await for (final status in connectivity.onConnectivityChanged) {
    yield !status.contains(ConnectivityResult.none);
  }
});

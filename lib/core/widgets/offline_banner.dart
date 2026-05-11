import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/network/connectivity_service.dart';

/// A banner widget that shows when the device is offline
class OfflineBanner extends ConsumerWidget {
  final bool showWhenOnline;
  
  const OfflineBanner({
    super.key,
    this.showWhenOnline = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    
    if (isOnline && !showWhenOnline) {
      return const SizedBox.shrink();
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isOnline ? 0 : 40,
      child: Material(
        color: isOnline ? Colors.green : const Color(0xFFF59E0B),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isOnline ? Icons.wifi : Icons.wifi_off,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                isOnline ? 'Back Online' : 'You are offline — showing cached data',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A wrapper widget that adds offline banner to a screen
class OfflineAwareScaffold extends ConsumerWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;

  const OfflineAwareScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      body: Column(
        children: [
          // Offline banner
          if (!isOnline) const OfflineBanner(),
          // Main content
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// A simple connectivity status indicator for app bars
class ConnectivityIndicator extends ConsumerWidget {
  const ConnectivityIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        shape: BoxShape.circle,
      ),
    );
  }
}

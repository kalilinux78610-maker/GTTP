import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationUtils {
  /// Safely pops the current screen.
  /// If the navigator cannot pop (e.g., if the user deep-linked directly into this screen
  /// or it was pushed as a replacement route), it falls back to routing to the dashboard.
  static void safePop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/dashboard');
    }
  }
}

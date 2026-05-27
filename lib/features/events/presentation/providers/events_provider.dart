import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/network/connectivity_service.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/events_repository_impl.dart';

final eventsProvider = FutureProvider.autoDispose<List<EventModel>>((ref) async {
  final timer = Timer.periodic(const Duration(seconds: 30), (_) {
    if (ref.read(isOnlineProvider)) {
      ref.invalidateSelf();
    }
  });
  ref.onDispose(timer.cancel);

  final repository = ref.watch(eventsRepositoryProvider);
  return repository.getEvents();
});

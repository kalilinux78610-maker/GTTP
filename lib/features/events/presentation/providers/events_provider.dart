import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/events_repository_impl.dart';

final eventsProvider = FutureProvider.autoDispose<List<EventModel>>((ref) async {
  final repository = ref.watch(eventsRepositoryProvider);
  return repository.getEvents();
});

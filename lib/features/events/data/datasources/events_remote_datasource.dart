import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/network/api_client.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import '../models/event_model.dart';

final eventsRemoteDataSourceProvider = Provider<EventsRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EventsRemoteDataSource(apiClient);
});

class EventsRemoteDataSource {
  final ApiClient _apiClient;

  EventsRemoteDataSource(this._apiClient);

  Future<List<EventModel>> getEvents() async {
    final response = await _apiClient.get('/events', requiresAuth: true);

    final data = response['data'];
    final normalized = _normalizeEventsPayload(data);

    return normalized
        .map((json) => EventModel.fromJson(json))
        .toList();
  }

  List<Map<String, dynamic>> _normalizeEventsPayload(dynamic payload) {
    if (payload is List) {
      return payload
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    if (payload is Map<String, dynamic>) {
      // Some endpoints return a single event object in `data`.
      return [payload];
    }

    return const <Map<String, dynamic>>[];
  }
}

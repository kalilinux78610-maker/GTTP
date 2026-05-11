import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/network/api_exception.dart';
import '../../domain/repositories/events_repository.dart';
import '../datasources/events_remote_datasource.dart';
import '../models/event_model.dart';

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  final remoteDataSource = ref.watch(eventsRemoteDataSourceProvider);
  return EventsRepositoryImpl(remoteDataSource);
});

class EventsRepositoryImpl implements EventsRepository {
  final EventsRemoteDataSource _remoteDataSource;

  EventsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<EventModel>> getEvents() async {
    try {
      return await _remoteDataSource.getEvents();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch events: $e');
    }
  }
}

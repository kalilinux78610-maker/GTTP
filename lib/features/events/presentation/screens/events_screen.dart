import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/events_provider.dart';
import '../../data/models/event_model.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2A3A4A), size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Events & Gallery',
          style: TextStyle(
            color: Color(0xFF2A3A4A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6B7280)),
            onPressed: () => ref.refresh(eventsProvider),
          ),
        ],
      ),
      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(eventsProvider),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                16, 16, 16,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return _EventCard(event: events[index]);
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE65C00)),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Failed to load events',
                style: TextStyle(fontSize: 16, color: Colors.red.shade400),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(eventsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No events available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to event detail
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    event.imageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                  ),
                )
              else
                _buildPlaceholderImage(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (event.eventDate != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today, size: 12, color: Color(0xFFDC2626)),
                                const SizedBox(width: 4),
                                Text(
                                  event.eventDate!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(event.status).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            event.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(event.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A3A4A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                    if (event.location != null || event.eventTime != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (event.eventTime != null) ...[
                            const Icon(Icons.access_time, size: 16, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 4),
                            Text(
                              event.eventTime!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          if (event.location != null) ...[
                            const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
      case 'active':
        return const Color(0xFF059669); // Green
      case 'past':
      case 'completed':
        return const Color(0xFF6B7280); // Gray
      case 'upcoming':
      default:
        return const Color(0xFF3286C9); // Blue
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFE5E7EB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Center(
        child: Icon(
          Icons.photo_library_outlined,
          size: 48,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}

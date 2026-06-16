import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/widgets/full_screen_image_viewer.dart';
import 'package:gttp/features/courses/presentation/widgets/course_cover_image.dart';
import 'package:gttp/features/events/data/models/event_model.dart';
import 'package:gttp/features/events/presentation/providers/events_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/router/navigation_utils.dart';

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/dashboard');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FA),
      body: Column(
        children: [
          _buildHeaderStack(context, ref),
          Expanded(
            child: eventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return _EmptyState(onRefresh: () => ref.invalidate(eventsProvider));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(eventsProvider);
                    await ref.read(eventsProvider.future);
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Text(
                            '${events.length} event${events.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _GalleryEventTile(
                                event: events[index],
                                onTap: () => _showEventDetail(context, events[index]),
                              ),
                            ),
                            childCount: events.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => Skeletonizer(
                enabled: true,
                child: CustomScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(height: 14, width: 80, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(4))),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(height: 200, color: Colors.grey),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(height: 16, width: 250, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(4))),
                                        const SizedBox(height: 8),
                                        Container(height: 16, width: 120, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(4))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          childCount: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              error: (error, _) => _ErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(eventsProvider),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildHeaderStack(BuildContext context, WidgetRef ref) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 240,
          width: double.infinity,
          color: const Color(0xFF3B82F6),
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () {
                        NavigationUtils.safePop(context);
                      },
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                      onPressed: () => ref.invalidate(eventsProvider),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Gallery',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'School Event Activities',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }



  void _showEventDetail(BuildContext context, EventModel event) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventDetailSheet(event: event),
    );
  }
}

class _GalleryEventTile extends StatelessWidget {
  const _GalleryEventTile({
    required this.event,
    required this.onTap,
  });

  final EventModel event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final allImages = <String>[];
    if (event.images != null && event.images!.isNotEmpty) {
      allImages.addAll(event.images!);
    } else if (event.imageUrl != null) {
      allImages.add(event.imageUrl!);
    }

    final String? coverImage = allImages.isNotEmpty ? allImages.first : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (coverImage != null)
              CourseCoverImage(
                imageUrl: coverImage,
                fit: BoxFit.cover,
                placeholderColor: const Color(0xFF3B82F6),
              )
            else
              Container(color: const Color(0xFF3B82F6)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (event.eventDate != null && event.eventDate!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      event.eventDate!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventDetailSheet extends StatelessWidget {
  const _EventDetailSheet({required this.event});

  final EventModel event;

  Widget _buildImagesCarousel(BuildContext context) {
    final allImages = <String>[];
    if (event.images != null && event.images!.isNotEmpty) {
      allImages.addAll(event.images!);
    } else if (event.imageUrl != null) {
      allImages.add(event.imageUrl!);
    }

    if (allImages.isEmpty) {
      return CourseCoverImage(
        imageUrl: null,
        height: 200,
        borderRadius: BorderRadius.circular(16),
        fit: BoxFit.cover,
        placeholderColor: const Color(0xFF3B82F6),
      );
    }

    if (allImages.length == 1) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => FullScreenImageViewer(
              images: allImages,
              initialIndex: 0,
            ),
          ));
        },
        child: CourseCoverImage(
          imageUrl: allImages.first,
          height: 200,
          borderRadius: BorderRadius.circular(16),
          fit: BoxFit.cover,
          placeholderColor: const Color(0xFF3B82F6),
        ),
      );
    }

    return Column(
      children: List.generate(allImages.length, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == allImages.length - 1 ? 0 : 12.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => FullScreenImageViewer(
                  images: allImages,
                  initialIndex: index,
                ),
              ));
            },
            child: CourseCoverImage(
              imageUrl: allImages[index],
              height: 240,
              width: double.infinity,
              borderRadius: BorderRadius.circular(16),
              fit: BoxFit.cover,
              placeholderColor: const Color(0xFF3B82F6),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return GestureDetector(
            onTap: () {}, // Prevent tap from bubbling to the outer detector
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFF475569), size: 20),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  children: [
                    _buildImagesCarousel(context),
              const SizedBox(height: 12),
              if (event.eventDate != null || event.eventTime != null || event.location != null)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (event.eventDate != null && event.eventDate!.isNotEmpty)
                      _DetailChip(icon: Icons.calendar_today_outlined, label: event.eventDate!),
                    if (event.eventTime != null && event.eventTime!.isNotEmpty)
                      _DetailChip(icon: Icons.access_time, label: event.eventTime!),
                    if (event.location != null && event.location!.isNotEmpty)
                      _DetailChip(icon: Icons.location_on_outlined, label: event.location!),
                  ],
                ),
              if (event.description.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  event.description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF475569),
                    height: 1.5,
                  ),
                ),
              ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),
);
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No events in gallery yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Event photos will appear here when events are published.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text(
              'Failed to load gallery',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

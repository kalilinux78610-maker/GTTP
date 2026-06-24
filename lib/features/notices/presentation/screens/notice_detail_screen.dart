import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/features/notices/data/models/notice_model.dart';
import 'package:gttp/features/notices/presentation/providers/notices_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NoticeDetailScreen extends ConsumerWidget {
  final String noticeId;

  const NoticeDetailScreen({super.key, required this.noticeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticeAsync = ref.watch(noticeDetailProvider(noticeId));

    return noticeAsync.when(
      loading: () => Skeletonizer(
        enabled: true,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 20,
                  right: 20,
                  bottom: 30,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey, Colors.black38],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 24,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(height: 28, width: 250, color: Colors.white),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(height: 16, width: 100, color: Colors.white),
                        const SizedBox(width: 16),
                        Container(height: 16, width: 100, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20, 20, 20,
                    MediaQuery.of(context).padding.bottom + 20,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: List.generate(10, (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(height: 16, width: double.infinity, color: Colors.grey),
                      )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (e, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load notice', style: TextStyle(color: Colors.red.shade400)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(noticeDetailProvider(noticeId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (notice) => _NoticeDetailBody(notice: notice),
    );
  }
}

class _NoticeDetailBody extends StatelessWidget {
  const _NoticeDetailBody({required this.notice});

  final NoticeModel notice;

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(notice.category);
    
    // Create a darker shade for the gradient
    final hsl = HSLColor.fromColor(catColor);
    final darkColor = hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0)).toColor();

    return Scaffold(
      backgroundColor: catColor, // Match top color for status bar
      body: Column(
        children: [
          // Colored Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 24,
              right: 24,
              bottom: 32, // Extra bottom padding for the curved overlap
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [catColor, darkColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    InkWell(
                      onTap: () => context.pop(),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        notice.category.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  notice.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    letterSpacing: -0.5,
                  ),
                ),
                if (notice.targetAudience != null && notice.targetAudience!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.people_alt_outlined, color: Colors.white.withValues(alpha: 0.8), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Target: ${notice.targetAudience}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                // Metadata Row (Date & Author)
                Row(
                  children: [
                    if (notice.createdAt.isNotEmpty) ...[
                      Icon(Icons.access_time, color: Colors.white.withValues(alpha: 0.7), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        notice.createdAt,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 12),
                      Text('•', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, color: Colors.white.withValues(alpha: 0.7), size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              notice.authorName,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // White Content Area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24, 32, 24,
                    MediaQuery.of(context).padding.bottom + 32,
                  ),
                  child: Text(
                    notice.content,
                    style: const TextStyle(
                      color: Color(0xFF374151), // Dark grey, softer than black
                      fontSize: 16,
                      height: 1.7, // Great line height for readability
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'event':
        return const Color(0xFF8B5CF6); // Purple
      case 'announcement':
        return const Color(0xFF3B82F6); // Blue
      case 'alert':
        return const Color(0xFFF97316); // Orange
      case 'update':
        return const Color(0xFF10B981); // Green
      default:
        return const Color(0xFFE5E7EB); // Grey
    }
  }
}

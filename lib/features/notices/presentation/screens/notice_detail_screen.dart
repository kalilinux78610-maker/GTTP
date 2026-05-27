import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/features/notices/data/models/notice_model.dart';
import 'package:gttp/features/notices/presentation/providers/notices_provider.dart';

class NoticeDetailScreen extends ConsumerWidget {
  final String noticeId;

  const NoticeDetailScreen({super.key, required this.noticeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticeAsync = ref.watch(noticeDetailProvider(noticeId));

    return noticeAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
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

    return Scaffold(
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
                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
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
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    notice.category,
                    style: TextStyle(
                      color: catColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  notice.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                if (notice.targetAudience != null && notice.targetAudience!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.group, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Target: ${notice.targetAudience}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (notice.createdAt.isNotEmpty) ...[
                      const Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        notice.createdAt,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      const Text('•', style: TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(width: 16),
                    ],
                    Text(
                      'By ${notice.authorName}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  notice.content,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 16,
                    height: 1.6,
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
      case 'announcement':
        return const Color(0xFF8B5CF6);
      case 'event':
        return const Color(0xFF3B82F6);
      case 'alert':
      case 'update':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFF59E0B);
    }
  }
}

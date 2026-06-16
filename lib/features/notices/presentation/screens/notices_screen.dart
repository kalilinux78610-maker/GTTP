import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/features/notices/data/models/notice_model.dart';
import 'package:gttp/features/notices/presentation/providers/notices_provider.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NoticesScreen extends ConsumerStatefulWidget {
  const NoticesScreen({super.key});

  @override
  ConsumerState<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends ConsumerState<NoticesScreen> {
  String? _selectedCategory;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadRole);
  }

  Future<void> _loadRole() async {
    final user = await ref.read(secureStorageProvider).getUserModel();
    if (mounted) {
      setState(() {
        _userRole = user?.role;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final noticesAsync = ref.watch(filteredNoticesProvider);
    final isAuthorized = _userRole?.toLowerCase() == 'national coordinator' || _userRole?.toLowerCase() == 'superadmin';

    int unreadCount = 0;
    if (noticesAsync.hasValue && noticesAsync.value != null) {
      unreadCount = noticesAsync.value!.where((n) => !n.isRead).length;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: Column(
        children: [
          // Custom Solid Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF336DF2),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    InkWell(
                      onTap: () => context.go('/dashboard'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    // Action Buttons
                    Row(
                      children: [
                        if (isAuthorized) ...[
                          InkWell(
                            onTap: () => context.push('/notices/create'),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF97316),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF97316).withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // Title
                const Text(
                  'Notices',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  unreadCount > 0 
                      ? '$unreadCount unread notification${unreadCount > 1 ? 's' : ''}'
                      : 'Stay updated with recent events',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          
          // White Area for Category Chips
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _CategoryChip(
                    label: 'All',
                    isSelected: _selectedCategory == null,
                    onTap: () {
                      setState(() => _selectedCategory = null);
                      ref.read(noticeCategoryProvider.notifier).setCategory(null);
                    },
                  ),
                  const SizedBox(width: 8),
                  _CategoryChip(
                    label: 'Announcements',
                    isSelected: _selectedCategory == 'Announcement',
                    onTap: () {
                      setState(() => _selectedCategory = 'Announcement');
                      ref.read(noticeCategoryProvider.notifier).setCategory('Announcement');
                    },
                  ),
                  const SizedBox(width: 8),
                  _CategoryChip(
                    label: 'Events',
                    isSelected: _selectedCategory == 'Event',
                    onTap: () {
                      setState(() => _selectedCategory = 'Event');
                      ref.read(noticeCategoryProvider.notifier).setCategory('Event');
                    },
                  ),
                  const SizedBox(width: 8),
                  _CategoryChip(
                    label: 'Updates',
                    isSelected: _selectedCategory == 'Update',
                    onTap: () {
                      setState(() => _selectedCategory = 'Update');
                      ref.read(noticeCategoryProvider.notifier).setCategory('Update');
                    },
                  ),
                  const SizedBox(width: 8),
                  _CategoryChip(
                    label: 'Alerts',
                    isSelected: _selectedCategory == 'Alert',
                    onTap: () {
                      setState(() => _selectedCategory = 'Alert');
                      ref.read(noticeCategoryProvider.notifier).setCategory('Alert');
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Notices List
          Expanded(
            child: noticesAsync.when(
              data: (notices) {
                if (notices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedCategory == null
                              ? 'No notices found'
                              : 'No notices match your filters',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(noticesNotifierProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      24, 16, 24,
                      MediaQuery.of(context).padding.bottom + 90,
                    ),
                    itemCount: notices.length,
                    itemBuilder: (context, index) {
                      return _NoticeCard(notice: notices[index]);
                    },
                  ),
                );
              },
              loading: () => Skeletonizer(
                enabled: true,
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    24, 16, 24,
                    MediaQuery.of(context).padding.bottom + 90,
                  ),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(height: 24, width: 80, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8))),
                                const SizedBox(width: 8),
                                Container(height: 24, width: 60, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text('Loading Notice Title Here...', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            const Text('Loading content of the notice goes here. This takes up some space.', style: TextStyle(fontSize: 14)),
                            const SizedBox(height: 12),
                            Divider(color: Colors.grey.shade200, thickness: 1.5),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(height: 16, width: 100, color: Colors.grey),
                                Container(height: 16, width: 80, color: Colors.grey),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load notices:\n$error',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.red.shade400),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.read(noticesNotifierProvider.notifier).refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF336DF2) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isSelected 
              ? null 
              : Border.all(color: Colors.grey.shade200, width: 1.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF336DF2).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

class _NoticeCard extends ConsumerWidget {
  final NoticeModel notice;

  const _NoticeCard({required this.notice});

  Color _getBorderColor() {
    switch (notice.category.toLowerCase()) {
      case 'event':
        return const Color(0xFF8B5CF6);
      case 'announcement':
        return const Color(0xFF3B82F6);
      case 'alert':
        return const Color(0xFFF97316);
      case 'update':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      // Handles both "2026-05-23T10:15:40.000000Z" and "2026-05-23 16:04"
      final dt = DateTime.parse(dateStr.replaceFirst(' ', 'T'));
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr.split(' ').first;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderColor = _getBorderColor();
    final bool isNew = !notice.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Optimistically mark as read instantly
            if (!notice.isRead) {
              ref.read(noticesNotifierProvider.notifier).markAsRead(notice.id);
            }
            context.push('/notices/${notice.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CategoryBadge(category: notice.category),
                    const SizedBox(width: 8),
                    if (notice.isHighPriority) ...[
                      _PriorityBadge(),
                      const SizedBox(width: 8),
                    ],
                    if (isNew) ...[
                      const Spacer(),
                      _NewBadge(),
                    ],
                    if (notice.isPinned && !isNew) ...[
                      const Spacer(),
                      const Icon(Icons.push_pin, size: 18, color: Color(0xFFF97316)),
                    ] else if (notice.isPinned && isNew) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.push_pin, size: 18, color: Color(0xFFF97316)),
                    ],
                  ],
                ),
                if (notice.targetAudience != null && notice.targetAudience!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.group, color: Color(0xFF6B7280), size: 12),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            notice.targetAudience!,
                            style: const TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  notice.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  notice.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade200, thickness: 1.5),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (notice.createdAt.isNotEmpty) ...[
                      Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(notice.createdAt),
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      'By ${notice.authorName}',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData? icon;
    
    switch (category.toLowerCase()) {
      case 'announcement':
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF3B82F6);
        icon = Icons.campaign_outlined;
        break;
      case 'event':
        bgColor = const Color(0xFFF5F3FF);
        textColor = const Color(0xFF8B5CF6);
        icon = Icons.event_outlined;
        break;
      case 'alert':
        bgColor = const Color(0xFFFFF7ED);
        textColor = const Color(0xFFF97316);
        icon = Icons.warning_amber_rounded;
        break;
      case 'update':
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF10B981);
        icon = Icons.system_update_alt;
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        icon = Icons.label_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'URGENT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEF4444),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF3B82F6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'NEW',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3B82F6),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

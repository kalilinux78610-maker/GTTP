import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/features/notices/data/models/notice_model.dart';
import 'package:gttp/features/notices/presentation/providers/notices_provider.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';

class NoticesScreen extends ConsumerStatefulWidget {
  const NoticesScreen({super.key});

  @override
  ConsumerState<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends ConsumerState<NoticesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noticesAsync = ref.watch(filteredNoticesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      floatingActionButton: (_userRole?.toLowerCase() == 'national coordinator' || _userRole?.toLowerCase() == 'principal')
          ? Padding(
              // Push FAB above the floating nav bar (70px height + 20px gap)
              padding: const EdgeInsets.only(bottom: 90),
              child: FloatingActionButton.extended(
                onPressed: () => context.push('/notices/create'),
                backgroundColor: const Color(0xFFE65C00),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Create Notice',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : null,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2A3A4A), size: 20),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text(
          'Notices',
          style: TextStyle(
            color: Color(0xFF2A3A4A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6B7280)),
            onPressed: () => ref.read(noticesNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
                ref.read(noticeSearchQueryProvider.notifier).updateQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'Search notices...',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF9CA3AF)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          ref.read(noticeSearchQueryProvider.notifier).updateQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // Category Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
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
                    label: 'Announcement',
                    isSelected: _selectedCategory == 'Announcement',
                    onTap: () {
                      setState(() => _selectedCategory = 'Announcement');
                      ref.read(noticeCategoryProvider.notifier).setCategory('Announcement');
                    },
                  ),
                  const SizedBox(width: 8),
                  _CategoryChip(
                    label: 'Event',
                    isSelected: _selectedCategory == 'Event',
                    onTap: () {
                      setState(() => _selectedCategory = 'Event');
                      ref.read(noticeCategoryProvider.notifier).setCategory('Event');
                    },
                  ),
                  const SizedBox(width: 8),
                  _CategoryChip(
                    label: 'Alert',
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
                          _searchQuery.isEmpty && _selectedCategory == null
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
                      16, 16, 16,
                      // Nav bar (70) + gap (20) + FAB height (56) + spacer (16)
                      MediaQuery.of(context).padding.bottom + 162,
                    ),
                    itemCount: notices.length,
                    itemBuilder: (context, index) {
                      return _NoticeCard(notice: notices[index]);
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE65C00) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final NoticeModel notice;

  const _NoticeCard({required this.notice});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        border: notice.isPinned
            ? Border.all(color: const Color(0xFFE65C00), width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/notices/${notice.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Priority indicator
                    Container(
                      width: 4,
                      height: 48,
                      decoration: BoxDecoration(
                        color: notice.isHighPriority
                            ? const Color(0xFFEF4444)
                            : notice.isPinned
                                ? const Color(0xFFE65C00)
                                : const Color(0xFF6B7280),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (notice.isPinned) ...[
                                const Icon(
                                  Icons.push_pin,
                                  size: 16,
                                  color: Color(0xFFE65C00),
                                ),
                                const SizedBox(width: 4),
                              ],
                              Expanded(
                                child: Text(
                                  notice.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2A3A4A),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _CategoryBadge(category: notice.category),
                              const SizedBox(width: 8),
                              if (notice.isHighPriority)
                                _PriorityBadge(),
                              if (notice.targetAudience != null && notice.targetAudience!.isNotEmpty) ...[
                                if (notice.isHighPriority) const SizedBox(width: 8),
                                _TargetBadge(target: notice.targetAudience!),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Unread indicator
                    if (!notice.isRead)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE65C00),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Content preview
                Text(
                  notice.content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Footer Row
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      notice.authorName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (notice.createdAt.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        notice.createdAt,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                    if (notice.attachmentUrl != null) ...[
                      const Spacer(),
                      Icon(
                        Icons.attach_file,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ],
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
    
    switch (category.toLowerCase()) {
      case 'announcement':
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF2563EB);
        break;
      case 'event':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        break;
      case 'alert':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.priority_high, size: 10, color: Color(0xFFDC2626)),
          SizedBox(width: 2),
          Text(
            'HIGH',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetBadge extends StatelessWidget {
  final String target;

  const _TargetBadge({required this.target});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.group, size: 10, color: Color(0xFF6B7280)),
          const SizedBox(width: 2),
          Text(
            target,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}

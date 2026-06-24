import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/utils/student_row_parser.dart';
import 'package:gttp/features/dashboard/presentation/providers/gttp_api_providers.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyStudentsScreen extends ConsumerStatefulWidget {
  const MyStudentsScreen({super.key});

  @override
  ConsumerState<MyStudentsScreen> createState() => _MyStudentsScreenState();
}

class _MyStudentsScreenState extends ConsumerState<MyStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(myStudentsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
                color: Color(0xFF0052CC), // Updated to match admin blue theme
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (context.canPop()) context.pop();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'My Students',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Performance overview',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        setState(() => _searchQuery = v.trim().toLowerCase());
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by name or admission no...',
                      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: studentsAsync.when(
                loading: () => Skeletonizer(
                  enabled: true,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      24, 24, 24,
                      MediaQuery.of(context).padding.bottom + 120, // To clear floating nav bar
                    ),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.grey,
                                child: Text('XX', style: TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(height: 16, width: double.infinity, color: Colors.grey),
                                    const SizedBox(height: 4),
                                    Container(height: 14, width: 150, color: Colors.grey),
                                    const SizedBox(height: 6),
                                    Container(height: 14, width: 100, color: Colors.grey),
                                    const SizedBox(height: 8),
                                    Container(height: 20, width: 60, color: Colors.grey),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              const SizedBox(
                                width: 48,
                                height: 48,
                                child: CircularProgressIndicator(
                                  value: 0.5,
                                  backgroundColor: Color(0xFFF3F4F6),
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load students',
                          style: TextStyle(color: Colors.red.shade400),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => ref.invalidate(myStudentsProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (rows) {
                  final filtered = rows.where((row) {
                    if (_searchQuery.isEmpty) return true;
                    final name = StudentRowParser.name(row).toLowerCase();
                    final code = StudentRowParser.id(row).toLowerCase();
                    return name.contains(_searchQuery) || code.contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        rows.isEmpty ? 'No students returned from API' : 'No students match your search',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(studentsApiProvider);
                      ref.invalidate(myStudentsProvider);
                      await ref.read(myStudentsProvider.future);
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        24, 24, 24,
                        MediaQuery.of(context).padding.bottom + 120, // To clear floating nav bar
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final student = filtered[index];
                        final name = StudentRowParser.name(student);
                        
                        final rawClass = student['class']?.toString() ?? StudentRowParser.classLabel(student);
                        final classDisplay = rawClass.toLowerCase().startsWith('class') || rawClass.toLowerCase().startsWith('grade') || rawClass == '—'
                            ? rawClass 
                            : 'Class $rawClass';
                            
                        final email = student['email']?.toString() ?? 'No Email';
                        final rollNo = student['roll_number']?.toString() ?? 'N/A';
                        final type = student['institute_type']?.toString() ?? 'School';
                        
                        int score = StudentRowParser.scorePercent(student);
                                                
                        final studentId = StudentRowParser.id(student);
                        final initials = name
                            .split(RegExp(r'\s+'))
                            .where((p) => p.isNotEmpty)
                            .map((e) => e[0])
                            .take(2)
                            .join();
                            
                        final avatarUrl = StudentRowParser.avatar(student);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: studentId.isEmpty
                                ? null
                                : () => context.push('/dashboard/my-students/$studentId'),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (avatarUrl != null)
                                    ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: avatarUrl,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) => CircleAvatar(
                                          radius: 28,
                                          backgroundColor: const Color(0xFF8B5CF6),
                                          child: Text(
                                            initials.isEmpty ? '?' : initials.toUpperCase(),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: const Color(0xFF8B5CF6),
                                      child: Text(
                                        initials.isEmpty ? '?' : initials.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F2937),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          email,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF6B7280),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Roll No: $rollNo',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF6B7280),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                                              child: Icon(Icons.circle, size: 4, color: Color(0xFF9CA3AF)),
                                            ),
                                            Flexible(
                                              child: Text(
                                                classDisplay,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF6B7280),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            type.isNotEmpty ? '${type[0].toUpperCase()}${type.substring(1)}' : 'School',
                                            style: const TextStyle(
                                              color: Color(0xFF3B82F6),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            CircularProgressIndicator(
                                              value: score / 100,
                                              backgroundColor: const Color(0xFFF3F4F6),
                                              color: const Color(0xFF10B981),
                                              strokeWidth: 4,
                                              strokeCap: StrokeCap.round,
                                            ),
                                            Center(
                                              child: Text(
                                                '$score%',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF10B981),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Color(0xFF9CA3AF),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}

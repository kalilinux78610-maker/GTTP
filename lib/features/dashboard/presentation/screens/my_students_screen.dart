import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/core/utils/student_row_parser.dart';
import 'package:gttp/features/dashboard/presentation/providers/gttp_api_providers.dart';

class MyStudentsScreen extends ConsumerStatefulWidget {
  const MyStudentsScreen({super.key});

  @override
  ConsumerState<MyStudentsScreen> createState() => _MyStudentsScreenState();
}

class _MyStudentsScreenState extends ConsumerState<MyStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _scoreColor(int score) {
    if (score >= 85) return const Color(0xFF10B981);
    if (score >= 70) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(myStudentsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 24),
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
                    onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
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
                loading: () => const Center(child: CircularProgressIndicator()),
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
                        final classLabel = StudentRowParser.classLabel(student);
                        final score = StudentRowParser.scorePercent(student);
                        final studentId = StudentRowParser.id(student);
                        final color = _scoreColor(score);
                        final initials = name
                            .split(RegExp(r'\s+'))
                            .where((p) => p.isNotEmpty)
                            .map((e) => e[0])
                            .take(2)
                            .join();

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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: const Color(0xFFF3F4F6),
                                    child: Text(
                                      initials.isEmpty ? '?' : initials.toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF0052CC), // Match blue theme
                                        fontWeight: FontWeight.bold,
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
                                            color: Color(0xFF2A3A4A),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          classLabel,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (score > 0)
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: color, width: 2),
                                      ),
                                      child: Text(
                                        '$score%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                          fontSize: 12,
                                        ),
                                      ),
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
      ),
    );
  }
}

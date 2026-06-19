import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/features/dashboard/presentation/providers/gttp_api_providers.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gttp/core/utils/student_row_parser.dart';

class FacultyMembersScreen extends ConsumerStatefulWidget {
  const FacultyMembersScreen({super.key});

  @override
  ConsumerState<FacultyMembersScreen> createState() => _FacultyMembersScreenState();
}

class _FacultyMembersScreenState extends ConsumerState<FacultyMembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final facultyAsync = ref.watch(facultyApiProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 24),
              decoration: const BoxDecoration(
                color: Color(0xFFE65C00), // Orange color to match design
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
                    'Faculty Members',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Teaching staff directory',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search faculty by name...',
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
              child: facultyAsync.when(
                data: (facultyList) {
                  final filteredList = facultyList.where((f) {
                    final userObj = f['user'] is Map ? f['user'] as Map : f;
                    final name = (userObj['name'] ?? userObj['faculty_name'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery);
                  }).toList();

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text(
                            'No faculty found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2A3A4A),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: filteredList.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final faculty = filteredList[index];
                      final userObj = faculty['user'] is Map ? faculty['user'] as Map : faculty;
                      
                      final name = (userObj['name'] ?? userObj['faculty_name'] ?? 'Unknown').toString();
                      final email = (userObj['email'] ?? 'No email').toString();
                      final phone = (userObj['phone'] ?? userObj['mobile'] ?? 'No phone').toString();
                      final role = (userObj['role'] ?? userObj['designation'] ?? 'Faculty').toString();
                      final avatarUrl = StudentRowParser.avatar(Map<String, dynamic>.from(userObj));

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            // Navigate to details screen, pass faculty map as extra
                            context.push('/dashboard/faculty-members/details', extra: faculty);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Row(
                          children: [
                            if (avatarUrl != null)
                              ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: avatarUrl,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => CircleAvatar(
                                    backgroundColor: const Color(0xFFE65C00).withValues(alpha: 0.1),
                                    radius: 24,
                                    child: Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : 'F',
                                      style: const TextStyle(color: Color(0xFFE65C00), fontWeight: FontWeight.bold, fontSize: 20),
                                    ),
                                  ),
                                ),
                              )
                            else
                              CircleAvatar(
                                backgroundColor: const Color(0xFFE65C00).withValues(alpha: 0.1),
                                radius: 24,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'F',
                                  style: const TextStyle(
                                    color: Color(0xFFE65C00),
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
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    role,
                                    style: const TextStyle(
                                      color: Color(0xFF3B82F6),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.email_outlined, size: 14, color: Color(0xFF64748B)),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          email,
                                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF64748B)),
                                      const SizedBox(width: 4),
                                      Text(
                                        phone,
                                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                    },
                  );
                },
                loading: () => Skeletonizer(
                  enabled: true,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: 6,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 24,
                              child: Text('XX', style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(height: 16, width: 120, color: Colors.grey),
                                  const SizedBox(height: 4),
                                  Container(height: 14, width: 100, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Container(height: 12, width: 150, color: Colors.grey),
                                  const SizedBox(height: 4),
                                  Container(height: 12, width: 90, color: Colors.grey),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load faculty',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          err.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.refresh(facultyApiProvider),
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
      ),
    );
  }
}

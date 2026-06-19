import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/features/certificates/presentation/providers/certificates_provider.dart';

class CertificateBuilderScreen extends ConsumerStatefulWidget {
  const CertificateBuilderScreen({super.key});

  @override
  ConsumerState<CertificateBuilderScreen> createState() => _CertificateBuilderScreenState();
}

class _CertificateBuilderScreenState extends ConsumerState<CertificateBuilderScreen> {
  String? _selectedCourse;
  String? _selectedStudent;

  @override
  Widget build(BuildContext context) {
    final builderState = ref.watch(certificateBuilderProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text(
          'Certificate Builder',
          style: TextStyle(
            color: Color(0xFF181C1F),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF181C1F)),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: builderState.when(
        data: (data) {
          final courses = data['courses'] as List? ?? [];
          final students = data['students'] as List? ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Select Course'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: _selectedCourse,
                  hint: 'Choose a Course',
                  items: courses.map((e) {
                    return DropdownMenuItem<String>(
                      value: e['id']?.toString() ?? '',
                      child: Text(e['title']?.toString() ?? 'Unnamed Course'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedCourse = val);
                  },
                ),
                const SizedBox(height: 24),
                
                _buildSectionHeader('Select Student'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: _selectedStudent,
                  hint: 'Choose a Student',
                  items: students.map((e) {
                    final studentId = e['id']?.toString() ?? '';
                    final name = e['name']?.toString() ?? 'Unnamed';
                    return DropdownMenuItem<String>(
                      value: studentId,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedStudent = val);
                  },
                ),
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_selectedCourse != null && _selectedStudent != null)
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Certificate Generated Successfully!')),
                            );
                            if (context.canPop()) context.pop();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFFE65C00),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Generate Certificate',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFE65C00)),
        ),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Error loading builder details:\n$e',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Color(0xFF94A3B8))),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

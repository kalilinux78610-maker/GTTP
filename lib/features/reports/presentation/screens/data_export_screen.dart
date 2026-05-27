import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:gttp/features/reports/data/models/student_model.dart';
import 'package:gttp/features/dashboard/presentation/providers/gttp_api_providers.dart';
import 'package:gttp/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:gttp/features/reports/presentation/providers/export_provider.dart';
import 'package:gttp/features/school_network/presentation/providers/school_network_provider.dart';

/// Resolves a display title from `/courses` (or similar) API maps.
String _titleFromCourseApiMap(Map<String, dynamic> c) {
  for (final key in [
    'title',
    'name',
    'course_name',
    'course_title',
    'class_name',
    'school_class',
    'course',
    'class',
    'program',
    'program_name',
    'batch',
    'batch_name',
    'department',
    'discipline',
  ]) {
    final val = c[key];
    if (val == null) continue;
    if (val is Map) {
      final nested =
          val['title'] ??
          val['name'] ??
          val['class_name'] ??
          val['course_name'] ??
          val['course_title'];
      if (nested != null && nested.toString().trim().isNotEmpty) {
        return nested.toString().trim();
      }
      if (val.isNotEmpty) {
        final firstVal = val.values.first;
        if (firstVal != null && firstVal.toString().trim().isNotEmpty) {
          return firstVal.toString().trim();
        }
      }
      continue;
    }
    final text = val.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

class DataExportCenterScreen extends ConsumerStatefulWidget {
  const DataExportCenterScreen({super.key});

  @override
  ConsumerState<DataExportCenterScreen> createState() =>
      _DataExportCenterScreenState();
}

class _DataExportCenterScreenState extends ConsumerState<DataExportCenterScreen>
    with WidgetsBindingObserver {
  static const _allSchools = 'All Schools';
  static const _allCourses = 'All Courses';

  String _selectedYear = '2026';
  String _selectedFormat = 'EXCEL';
  String _selectedSchool = _allSchools;
  String _selectedCourse = _allCourses;

  bool _includePassport = true;
  bool _includePillars = true;

  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(_refreshExportData);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshExportData();
    }
  }

  Future<void> _refreshExportData() async {
    ref.invalidate(studentsApiProvider);
    ref.invalidate(coursesApiProvider);
    ref.invalidate(exportStudentsProvider);
    ref.invalidate(
      filteredExportStudentsProvider(
        StudentFilterParams(
          year: _selectedYear,
          school: _selectedSchool,
          course: _selectedCourse,
        ),
      ),
    );
    ref.invalidate(dashboardDataProvider);
    await Future.wait([
      ref.read(exportStudentsProvider.future),
      ref.read(coursesApiProvider.future),
      ref.read(
        filteredExportStudentsProvider(
          StudentFilterParams(
            year: _selectedYear,
            school: _selectedSchool,
            course: _selectedCourse,
          ),
        ).future,
      ),
      ref.read(dashboardDataProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudentsAsync = ref.watch(
      filteredExportStudentsProvider(
        StudentFilterParams(
          year: _selectedYear,
          school: _selectedSchool,
          course: _selectedCourse,
        ),
      ),
    );
    final filteredStudents = filteredStudentsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const <StudentModel>[],
    );

    // We still need the unfiltered students just for populating the dropdown choices if they are not available from the schools endpoint
    final studentsAsync = ref.watch(exportStudentsProvider);
    final allStudents = studentsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const <StudentModel>[],
    );

    final schoolsAsync = ref.watch(schoolsProvider);
    final allSchoolsFromApi = schoolsAsync.maybeWhen(
      data: (d) => d,
      orElse: () => null,
    );
    final coursesAsync = ref.watch(coursesApiProvider);
    final allCoursesFromApi = coursesAsync.maybeWhen(
      data: (d) => d,
      orElse: () => null,
    );

    List<String> schoolChoices;
    if (allSchoolsFromApi != null && allSchoolsFromApi.isNotEmpty) {
      final unique =
          allSchoolsFromApi
              .map((s) => s.title)
              .where((s) => s.trim().isNotEmpty)
              .toSet()
              .toList()
            ..sort();
      schoolChoices = [_allSchools, ...unique];
    } else {
      schoolChoices = _schoolChoices(allStudents);
    }

    final fromApi = <String>{};
    if (allCoursesFromApi != null) {
      for (final c in allCoursesFromApi) {
        final t = _titleFromCourseApiMap(c);
        if (t.isNotEmpty) fromApi.add(t);
      }
    }
    final fromStudents = allStudents
        .map((s) => s.courseName.trim())
        .where((s) => s.isNotEmpty)
        .toSet();
    final merged = {...fromApi, ...fromStudents}.toList()..sort();
    final courseChoices = merged.isEmpty
        ? <String>[_allCourses]
        : [_allCourses, ...merged];
    if (!schoolChoices.contains(_selectedSchool)) _selectedSchool = _allSchools;
    if (!courseChoices.contains(_selectedCourse)) _selectedCourse = _allCourses;

    final dashboardState = ref.watch(dashboardDataProvider);
    final apiTotal = dashboardState.maybeWhen(
      data: (d) => d.totalStudents,
      orElse: () => allStudents.isNotEmpty ? allStudents.length : null,
    );
    final totalStudents = dashboardState.maybeWhen(
      data: (data) => data.totalStudents.toString(),
      orElse: () => studentsAsync.maybeWhen(
        data: (s) => s.length.toString(),
        orElse: () => '...',
      ),
    );

    final displayedTotalStudents = totalStudents;

    final previewRows = filteredStudents;

    final expiring = previewRows.where((s) => s.isPassportExpiring).length;
    final rowEst = filteredStudents.isEmpty ? 0 : filteredStudents.length;
    final previewCount = filteredStudents.length;
    final estimatedSize = _estimatedSize(
      filteredStudents.isEmpty ? previewRows.length : rowEst,
      _columnCount(),
    );

    // Listen for export status
    ref.listen(exportProvider, (previous, next) {
      final savedPath = next.savedPath;
      final error = next.error;

      if (savedPath != null) {
        _showSuccessDialog(savedPath);
        ref.read(exportProvider.notifier).clearStatus();
      } else if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $error'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(exportProvider.notifier).clearStatus();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Export Center',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Download master student data with filters',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Export now',
            icon: const Icon(Icons.file_download_outlined, color: Colors.blue),
            onPressed: ref.watch(exportProvider).isLoading
                ? null
                : () => _runExport(totalStudents, apiTotal, filteredStudents),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await _refreshExportData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatTile(
                          'Total Students',
                          displayedTotalStudents,
                          const Color(0xFF3B82F6),
                          Icons.people_outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatTile(
                          'Expiring Soon',
                          '$expiring',
                          const Color(0xFFF59E0B),
                          Icons.warning_amber_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: 'Academic Year',
                    icon: Icons.calendar_today_outlined,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['2026', '2025', '2024', '2023'].map((year) {
                        final isSelected = _selectedYear == year;
                        return InkWell(
                          onTap: () => setState(() => _selectedYear = year),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              year,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Filter by School',
                    icon: Icons.filter_alt_outlined,
                    iconColor: const Color(0xFF3B82F6),
                    child: _buildFilterTile(
                      value: _selectedSchool,
                      choices: schoolChoices,
                      hint: 'Select School',
                      onSelected: (v) => setState(() => _selectedSchool = v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Filter by Course',
                    icon: Icons.filter_alt_outlined,
                    iconColor: const Color(0xFF3B82F6),
                    child: _buildFilterTile(
                      value: _selectedCourse,
                      choices: courseChoices,
                      hint: 'Select Course',
                      onSelected: (v) => setState(() => _selectedCourse = v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDataFieldsSection(),
                  const SizedBox(height: 16),
                  _buildFormatSection(),
                  const SizedBox(height: 20),
                  _buildPreviewButton(previewCount),
                  const SizedBox(height: 20),
                  if (_showPreview)
                    ..._buildDataPreviewSection(
                      previewRows,
                    ),
                  if (_showPreview) const SizedBox(height: 20),
                  _buildSummarySection(totalStudents, rowEst, estimatedSize),
                  const SizedBox(height: 24),
                  _buildExportButton(
                    totalStudents,
                    apiTotal,
                    rowEst,
                    filteredStudents,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          if (ref.watch(exportProvider).isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Generating CSV & Saving…'),
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

  // Tappable filter tile that opens a bottom sheet picker
  Widget _buildFilterTile({
    required String value,
    required List<String> choices,
    required String hint,
    required ValueChanged<String> onSelected,
  }) {
    return InkWell(
      onTap: () => _showPickerBottomSheet(
        choices: choices,
        selected: value,
        onSelected: onSelected,
      ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }

  void _showPickerBottomSheet({
    required List<String> choices,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: choices.length,
                    itemBuilder: (context, index) {
                      final choice = choices[index];
                      final isSelected = choice == selected;
                      return ListTile(
                        title: Text(
                          choice,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF1E293B),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check,
                                color: Color(0xFF3B82F6))
                            : null,
                        onTap: () {
                          onSelected(choice);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatTile(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataFieldsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Include Data Fields',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose columns included in CSV / Excel export and preview.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Passport Information',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            subtitle: const Text(
              'Number, expiry date, validity status',
              style: TextStyle(fontSize: 11),
            ),
            value: _includePassport,
            activeThumbColor: const Color(0xFF3B82F6),
            onChanged: (v) => setState(() => _includePassport = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              '4 Pillars Reports',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            subtitle: const Text(
              'Theory, Practical, Internship, Visits completion',
              style: TextStyle(fontSize: 11),
            ),
            value: _includePillars,
            activeThumbColor: const Color(0xFF3B82F6),
            onChanged: (v) => setState(() => _includePillars = v),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Format',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFormatOption('EXCEL', Icons.insert_drive_file_outlined),
              const SizedBox(width: 12),
              _buildFormatOption('CSV', Icons.list_alt_outlined),
              const SizedBox(width: 12),
              _buildFormatOption('PDF', Icons.picture_as_pdf_outlined),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFormat == 'PDF'
                ? 'PDF generates a formatted document (.pdf) you can share or print.'
                : 'Excel uses CSV format (.csv), opens directly in Microsoft Excel.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewButton(int count) {
    return OutlinedButton(
      onPressed: count == 0 ? null : () => setState(() => _showPreview = !_showPreview),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: count == 0 ? Colors.grey.shade400 : const Color(0xFF3B82F6)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        _showPreview
            ? 'Hide Preview'
            : count == 0
                ? 'No Preview Available'
                : 'Show Data Preview ($count row${count == 1 ? '' : 's'})',
        style: TextStyle(
          color: count == 0 ? Colors.grey.shade400 : const Color(0xFF3B82F6),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSummarySection(
    String totalStudents,
    int rowEst,
    String estimatedSize,
  ) {
    final fmtLabel = _selectedFormat == 'PDF'
        ? 'PDF (text report)'
        : _selectedFormat;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Summary',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Students (approx.):', '$rowEst'),
          const SizedBox(height: 8),
          _buildSummaryRow('Estimated file size:', '~$estimatedSize'),
          const SizedBox(height: 8),
          _buildSummaryRow('Format:', fmtLabel),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Filters:',
            '$_selectedYear · ${_abbrev(_selectedSchool)} · ${_abbrev(_selectedCourse)}',
          ),
        ],
      ),
    );
  }

  String _abbrev(String s) {
    if (s.length <= 24) return s;
    return '${s.substring(0, 21)}…';
  }

  List<String> _schoolChoices(List<StudentModel> students) {
    final unique =
        students
            .map((s) => s.schoolName)
            .where((s) => s.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return [_allSchools, ...unique];
  }

  String _estimatedSize(int rows, int columnCount) {
    final bytesPerRow = 120 + columnCount * 35;
    final totalBytes = rows * bytesPerRow;
    if (totalBytes < 1024) {
      return '$totalBytes B';
    } else if (totalBytes < 1024 * 1024) {
      final kb = totalBytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    } else {
      final mb = totalBytes / (1024 * 1024);
      return '${mb.toStringAsFixed(2)} MB';
    }
  }

  int _columnCount() {
    var n = 6;
    if (_includePassport) n += 2;
    if (_includePillars) n += 4;
    return n;
  }

  Future<void> _runExport(
    String totalStudentsLabel,
    int? apiTotal,
    List<StudentModel> students,
  ) async {
    if (totalStudentsLabel == '...') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for dashboard data to load.'),
        ),
      );
      return;
    }

    ref
        .read(exportProvider.notifier)
        .exportData(
          students: students,
          format: _selectedFormat,
          includePassport: _includePassport,
          includePillars: _includePillars,
        );
  }

  void _showSuccessDialog(String path) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Export Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The data has been exported and saved successfully to your device.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                path,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              SharePlus.instance.share(
                ShareParams(
                  files: [XFile(path)],
                  text: 'GTTP India Student Export',
                ),
              );
            },
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Share / Save As'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(
    String totalStudents,
    int? apiTotal,
    int rowEst,
    List<StudentModel> students,
  ) {
    final exportState = ref.watch(exportProvider);
    final disabled = totalStudents == '...' || exportState.isLoading;

    return ElevatedButton(
      onPressed: disabled
          ? null
          : () => _runExport(totalStudents, apiTotal, students),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEA580C),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          exportState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.download_outlined,
                  color: Colors.white,
                  size: 20,
                ),
          const SizedBox(width: 8),
          Text(
            exportState.isLoading
                ? 'Saving File…'
                : 'Export ~$rowEst students ($_selectedFormat)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDataPreviewSection(List<StudentModel> list) {
    return [

      Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              list.isEmpty
                  ? 'No API rows match selected filters.'
                  : 'Data Preview (${list.length} record${list.length == 1 ? '' : 's'})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Try "$_allSchools" and "$_allCourses" to see results.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              ...list.asMap().entries.expand((e) {
                final i = e.key;
                final s = e.value;
                final widgets = <Widget>[
                  if (i > 0)
                    const Divider(height: 24, color: Color(0xFFE2E8F0)),
                  _buildPreviewStudentCard(s),
                ];
                return widgets;
              }),
          ],
        ),
      ),
    ];
  }

  Widget _buildPreviewStudentCard(StudentModel s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                s.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            if (s.isPassportExpiring)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '⚠ Expiring',
                  style: TextStyle(
                    color: Color(0xFFD97706),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${s.studentCode} · ${s.city}',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        Text(
          '${s.schoolName} · ${s.courseName}',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
        ),
        if (_includePassport) ...[
          const SizedBox(height: 6),
          Text(
            'Passport: ${s.passportNumber}  ·  Expiry: ${s.passportExpiry}',
            style: const TextStyle(color: Color(0xFF475569), fontSize: 12),
          ),
        ],
        if (_includePillars) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF22C55E),
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Reports: T ${s.theoryCompletion}% · P ${s.practicalCompletion}% · I ${s.internshipCompletion}% · V ${s.visitsCompletion}%',
                  style: const TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    Color iconColor = const Color(0xFF64748B),
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildFormatOption(String format, IconData icon) {
    final isSelected = _selectedFormat == format;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFormat = format),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                format,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

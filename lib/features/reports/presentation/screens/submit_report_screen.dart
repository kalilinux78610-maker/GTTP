import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gttp/features/reports/data/models/report_model.dart';
import 'package:gttp/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:gttp/core/network/api_exception.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';

class SubmitReportScreen extends ConsumerStatefulWidget {
  final String? courseId;
  final String? moduleId;
  final String? submoduleId;

  const SubmitReportScreen({
    super.key,
    this.courseId,
    this.moduleId,
    this.submoduleId,
  });

  @override
  ConsumerState<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends ConsumerState<SubmitReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  ReportCategory _selectedCategory = ReportCategory.theory;
  bool _isSubmitting = false;
  PlatformFile? _selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.single;
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    try {
      final bytes = _selectedFile != null ? await _selectedFile!.readAsBytes() : null;

      await ref.read(reportsRepositoryProvider).submitReport(
        courseId: widget.courseId,
        moduleId: widget.moduleId,
        submoduleId: widget.submoduleId,
        activityTitle: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        fileName: _selectedFile?.name,
        fileBytes: bytes,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } on OfflineSavedException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved offline! Will automatically sync when internet is restored.'),
            backgroundColor: Colors.blueGrey,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Submit Task Report'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1A1C1E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Task Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1C1E),
                ),
              ),
              const SizedBox(height: 16),
              
              // Activity Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Activity Title / Subject',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Category Selection
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF9FAFB),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ReportCategory>(
                    value: _selectedCategory,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    items: const [
                      DropdownMenuItem(
                        value: ReportCategory.theory,
                        child: Text('Tourism Management (Theory)'),
                      ),
                      DropdownMenuItem(
                        value: ReportCategory.practical,
                        child: Text('Heritage Studies (Practical)'),
                      ),
                      DropdownMenuItem(
                        value: ReportCategory.internship,
                        child: Text('Sustainable Tourism (Internship)'),
                      ),
                      DropdownMenuItem(
                        value: ReportCategory.visits,
                        child: Text('Event Management (Visits)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCategory = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Report Details / Description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your report details';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // File Upload
              const Text(
                'Attachment',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickFile,
                borderRadius: BorderRadius.circular(12),
                child: DottedBorder(
                  options: const RoundedRectDottedBorderOptions(
                    color: Color(0xFFD1D5DB),
                    strokeWidth: 2,
                    dashPattern: [6, 4],
                    radius: Radius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _selectedFile != null
                              ? Icons.file_present_rounded
                              : Icons.cloud_upload_outlined,
                          size: 32,
                          color: _selectedFile != null
                              ? const Color(0xFF3286C9)
                              : const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _selectedFile != null
                              ? _selectedFile!.name
                              : 'Tap to browse and upload a file',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: _selectedFile != null
                                ? const Color(0xFF1F2937)
                                : const Color(0xFF6B7280),
                            fontWeight: _selectedFile != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (_selectedFile == null) ...[
                          const SizedBox(height: 4),
                          const Text(
                            'PDF, DOCX, PNG, JPG (Max 10MB)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedFile = null;
                              });
                            },
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Remove File'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              if (_selectedFile != null)
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3286C9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Submit Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

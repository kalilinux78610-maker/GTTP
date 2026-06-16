import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gttp/features/courses/presentation/widgets/file_upload_dropzone.dart';
import 'package:gttp/features/courses/data/datasources/courses_remote_datasource.dart';

class CreateCourseModuleScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CreateCourseModuleScreen({
    super.key,
    required this.courseId,
  });

  @override
  ConsumerState<CreateCourseModuleScreen> createState() => _CreateCourseModuleScreenState();
}

class _CreateCourseModuleScreenState extends ConsumerState<CreateCourseModuleScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _titleController = TextEditingController();
  final _orderController = TextEditingController();
  final _durationController = TextEditingController();
  final _reminderController = TextEditingController();

  // State
  String? _selectedType;
  String? _selectedFileName;
  bool _isLoading = false;

  final List<String> _moduleTypes = [
    'External Course',
    'Report Upload',
    'Industry Visit',
    'Case Study',
    'Video',
    'Assignment',
    'Live Session',
    'MCQ Test',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _orderController.dispose();
    _durationController.dispose();
    _reminderController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _saveModule() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a module type')),
      );
      return;
    }

    if (_selectedType == 'Report Upload' && _selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a report file')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(coursesRemoteDataSourceProvider).createModule(
        courseId: widget.courseId,
        title: _titleController.text.trim(),
        type: _selectedType!,
        order: int.tryParse(_orderController.text.trim()),
        durationHours: int.tryParse(_durationController.text.trim()),
        reminderDays: int.tryParse(_reminderController.text.trim()),
      );

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Module created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // pass true to trigger refresh
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create module: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Unit (Modules)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modules',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Title & Type Row
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildTitleField(theme)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildTypeDropdown(theme, isDark)),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildTitleField(theme),
                      const SizedBox(height: 24),
                      _buildTypeDropdown(theme, isDark),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Order & Duration Row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Order',
                      controller: _orderController,
                      theme: theme,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildTextField(
                      label: 'Duration (Hours)',
                      controller: _durationController,
                      theme: theme,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Reminder
              SizedBox(
                width: MediaQuery.of(context).size.width > 600
                    ? (MediaQuery.of(context).size.width - 72) / 2
                    : double.infinity,
                child: _buildTextField(
                  label: 'Reminder (Days Before)',
                  controller: _reminderController,
                  theme: theme,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 24),

              // Dynamic Areas based on Type
              if (_selectedType == 'Report Upload') ...[
                Text(
                  'Upload Report (PDF) *',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                FileUploadDropzone(
                  onBrowse: _pickFile,
                  selectedFileName: _selectedFileName,
                  onClear: () => setState(() => _selectedFileName = null),
                ),
                const SizedBox(height: 32),
              ],

              // MCQ Settings Accordion
              _buildAccordion(
                title: 'MCQ Settings',
                theme: theme,
                isDark: isDark,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('MCQ Settings options will appear here...'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Certificates Accordion
              _buildAccordion(
                title: 'Certificates',
                theme: theme,
                isDark: isDark,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Certificate options will appear here...'),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveModule,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save Module'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Title ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(
                text: '*',
                style: TextStyle(color: Colors.redAccent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'click some pictures',
          ),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildTypeDropdown(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Type ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(
                text: '*',
                style: TextStyle(color: Colors.redAccent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedType,
          hint: const Text('Select an option'),
          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
            ),
          ),
          items: _moduleTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedType = value;
            });
          },
          validator: (value) => value == null ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required ThemeData theme,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: const InputDecoration(),
        ),
      ],
    );
  }

  Widget _buildAccordion({
    required String title,
    required ThemeData theme,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        children: children,
      ),
    );
  }
}

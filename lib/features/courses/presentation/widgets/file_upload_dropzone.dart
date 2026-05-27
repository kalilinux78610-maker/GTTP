import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class FileUploadDropzone extends StatelessWidget {
  final VoidCallback onBrowse;
  final String? selectedFileName;
  final VoidCallback? onClear;

  const FileUploadDropzone({
    super.key,
    required this.onBrowse,
    this.selectedFileName,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onBrowse,
      borderRadius: BorderRadius.circular(8),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: isDark ? Colors.white24 : Colors.black26,
          strokeWidth: 1.5,
          dashPattern: const [6, 4],
          radius: const Radius.circular(8),
          padding: const EdgeInsets.all(24),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedFileName == null) ...[
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 40,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    children: [
                      const TextSpan(text: 'Drag & Drop your files or '),
                      TextSpan(
                        text: 'Browse',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        selectedFileName!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onClear != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: onClear,
                        tooltip: 'Remove file',
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

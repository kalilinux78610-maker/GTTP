import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models/student_model.dart';

class ExportService {
  Future<String> exportData(
    List<StudentModel> students, 
    String format, {
    bool includePassport = true,
    bool includePillars = true,
    bool includeAcademic = true,
  }) async {
    try {
      List<int> bytes;
      String fileExt = '';

      if (format == 'CSV' || format == 'EXCEL') {
        final List<String> headers = [
          'Student ID', 'Name', 'Student Code', 'School', 'Course', 'City'
        ];
        if (includePassport) {
          headers.addAll(['Passport Number', 'Passport Expiry']);
        }
        if (includePillars) {
          headers.addAll(['Theory Completion (%)', 'Practical Completion (%)', 'Internship Completion (%)', 'Visits Completion (%)']);
        }
        // Note: Currently StudentModel doesn't have explicit GPA/Attendance, using the existing data structure if academic is checked.
        
        final List<List<dynamic>> rows = [
          headers,
          ...students.map((s) {
            final List<dynamic> row = [s.id, s.name, s.studentCode, s.schoolName, s.courseName, s.city];
            if (includePassport) {
              row.addAll([s.passportNumber, s.passportExpiry]);
            }
            if (includePillars) {
              row.addAll([s.theoryCompletion, s.practicalCompletion, s.internshipCompletion, s.visitsCompletion]);
            }
            return row;
          }),
        ];
        final content = csv.encode(rows);
        bytes = utf8.encode(content);
        fileExt = '.csv';
      } else if (format == 'JSON') {
        final content = jsonEncode(students.map((e) => e.toJson()).toList());
        bytes = utf8.encode(content);
        fileExt = '.json';
      } else if (format == 'PDF') {
        final pdf = pw.Document();

        final generatedAt = DateTime.now();
        final formattedGeneratedAt = "${generatedAt.year}-${generatedAt.month.toString().padLeft(2, '0')}-${generatedAt.day.toString().padLeft(2, '0')} ${generatedAt.hour.toString().padLeft(2, '0')}:${generatedAt.minute.toString().padLeft(2, '0')}";

        String formatDate(String isoString) {
          if (isoString.isEmpty) return 'N/A';
          final date = DateTime.tryParse(isoString);
          if (date == null) return isoString;
          return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        }

        final List<String> headers = [
          'No', 'Name', 'School Name', 'Course', 'City'
        ];
        if (includePassport) {
          headers.addAll(['Passport', 'Expiry']);
        }
        if (includePillars) {
          headers.addAll(['Thry%', 'Prac%', 'Intrn%', 'Visit%']);
        }

        final tableData = <List<String>>[
          headers,
          ...students.asMap().entries.map((entry) {
            final s = entry.value;
            final row = [
              '${entry.key + 1}',
              s.name,
              s.schoolName,
              s.courseName,
              s.city,
            ];
            if (includePassport) {
              row.addAll([s.passportNumber, formatDate(s.passportExpiry)]);
            }
            if (includePillars) {
              row.addAll([
                '${s.theoryCompletion}%',
                '${s.practicalCompletion}%',
                '${s.internshipCompletion}%',
                '${s.visitsCompletion}%',
              ]);
            }
            return row;
          }),
        ];

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4.landscape,
            build: (context) => [
              pw.Header(level: 0, child: pw.Text('GTTP STUDENT REPORT')),
              pw.Paragraph(text: 'Generated: $formattedGeneratedAt'),
              pw.Paragraph(text: 'Total Students: ${students.length}'),
              if (students.isEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 8),
                  child: pw.Text(
                    'No students found for selected filters.',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                )
              else
                pw.TableHelper.fromTextArray(
                  context: context,
                  headerStyle: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 7.5),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellPadding: const pw.EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 2,
                  ),
                  data: tableData,
                ),
            ],
          ),
        );

        bytes = await pdf.save();
        fileExt = '.pdf';
      } else {
        throw Exception('Unsupported format: $format');
      }

      // Get appropriate directory
      Directory directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'GTTP_Student_Export_$timestamp$fileExt';
      final path = '${directory.path}/$fileName';
      final file = File(path);

      await file.writeAsBytes(bytes);
      
      if (kDebugMode) {
        print('File saved to: $path');
      }
      
      return path;
    } catch (e) {
      if (kDebugMode) {
        print('Error in ExportService: $e');
      }
      rethrow;
    }
  }
}

import 'package:gttp/features/reports/domain/services/export_service.dart';
import 'package:gttp/features/reports/data/models/student_model.dart';
void main() async {
  final service = ExportService();
  final student = StudentModel(
    id: '1',
    name: 'Test',
    studentCode: '123',
    schoolName: 'School',
    courseName: 'Course',
    city: 'City',
    passportNumber: 'PASS',
    passportExpiry: '2025-01-01',
    theoryCompletion: 0,
    practicalCompletion: 0,
    internshipCompletion: 0,
    visitsCompletion: 0,
    isPassportExpiring: false,
  );
  try {
    print('Testing CSV');
    await service.exportData([student], 'CSV');
    print('CSV OK');
  } catch(e, st) {
    print('CSV Error: $e');
    print(st);
  }
}

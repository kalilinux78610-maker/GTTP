import 'package:flutter_test/flutter_test.dart';
import 'package:gttp/features/dashboard/data/models/dashboard_model.dart';

void main() {
  group('DashboardModel', () {
    test('fromJson should parse snake_case correctly', () {
      final json = {
        'total_students': 10,
        'total_classes': 5,
        'total_notices': 2,
        'total_schedules': 3,
        'total_syllabi': 4,
        'total_certificates': 6,
        'total_users': 15,
        'total_schools': 20,
        'total_courses': 7,
        'total_gallery': 8,
        'total_faculties': 9,
      };

      final model = DashboardModel.fromJson(json);

      expect(model.totalStudents, 10);
      expect(model.totalClasses, 5);
      expect(model.totalNotices, 2);
      expect(model.totalSchedules, 3);
      expect(model.totalSyllabi, 4);
      expect(model.totalCertificates, 6);
      expect(model.totalUsers, 15);
      expect(model.totalSchools, 20);
      expect(model.totalCourses, 7);
      expect(model.totalGallery, 8);
      expect(model.totalFaculties, 9);
    });

    test('fromJson should parse camelCase correctly', () {
      final json = {
        'totalStudents': 10,
        'totalClasses': 5,
        'totalNotices': 2,
        'totalSchedules': 3,
        'totalSyllabi': 4,
        'totalCertificates': 6,
        'totalUsers': 15,
        'totalSchools': 20,
        'totalCourses': 7,
        'totalGallery': 8,
        'totalFaculties': 9,
      };

      final model = DashboardModel.fromJson(json);

      expect(model.totalStudents, 10);
      expect(model.totalClasses, 5);
      expect(model.totalNotices, 2);
      expect(model.totalSchedules, 3);
      expect(model.totalSyllabi, 4);
      expect(model.totalCertificates, 6);
      expect(model.totalUsers, 15);
      expect(model.totalSchools, 20);
      expect(model.totalCourses, 7);
      expect(model.totalGallery, 8);
      expect(model.totalFaculties, 9);
    });

    test('fromJson should gracefully handle string numbers', () {
      final json = {
        'total_students': '10',
        'total_classes': '5',
      };

      final model = DashboardModel.fromJson(json);

      expect(model.totalStudents, 10);
      expect(model.totalClasses, 5);
      expect(model.totalSchools, 0); // fallback
    });

    test('fromJson should fallback to total_teachers for totalFaculties', () {
      final json = {
        'total_teachers': 12,
      };

      final model = DashboardModel.fromJson(json);

      expect(model.totalFaculties, 12);
    });

    test('fromJson should fallback to my_courses or courses_count for totalCourses', () {
      final json1 = {'courses_count': 3};
      final json2 = {'my_courses': 4};
      final json3 = {'courses': [{}, {}]};

      expect(DashboardModel.fromJson(json1).totalCourses, 3);
      expect(DashboardModel.fromJson(json2).totalCourses, 4);
      expect(DashboardModel.fromJson(json3).totalCourses, 2);
    });
    
    test('toJson should correctly map to expected JSON', () {
      final model = DashboardModel(
        totalStudents: 1,
        totalClasses: 2,
        totalNotices: 3,
        totalSchedules: 4,
        totalSyllabi: 5,
        totalCertificates: 6,
        totalUsers: 7,
        totalSchools: 8,
      );

      final json = model.toJson();
      expect(json['total_students'], 1);
      expect(json['total_classes'], 2);
      expect(json['total_schools'], 8);
    });
  });
}

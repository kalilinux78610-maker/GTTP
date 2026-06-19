import 'package:flutter_test/flutter_test.dart';
import 'package:gttp/features/school_network/data/models/school_model.dart';

void main() {
  group('SchoolModel', () {
    test('fromJson should parse standard valid data', () {
      final json = {
        'id': 1,
        'name': 'Test School',
        'address': 'New York',
        'total_faculties': 10,
        'total_students': 100,
        'phone': '1234567890',
        'email': 'school@test.com',
        'established_year': '1995',
        'active_courses': 5,
        'principals': [
          {'name': 'Mr. Principal'}
        ],
        'coordinators': [
          {'full_name': 'Mrs. Coordinator'}
        ]
      };

      final model = SchoolModel.fromJson(json);

      expect(model.id, '1');
      expect(model.title, 'Test School');
      expect(model.location, 'New York');
      expect(model.facultyCount, 10);
      expect(model.studentCount, 100);
      expect(model.phone, '1234567890');
      expect(model.email, 'school@test.com');
      expect(model.establishedYear, '1995');
      expect(model.activeCourses, 5);
      expect(model.principalName, 'Mr. Principal');
      expect(model.coordinatorName, 'Mrs. Coordinator');
    });

    test('fromJson should provide default fallbacks for missing data', () {
      final json = <String, dynamic>{};

      final model = SchoolModel.fromJson(json);

      expect(model.title, 'Unnamed School');
      expect(model.location, 'Unknown location');
      expect(model.facultyCount, 0);
      expect(model.studentCount, 0);
      expect(model.principalName, '-');
      expect(model.coordinatorName, '-');
      expect(model.phone, '-');
      expect(model.email, '-');
      expect(model.establishedYear, '-');
      expect(model.activeCourses, 0);
    });

    test('fromJson should fallback to scalar principal_name if array is empty', () {
      final json = {
        'principal_name': 'Direct Principal',
      };

      final model = SchoolModel.fromJson(json);

      expect(model.principalName, 'Direct Principal');
    });

    test('fromJson should parse counts from strings', () {
      final json = {
        'total_faculties': '25',
        'total_students': '500',
      };

      final model = SchoolModel.fromJson(json);

      expect(model.facultyCount, 25);
      expect(model.studentCount, 500);
    });

    test('toJson returns correct map', () {
      final model = SchoolModel(
        id: '1',
        title: 'Title',
        location: 'Loc',
        facultyCount: 5,
        studentCount: 10,
        principalName: 'P',
        coordinatorName: 'C',
        phone: '123',
        email: 'e@e.com',
        establishedYear: '2000',
        activeCourses: 2,
      );

      final json = model.toJson();
      expect(json['id'], '1');
      expect(json['title'], 'Title');
      expect(json['studentCount'], 10);
    });
  });
}

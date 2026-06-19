import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/features/school_network/data/models/school_model.dart';
import 'package:gttp/features/school_network/presentation/providers/school_network_provider.dart';

void main() {
  group('SchoolSearchQueryNotifier', () {
    test('default state is empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final query = container.read(schoolSearchQueryProvider);
      expect(query, isEmpty);
    });

    test('updateQuery updates state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(schoolSearchQueryProvider.notifier).updateQuery('Science');
      final query = container.read(schoolSearchQueryProvider);
      expect(query, 'Science');
    });
  });

  group('filterSchoolsByQuery', () {
    final mockSchools = [
      SchoolModel(
        id: '1',
        title: 'Science Institute',
        location: 'New York',
        facultyCount: 10,
        studentCount: 100,
        principalName: 'P1',
        coordinatorName: 'C1',
        phone: '123',
        email: 'e@e.com',
        establishedYear: '2000',
        activeCourses: 5,
      ),
      SchoolModel(
        id: '2',
        title: 'Arts Academy',
        location: 'California',
        facultyCount: 5,
        studentCount: 50,
        principalName: 'P2',
        coordinatorName: 'C2',
        phone: '456',
        email: 'e2@e.com',
        establishedYear: '2001',
        activeCourses: 2,
      ),
      SchoolModel(
        id: '3',
        title: 'Tech High',
        location: 'Science Park',
        facultyCount: 20,
        studentCount: 200,
        principalName: 'P3',
        coordinatorName: 'C3',
        phone: '789',
        email: 'e3@e.com',
        establishedYear: '2010',
        activeCourses: 10,
      ),
    ];

    test('returns all schools when query is empty', () {
      final filtered = filterSchoolsByQuery(mockSchools, '');
      expect(filtered.length, 3);
    });

    test('filters schools by name', () {
      final filtered = filterSchoolsByQuery(mockSchools, 'Arts');
      expect(filtered.length, 1);
      expect(filtered.first.title, 'Arts Academy');
    });

    test('filters schools by location', () {
      final filtered = filterSchoolsByQuery(mockSchools, 'California');
      expect(filtered.length, 1);
      expect(filtered.first.title, 'Arts Academy');
    });

    test('filters schools by name and location ignoring case', () {
      final filtered = filterSchoolsByQuery(mockSchools, 'science');
      // 'Science Institute' matches name, 'Tech High' matches location 'Science Park'
      expect(filtered.length, 2);
    });
  });
}

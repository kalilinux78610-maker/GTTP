import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gttp/core/network/api_client.dart';
import 'package:gttp/features/auth/domain/entities/user.dart';
import 'package:gttp/features/dashboard/data/datasources/dashboard_remote_datasource.dart';

import 'package:gttp/core/network/api_exception.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late DashboardRemoteDataSource dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = DashboardRemoteDataSource(mockApiClient, null);
  });

  group('DashboardRemoteDataSource', () {
    test('fetchDashboardResponse calls correct endpoint for default user', () async {
      when(() => mockApiClient.get(any(), requiresAuth: any(named: 'requiresAuth')))
          .thenAnswer((_) async => {'data': {}});

      await dataSource.fetchDashboardResponse();

      verify(() => mockApiClient.get('/dashboard', requiresAuth: true)).called(1);
    });

    test('fetchDashboardResponse calls student endpoint for student role', () async {
      final studentUser = User(id: 1, email: 'test@t.com', name: 'Student', role: 'student', roleLevel: 1, isAlumni: false, isActive: true);
      final studentDataSource = DashboardRemoteDataSource(mockApiClient, studentUser);

      when(() => mockApiClient.get(any(), requiresAuth: any(named: 'requiresAuth')))
          .thenAnswer((_) async => {'data': {}});

      await studentDataSource.fetchDashboardResponse();

      verify(() => mockApiClient.get('/student/dashboard', requiresAuth: true)).called(1);
    });

    test('getDashboardData fetches schools and merges data', () async {
      when(() => mockApiClient.get(any(), requiresAuth: any(named: 'requiresAuth')))
          .thenAnswer((invocation) async {
        final path = invocation.positionalArguments[0] as String;
        if (path.contains('dashboard')) {
          return {
            'data': {
              'total_students': 100,
              'user': {'name': 'Test User'}
            }
          };
        } else if (path == '/schools') {
          return {
            'data': [
              {
                'total_students': 150, // Should override
                'total_faculties': 20,
                'name': 'Merged School'
              }
            ]
          };
        }
        return {};
      });

      final result = await dataSource.getDashboardData();

      expect(result.totalStudents, 150);
      expect(result.totalUsers, 20); // total_faculties + 0
      expect(result.schoolName, 'Merged School');
      expect(result.currentUserDisplayName, 'Test User');
    });

    test('getDashboardData handles schools API failure gracefully', () async {
      when(() => mockApiClient.get(any(), requiresAuth: any(named: 'requiresAuth')))
          .thenAnswer((invocation) async {
        final path = invocation.positionalArguments[0] as String;
        if (path.contains('dashboard')) {
          return {
            'data': {
              'total_students': 100,
            }
          };
        } else {
          throw ApiException('Schools error');
        }
      });

      final result = await dataSource.getDashboardData();

      // Dashboard API succeeded, Schools failed. It should not crash.
      expect(result.totalStudents, 100);
      expect(result.schoolName, null);
    });
  });
}

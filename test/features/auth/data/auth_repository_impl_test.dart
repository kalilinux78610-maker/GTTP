import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gttp/core/network/api_exception.dart';
import 'package:gttp/core/security/secure_storage_service.dart';
import 'package:gttp/features/auth/data/auth_remote_datasource.dart';
import 'package:gttp/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockSecureStorageService mockSecureStorage;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockSecureStorage = MockSecureStorageService();
    repository = AuthRepositoryImpl(mockRemoteDataSource, mockSecureStorage);
  });

  group('AuthRepositoryImpl', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';

    test('should call login on remote data source', () async {
      when(() => mockRemoteDataSource.login(
            usernameOrEmail: any(named: 'usernameOrEmail'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => {});

      await repository.login(usernameOrEmail: tEmail, password: tPassword);

      verify(() => mockRemoteDataSource.login(
            usernameOrEmail: tEmail,
            password: tPassword,
          )).called(1);
    });

    test('should throw ApiException when remote data source throws unknown exception on login', () async {
      when(() => mockRemoteDataSource.login(
            usernameOrEmail: any(named: 'usernameOrEmail'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Unknown Error'));

      expect(
        () => repository.login(usernameOrEmail: tEmail, password: tPassword),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Login failed due to an unexpected error.')),
      );
    });

    test('should call forgotPassword on remote data source', () async {
      when(() => mockRemoteDataSource.forgotPassword(email: any(named: 'email')))
          .thenAnswer((_) async => {});

      await repository.forgotPassword(email: tEmail);

      verify(() => mockRemoteDataSource.forgotPassword(email: tEmail)).called(1);
    });

    test('should delete tokens on logout', () async {
      when(() => mockSecureStorage.clearTokens()).thenAnswer((_) async {});
      when(() => mockSecureStorage.clearPendingUserId()).thenAnswer((_) async {});
      when(() => mockSecureStorage.clearDisplayName()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => mockSecureStorage.clearTokens()).called(1);
      verify(() => mockSecureStorage.clearPendingUserId()).called(1);
      verify(() => mockSecureStorage.clearDisplayName()).called(1);
    });
  });
}

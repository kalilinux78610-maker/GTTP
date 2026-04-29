import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/network/api_client.dart';
import 'package:gttp/core/security/secure_storage_service.dart';
import 'package:gttp/features/auth/data/auth_remote_datasource.dart';
import 'package:gttp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gttp/features/auth/domain/repositories/auth_repository.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  // Use the platform-aware factory (handles Web, Android, iOS differences)
  return SecureStorageService.create();
});

final dioProvider = Provider<Dio>((ref) => Dio());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient.create(ref.read(secureStorageProvider));
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    ref.read(apiClientProvider),
    ref.read(secureStorageProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDataSourceProvider),
    ref.read(secureStorageProvider),
  );
});

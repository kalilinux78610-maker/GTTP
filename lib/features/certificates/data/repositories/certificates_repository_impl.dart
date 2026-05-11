import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/network/api_exception.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/certificates/data/datasources/certificates_remote_datasource.dart';
import 'package:gttp/features/certificates/data/models/certificate_model.dart';
import 'package:gttp/features/certificates/domain/repositories/certificates_repository.dart';

final certificatesRemoteDataSourceProvider = Provider<CertificatesRemoteDataSource>((ref) {
  return CertificatesRemoteDataSource(ref.read(apiClientProvider));
});

final certificatesRepositoryProvider = Provider<CertificatesRepository>((ref) {
  return CertificatesRepositoryImpl(ref.read(certificatesRemoteDataSourceProvider));
});

class CertificatesRepositoryImpl implements CertificatesRepository {
  final CertificatesRemoteDataSource _remoteDataSource;

  CertificatesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<CertificateModel>> getCertificates() async {
    try {
      final data = await _remoteDataSource.getCertificates();
      return data.map((json) => CertificateModel.fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to get certificates: $e');
    }
  }

  @override
  Future<CertificateModel> getCertificateDetail(String id) async {
    try {
      final data = await _remoteDataSource.getCertificateDetail(id);
      return CertificateModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to get certificate detail: $e');
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/network/api_exception.dart';
import 'package:gttp/features/auth/presentation/providers/auth_providers.dart';
import 'package:gttp/features/notices/data/datasources/notices_remote_datasource.dart';
import 'package:gttp/features/notices/data/models/notice_model.dart';
import 'package:gttp/features/notices/domain/repositories/notices_repository.dart';

final noticesRemoteDataSourceProvider = Provider<NoticesRemoteDataSource>((ref) {
  return NoticesRemoteDataSource(ref.read(apiClientProvider));
});

final noticesRepositoryProvider = Provider<NoticesRepository>((ref) {
  return NoticesRepositoryImpl(ref.read(noticesRemoteDataSourceProvider));
});

class NoticesRepositoryImpl implements NoticesRepository {
  final NoticesRemoteDataSource _remoteDataSource;

  NoticesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<NoticeModel>> getNotices() async {
    try {
      final data = await _remoteDataSource.getNotices();
      return data.map((json) => NoticeModel.fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to get notices: $e');
    }
  }

  @override
  Future<NoticeModel> getNoticeDetail(String id) async {
    try {
      final data = await _remoteDataSource.getNoticeDetail(id);
      return NoticeModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to get notice detail: $e');
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _remoteDataSource.markAsRead(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to mark notice as read: $e');
    }
  }
}

import 'package:gttp/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:gttp/core/network/api_client.dart';
import 'package:gttp/core/security/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

void main() async {
  final secureStorage = SecureStorageService(const FlutterSecureStorage());
  final apiClient = ApiClient(Dio(), secureStorage);
  final dataSource = ReportsRemoteDataSource(apiClient);
  
  debugPrint('Fetching reports...');
  final reports = await dataSource.getFlaggedReports();
  
  for (var report in reports) {
    debugPrint('Report ID: ${report.id}, Category: ${report.category}');
  }
  debugPrint('Done.');
}

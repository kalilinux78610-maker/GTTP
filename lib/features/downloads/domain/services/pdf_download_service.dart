import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gttp/core/cache/cache_service.dart';

final pdfDownloadServiceProvider = Provider<PdfDownloadService>((ref) {
  return PdfDownloadService();
});

class PdfDownloadService {
  final Dio _dio = Dio();

  String _getCacheKey(String courseId) => 'pdf_download_$courseId';

  Future<String?> downloadCoursePdf(String courseId, String url) async {
    try {
      final cacheKey = _getCacheKey(courseId);
      
      // Check if already downloaded
      final cachedPath = CacheService.instance.get<String>(cacheKey);
      if (cachedPath != null) {
        if (File(cachedPath).existsSync()) {
          return cachedPath; // Return existing
        } else {
          // File was deleted outside of cache, clear cache
          CacheService.instance.delete(cacheKey);
        }
      }

      // Download
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'course_${courseId}_module.pdf';
      final localPath = '${dir.path}/$fileName';

      await _dio.download(url, localPath);

      // Save to Hive cache with no expiry
      await CacheService.instance.put(cacheKey, localPath);

      return localPath;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PDF Download Error: $e');
      }
      return null;
    }
  }

  Future<String?> getOfflinePdfPath(String courseId) async {
    final cacheKey = _getCacheKey(courseId);
    final cachedPath = CacheService.instance.get<String>(cacheKey);
    
    if (cachedPath != null) {
      if (File(cachedPath).existsSync()) {
        return cachedPath;
      } else {
        CacheService.instance.delete(cacheKey);
      }
    }
    return null;
  }
  
  Future<void> deleteOfflinePdf(String courseId) async {
    final cacheKey = _getCacheKey(courseId);
    final cachedPath = CacheService.instance.get<String>(cacheKey);
    
    if (cachedPath != null) {
      final file = File(cachedPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
      await CacheService.instance.delete(cacheKey);
    }
  }
}

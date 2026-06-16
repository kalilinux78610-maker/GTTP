import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  static const String pdfDownloadsBox = 'pdf_downloads';
  static const String coursesCacheBox = 'courses_cache';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(pdfDownloadsBox);
    await Hive.openBox<String>(coursesCacheBox);
  }

  Box<String> get pdfDownloads => Hive.box<String>(pdfDownloadsBox);
  Box<String> get coursesCache => Hive.box<String>(coursesCacheBox);
}

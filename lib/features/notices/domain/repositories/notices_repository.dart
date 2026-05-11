import 'package:gttp/features/notices/data/models/notice_model.dart';

abstract class NoticesRepository {
  Future<List<NoticeModel>> getNotices();
  Future<NoticeModel> getNoticeDetail(String id);
  Future<void> markAsRead(String id);
}

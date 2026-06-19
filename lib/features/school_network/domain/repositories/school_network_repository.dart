import 'package:gttp/features/school_network/data/models/school_model.dart';

abstract class SchoolNetworkRepository {
  Future<List<SchoolModel>> getSchools();
  Stream<List<SchoolModel>> watchSchools();
  Future<SchoolModel> getSchoolDetail(String id);
  Future<Map<String, dynamic>> getFacultyDetail(String id);
}

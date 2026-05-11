import 'package:gttp/features/school_network/data/models/school_model.dart';

abstract class SchoolNetworkRepository {
  Future<List<SchoolModel>> getSchools();
  Future<SchoolModel> getSchoolDetail(String id);
}

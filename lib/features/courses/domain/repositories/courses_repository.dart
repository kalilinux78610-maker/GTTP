import '../../data/models/course_model.dart';

abstract class CoursesRepository {
  Future<List<CourseModel>> getCourses();
  Future<CourseModel?> getCourseDetails(String id);
}

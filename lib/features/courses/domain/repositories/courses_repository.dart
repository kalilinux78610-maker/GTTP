import '../../data/models/course_model.dart';

abstract class CoursesRepository {
  Future<List<CourseModel>> getCourses();
  Future<CourseModel?> getCourseDetails(String id);
  Future<void> enrollCourse(String id);
  Future<List<Map<String, dynamic>>> getCourseEnrolledStudents(String id);
  Future<List<Map<String, dynamic>>> getPendingSubmissions(String courseId);
  Future<void> submitQuiz(String courseId, String moduleId, int scorePercentage, bool passed);
  Future<Map<String, dynamic>> markModuleComplete(String courseId, String moduleId);
}

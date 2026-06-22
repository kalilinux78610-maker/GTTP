import '../../data/models/course_model.dart';

abstract class CoursesRepository {
  Future<List<CourseModel>> getCourses();
  Future<CourseModel?> getCourseDetails(String id);
  Future<void> enrollCourse(String id);
  Future<List<Map<String, dynamic>>> getCourseEnrolledStudents(String id);
  Future<List<Map<String, dynamic>>> getPendingSubmissions(String courseId);
  Future<void> submitQuiz(String courseId, String moduleId, int scorePercentage, bool passed, [String? submoduleId]);
  Future<Map<String, dynamic>> markModuleComplete(String courseId, String moduleId);
  Future<Map<String, dynamic>> markSubmoduleComplete(String courseId, String moduleId, String submoduleId);
  Future<void> submitSessionProof(String courseId, String sessionId, String fileName, List<int> fileBytes);
  Future<void> reviewSubmission(String submissionId, String status, String reviewNotes);
}

class DashboardModel {
  final int totalStudents;
  final int totalClasses;
  final int totalNotices;
  final int totalSchedules;
  final int totalSyllabi;
  final int totalCertificates;
  final int totalUsers;
  final int totalSchools;
  /// Published / catalog courses count when the dashboard API sends it.
  final int totalCourses;
  /// Number of gallery items/photos
  final int totalGallery;
  /// Total number of faculties/teachers
  final int totalFaculties;

  /// Class Overview Stats
  final int completionPercentage;
  final int needGrading;


  /// Logged-in user display name when the API includes it (e.g. under `user`).
  final String? currentUserDisplayName;
  
  /// The school logo URL when resolved from the /schools endpoint.
  final String? schoolLogo;

  /// The school name from the /schools endpoint.
  final String? schoolName;

  /// The school type (institute type) from the /schools endpoint.
  final String? schoolType;

  /// Profile fields from nested `user` blocks when the dashboard API includes them.
  final String? currentUserPhone;
  final String? currentUserOrganization;
  final String? currentUserInstituteType;

  /// Student profile specific data
  final Map<String, dynamic>? studentProfile;
  final Map<String, dynamic>? studentClass;
  final List<dynamic>? enrolledCourses;

  /// Role-specific lists from dashboards
  final List<dynamic>? facultiesList;
  final List<dynamic>? studentsList;
  final List<dynamic>? institutesList;

  DashboardModel({
    required this.totalStudents,
    required this.totalClasses,
    required this.totalNotices,
    required this.totalSchedules,
    required this.totalSyllabi,
    required this.totalCertificates,
    required this.totalUsers,
    required this.totalSchools,
    this.totalCourses = 0,
    this.totalGallery = 0,
    this.totalFaculties = 0,
    this.completionPercentage = 0,
    this.needGrading = 0,
    this.currentUserDisplayName,
    this.schoolLogo,
    this.schoolName,
    this.schoolType,
    this.currentUserPhone,
    this.currentUserOrganization,
    this.currentUserInstituteType,
    this.studentProfile,
    this.studentClass,
    this.enrolledCourses,
    this.facultiesList,
    this.studentsList,
    this.institutesList,
  });

  /// Custom fromJson that handles both snake_case and camelCase keys
  factory DashboardModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserDisplayName,
    String? currentUserPhone,
    String? currentUserOrganization,
    String? currentUserInstituteType,
  }) {
    int pick(String snake, String camel) {
      final v = json[snake] ?? json[camel];
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    var totalCourses = pick('total_courses', 'totalCourses');
    if (totalCourses == 0) {
      totalCourses = pick('courses_count', 'coursesCount');
    }
    if (totalCourses == 0) {
      totalCourses = pick('enrolled_courses', 'enrolledCourses');
    }
    if (totalCourses == 0) {
      totalCourses = pick('my_courses', 'myCourses');
    }
    if (totalCourses == 0) {
      totalCourses = pick('active_courses_count', 'activeCoursesCount');
    }
    if (totalCourses == 0) {
      totalCourses = pick('total_active_courses', 'totalActiveCourses');
    }
    if (totalCourses == 0 && json['courses'] is List) {
      totalCourses = (json['courses'] as List).length;
    }

    var totalSchedules = pick('total_schedules', 'totalSchedules');
    if (totalSchedules == 0) {
      totalSchedules = pick('schedules_count', 'schedulesCount');
    }
    if (totalSchedules == 0) {
      totalSchedules = pick('my_schedules', 'mySchedules');
    }

    var totalCertificates = pick('total_certificates', 'totalCertificates');
    if (totalCertificates == 0) {
      totalCertificates = pick('certificates_count', 'certificatesCount');
    }
    if (totalCertificates == 0) {
      totalCertificates = pick('my_certificates', 'myCertificates');
    }
    if (totalCertificates == 0) {
      totalCertificates = pick('earned_certificates', 'earnedCertificates');
    }

    return DashboardModel(
      totalStudents: pick('total_students', 'totalStudents'),
      totalClasses: pick('total_classes', 'totalClasses'),
      totalNotices: pick('total_notices', 'totalNotices'),
      totalSchedules: totalSchedules,
      totalSyllabi: pick('total_syllabi', 'totalSyllabi'),
      totalCertificates: totalCertificates,
      totalUsers: pick('total_users', 'totalUsers'),
      totalSchools: pick('total_schools', 'totalSchools') == 0 ? pick('institutes_count', 'institutesCount') : pick('total_schools', 'totalSchools'),
      totalGallery: pick('total_gallery', 'totalGallery'),
      totalCourses: totalCourses,
      totalFaculties: pick('total_faculties', 'totalFaculties') == 0 ? pick('total_teachers', 'totalTeachers') == 0 ? pick('faculties_count', 'facultiesCount') : pick('total_teachers', 'totalTeachers') : pick('total_faculties', 'totalFaculties'),
      completionPercentage: pick('completion_percentage', 'completionPercentage') == 0 ? pick('completion_rate', 'completionRate') : pick('completion_percentage', 'completionPercentage'),
      needGrading: pick('need_grading', 'needGrading') == 0 ? pick('pending_grading', 'pendingGrading') : pick('need_grading', 'needGrading'),
      currentUserDisplayName: currentUserDisplayName,
      schoolLogo: json['school_logo'] as String? ?? json['schoolLogo'] as String?,
      schoolName: json['school_name'] as String? ?? json['schoolName'] as String? ?? (json['school'] is Map ? json['school']['name'] as String? : null),
      schoolType: json['school_type'] as String? ?? json['schoolType'] as String? ?? json['institute_type'] as String? ?? json['type'] as String?,
      currentUserPhone: currentUserPhone,
      currentUserOrganization: currentUserOrganization,
      currentUserInstituteType: currentUserInstituteType,
      studentProfile: json['profile'] as Map<String, dynamic>?,
      studentClass: json['class'] as Map<String, dynamic>?,
      enrolledCourses: json['courses'] as List<dynamic>?,
      facultiesList: json['faculties'] as List<dynamic>?,
      studentsList: json['students'] as List<dynamic>?,
      institutesList: json['institutes'] as List<dynamic>?,
    );
  }

  DashboardModel copyWith({
    int? totalStudents,
    int? totalClasses,
    int? totalNotices,
    int? totalSchedules,
    int? totalSyllabi,
    int? totalCertificates,
    int? totalUsers,
    int? totalSchools,
    int? totalCourses,
    int? totalGallery,
    int? totalFaculties,
    int? completionPercentage,
    int? needGrading,
    String? currentUserDisplayName,
    String? schoolLogo,
    String? schoolName,
    String? schoolType,
    String? currentUserPhone,
    String? currentUserOrganization,
    String? currentUserInstituteType,
    Map<String, dynamic>? studentProfile,
    Map<String, dynamic>? studentClass,
    List<dynamic>? enrolledCourses,
    List<dynamic>? facultiesList,
    List<dynamic>? studentsList,
    List<dynamic>? institutesList,
  }) {
    return DashboardModel(
      totalStudents: totalStudents ?? this.totalStudents,
      totalClasses: totalClasses ?? this.totalClasses,
      totalNotices: totalNotices ?? this.totalNotices,
      totalSchedules: totalSchedules ?? this.totalSchedules,
      totalSyllabi: totalSyllabi ?? this.totalSyllabi,
      totalCertificates: totalCertificates ?? this.totalCertificates,
      totalUsers: totalUsers ?? this.totalUsers,
      totalSchools: totalSchools ?? this.totalSchools,
      totalCourses: totalCourses ?? this.totalCourses,
      totalGallery: totalGallery ?? this.totalGallery,
      totalFaculties: totalFaculties ?? this.totalFaculties,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      needGrading: needGrading ?? this.needGrading,
      currentUserDisplayName: currentUserDisplayName ?? this.currentUserDisplayName,
      schoolLogo: schoolLogo ?? this.schoolLogo,
      schoolName: schoolName ?? this.schoolName,
      schoolType: schoolType ?? this.schoolType,
      currentUserPhone: currentUserPhone ?? this.currentUserPhone,
      currentUserOrganization:
          currentUserOrganization ?? this.currentUserOrganization,
      currentUserInstituteType:
          currentUserInstituteType ?? this.currentUserInstituteType,
      studentProfile: studentProfile ?? this.studentProfile,
      studentClass: studentClass ?? this.studentClass,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      facultiesList: facultiesList ?? this.facultiesList,
      studentsList: studentsList ?? this.studentsList,
      institutesList: institutesList ?? this.institutesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_students': totalStudents,
      'total_classes': totalClasses,
      'total_notices': totalNotices,
      'total_schedules': totalSchedules,
      'total_syllabi': totalSyllabi,
      'total_certificates': totalCertificates,
      'total_users': totalUsers,
      'total_schools': totalSchools,
      'total_courses': totalCourses,
      'total_gallery': totalGallery,
      'total_faculties': totalFaculties,
      'completion_percentage': completionPercentage,
      'need_grading': needGrading,
      'currentUserDisplayName': currentUserDisplayName,
      'school_logo': schoolLogo,
      'school_name': schoolName,
      'school_type': schoolType,
      'currentUserPhone': currentUserPhone,
      'currentUserOrganization': currentUserOrganization,
      'currentUserInstituteType': currentUserInstituteType,
      'profile': studentProfile,
      'class': studentClass,
      'courses': enrolledCourses,
      'faculties': facultiesList,
      'students': studentsList,
      'institutes': institutesList,
    };
  }
}

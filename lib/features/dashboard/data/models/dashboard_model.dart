class DashboardModel {
  final int totalStudents;
  final int totalClasses;
  final int totalNotices;
  final int totalSchedules;
  final int totalSyllabi;
  final int totalCertificates;
  final int totalUsers;
  final int totalSchools;

  /// Logged-in user display name when the API includes it (e.g. under `user`).
  final String? currentUserDisplayName;

  DashboardModel({
    required this.totalStudents,
    required this.totalClasses,
    required this.totalNotices,
    required this.totalSchedules,
    required this.totalSyllabi,
    required this.totalCertificates,
    required this.totalUsers,
    required this.totalSchools,
    this.currentUserDisplayName,
  });

  factory DashboardModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserDisplayName,
  }) {
    int pick(String snake, String camel) {
      final v = json[snake] ?? json[camel];
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('$v') ?? 0;
    }

    return DashboardModel(
      totalStudents: pick('total_students', 'totalStudents'),
      totalClasses: pick('total_classes', 'totalClasses'),
      totalNotices: pick('total_notices', 'totalNotices'),
      totalSchedules: pick('total_schedules', 'totalSchedules'),
      totalSyllabi: pick('total_syllabi', 'totalSyllabi'),
      totalCertificates: pick('total_certificates', 'totalCertificates'),
      totalUsers: pick('total_users', 'totalUsers'),
      totalSchools: pick('total_schools', 'totalSchools'),
      currentUserDisplayName: currentUserDisplayName,
    );
  }
}

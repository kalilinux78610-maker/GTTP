/// App roles returned by the GTTP API (`user.role`, etc.).
enum AppUserRole {
  student,
  faculty,
  coordinator,
  principal,
  admin,
  superAdmin,
  unknown;

  static AppUserRole fromApi(String? raw) {
    if (raw == null || raw.trim().isEmpty) return AppUserRole.unknown;
    final value = raw.trim().toLowerCase().replaceAll('_', ' ');

    // Handle role_level strings (0 = Super Admin)
    if (raw == '0') return AppUserRole.superAdmin;
    if (raw == '1') return AppUserRole.admin;
    if (raw == '2') return AppUserRole.coordinator;
    if (raw == '3') return AppUserRole.principal;
    if (raw == '4') return AppUserRole.faculty;
    if (raw == '5') return AppUserRole.student;

    if (value.contains('principal')) return AppUserRole.principal;
    if (value.contains('coordinator')) return AppUserRole.coordinator;
    if (value.contains('super') && value.contains('admin')) {
      return AppUserRole.superAdmin;
    }
    if (value.contains('admin')) return AppUserRole.admin;
    if (value.contains('faculty') || value.contains('teacher')) return AppUserRole.faculty;
    if (value.contains('student')) return AppUserRole.student;

    return AppUserRole.unknown;
  }

  String get label {
    switch (this) {
      case AppUserRole.student:
        return 'Student';
      case AppUserRole.faculty:
        return 'Faculty';
      case AppUserRole.admin:
        return 'Trust Administrator';
      case AppUserRole.superAdmin:
        return 'Super Administrator';
      case AppUserRole.coordinator:
        return 'National Coordinator';
      case AppUserRole.principal:
        return 'Principal';
      case AppUserRole.unknown:
        return 'User';
    }
  }

  bool get isCoordinator => this == AppUserRole.coordinator;
  bool get isPrincipal => this == AppUserRole.principal;

  /// Trust / school admin style dashboard (current default UI).
  bool get usesAdminDashboard =>
      this == AppUserRole.admin ||
      this == AppUserRole.superAdmin ||
      this == AppUserRole.unknown;

  bool get usesCoordinatorDashboard => isCoordinator;
  bool get usesPrincipalDashboard => isPrincipal;
  bool get usesTeacherDashboard => this == AppUserRole.faculty;

  bool get canAccessDataExport =>
      this == AppUserRole.admin || 
      this == AppUserRole.superAdmin || 
      this == AppUserRole.coordinator || 
      this == AppUserRole.principal ||
      this == AppUserRole.unknown;

  bool get canAccessSchoolNetwork =>
      this == AppUserRole.admin ||
      this == AppUserRole.superAdmin ||
      this == AppUserRole.coordinator ||
      this == AppUserRole.principal ||
      this == AppUserRole.faculty ||
      this == AppUserRole.unknown;
}

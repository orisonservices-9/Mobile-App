/// Paths for the single school app. Role resolution happens only after OTP
/// verification; the client never accepts a role chosen by the user.
abstract final class SchoolApiPaths {
  static const requestOtp = '/api/mobile/auth/request-otp';
  static const verifyOtp = '/api/mobile/auth/verify-otp';
  static const session = '/api/mobile/session';

  static const teacherProfile = '/api/mobile/teacher/me';
  static const teacherDashboard = '/api/mobile/teacher/dashboard';
  static const teacherClasses = '/api/mobile/teacher/classes';
  static const teacherTimetable = '/api/mobile/teacher/timetable';
  static const teacherTasks = '/api/mobile/teacher/tasks';
  static const teacherNotices = '/api/mobile/teacher/notices';
  static const teacherLessonPlans = '/api/mobile/teacher/lesson-plans';
  static const teacherLeave = '/api/mobile/teacher/leave';

  static const leadershipDashboard = '/api/mobile/leadership/dashboard';
  static const leadershipAlerts = '/api/mobile/leadership/alerts';
  static const leadershipApprovals = '/api/mobile/leadership/approvals';
  static const leadershipAcademics = '/api/mobile/leadership/academics';
  static const leadershipAttendance = '/api/mobile/leadership/attendance';
  static const leadershipFinance = '/api/mobile/leadership/finance';
  static const leadershipAdmissions = '/api/mobile/leadership/admissions';
  static const leadershipStaff = '/api/mobile/leadership/staff';
  static const leadershipTransport = '/api/mobile/leadership/transport';
  static const leadershipAnnouncements = '/api/mobile/leadership/announcements';

  static String decideApproval(String approvalId) =>
      '/api/mobile/leadership/approvals/$approvalId/decision';
  static String resolveAlert(String alertId) =>
      '/api/mobile/leadership/alerts/$alertId/resolve';

  static String classStudents(String classId) =>
      '/api/mobile/teacher/classes/$classId/students';
  static String classAttendance(String classId) =>
      '/api/mobile/teacher/classes/$classId/attendance';
  static String classHomework(String classId) =>
      '/api/mobile/teacher/classes/$classId/homework';
  static String completeLessonPlan(String planId) =>
      '/api/mobile/teacher/lesson-plans/$planId/complete';
  static String examMarks(String examId, String classId) =>
      '/api/mobile/teacher/exams/$examId/classes/$classId/marks';
}

/// Stable path catalogue shared by the future live repository implementation.
///
/// This file intentionally performs no network calls. The premium preview continues
/// to use `DemoOrisonRepository` until deployment services are configured and the
/// live adapter is explicitly enabled.
abstract final class ParentApiPaths {
  static const requestOtp = '/api/parent/auth/request-otp';
  static const verifyOtp = '/api/parent/auth/verify-otp';
  static const parentProfile = '/api/parent/me';
  static const students = '/api/parent/students';

  static String dashboard(String studentId) =>
      '/api/parent/students/$studentId/dashboard';
  static String attendance(String studentId) =>
      '/api/parent/students/$studentId/attendance';
  static String results(String studentId) =>
      '/api/parent/students/$studentId/results';
  static String homework(String studentId) =>
      '/api/parent/students/$studentId/homework';
  static String homeworkStatus(String studentId, String homeworkId) =>
      '/api/parent/students/$studentId/homework/$homeworkId/status';
  static String timetable(String studentId) =>
      '/api/parent/students/$studentId/timetable';
  static String fees(String studentId) =>
      '/api/parent/students/$studentId/fees';
  static String paymentProof(String feeId) =>
      '/api/parent/fees/$feeId/payment-proof';
  static String leave(String studentId) =>
      '/api/parent/students/$studentId/leave';
  static String hallTickets(String studentId) =>
      '/api/parent/students/$studentId/hall-tickets';
  static String transport(String studentId) =>
      '/api/parent/students/$studentId/transport';
  static String notices(String studentId) =>
      '/api/parent/students/$studentId/notices';
  static String markNoticeRead(String studentId, String noticeId) =>
      '/api/parent/students/$studentId/notices/$noticeId/read';
  static String helpRequests(String studentId) =>
      '/api/parent/students/$studentId/help-requests';
  static String upload(String category) => '/api/parent/uploads/$category';
}

/// External services that must be configured before replacing the demo repository.
abstract final class ParentApiReleaseGate {
  static const requiredServices = <String>[
    'HTTPS API URL',
    'SMS OTP provider',
    'secure attachment storage',
    'push notification provider',
    'bus GPS/map provider',
  ];
}

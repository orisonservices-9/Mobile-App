import '../models/models.dart';
import '../models/app_session.dart';
import '../models/teacher_models.dart';
import '../models/leadership_models.dart';

abstract class OrisonRepository {
  Future<AppSession?> authenticateWithOtp(String mobile, String otp);
  Future<bool> verifyOtp(String mobile, String otp);
  Future<ParentSnapshot> loadParentHome();
  Future<TeacherSnapshot> loadTeacherHome(String teacherId);
  Future<LeadershipSnapshot> loadLeadershipHome(String userId);
  Future<bool> decideLeadershipApproval(String approvalId, String decision);
  Future<bool> resolveLeadershipAlert(String alertId);
  Future<bool> publishLeadershipAnnouncement(String title, String audience);
  Future<bool> submitTeacherAttendance({
    required String classId,
    required DateTime date,
    required Map<String, String> statuses,
  });
  Future<bool> assignTeacherHomework({
    required String classId,
    required String subject,
    required String title,
    required String instructions,
    required DateTime dueDate,
    required List<String> attachmentNames,
  });
  Future<bool> completeTeacherLessonPlan(String planId);
  Future<bool> applyTeacherLeave(TeacherLeaveRequest request);
  Future<ParentProfile> updateProfile(ParentProfile profile);
  Future<LeaveRequest> applyLeave({
    required String studentId,
    required DateTime from,
    required DateTime to,
    required String type,
    required String description,
    String? attachmentName,
  });
  Future<void> initiateFeePayment(String feeId);
  Future<bool> submitFeePaymentProof({
    required String feeId,
    required double amount,
    required String transactionId,
    required String proofName,
  });
  Future<bool> updateHomeworkStatus({
    required String studentId,
    required String homeworkId,
    required bool completed,
  });
  Future<bool> markNoticeRead(String noticeId);
  Future<HelpRequest> submitHelpRequest({
    required String studentId,
    required String kind,
    required String category,
    required String description,
    required String priority,
    String? preferredTime,
    String? attachmentName,
    String? parentName,
    String? studentName,
    String? mobile,
  });
}

class DemoOrisonRepository implements OrisonRepository {
  final Map<String, bool> _homeworkStatuses = {
    'hw-math-72': false,
    'hw-science-heart': false,
    'hw-english-ch6': true,
    'hw-social-map': false,
  };
  final Set<String> _readNoticeIds = {'notice-holiday'};
  final List<LeaveRequest> _leaveRequests = [
    LeaveRequest(
      id: 'leave-2026-03',
      type: 'Family event',
      from: DateTime(2026, 8, 28),
      to: DateTime(2026, 8, 29),
      description: 'Attending a close family wedding outside the city.',
      status: 'Pending',
      appliedOn: DateTime(2026, 8, 17),
    ),
    LeaveRequest(
      id: 'leave-2026-02',
      type: 'Medical leave',
      from: DateTime(2026, 8, 3),
      to: DateTime(2026, 8, 4),
      description: 'Doctor advised two days of rest due to fever.',
      status: 'Approved',
      appliedOn: DateTime(2026, 8, 2),
      attachmentName: 'medical-certificate.pdf',
    ),
    LeaveRequest(
      id: 'leave-2026-01',
      type: 'Personal leave',
      from: DateTime(2026, 7, 10),
      to: DateTime(2026, 7, 10),
      description: '',
      status: 'Approved',
      appliedOn: DateTime(2026, 7, 8),
    ),
  ];
  final List<HelpRequest> _helpRequests = [
    HelpRequest(
      id: 'CB-260817-12',
      kind: 'School callback',
      category: 'Exam performance',
      description:
          'Need guidance on improving English performance before Unit Test III.',
      status: 'Scheduled',
      createdAt: DateTime(2026, 8, 17, 18, 30),
      priority: 'Normal',
      preferredTime: '4:00 PM – 6:00 PM',
      parentName: 'Anita Thorne',
      studentName: 'Marcus Thorne',
      mobile: '9876543210',
    ),
    HelpRequest(
      id: 'APP-260810-08',
      kind: 'App support',
      category: 'Payment & receipts',
      description: 'The receipt PDF was not opening after the first download.',
      status: 'Resolved',
      createdAt: DateTime(2026, 8, 10, 11, 15),
      priority: 'Normal',
      attachmentName: 'receipt-error.png',
      parentName: 'Anita Thorne',
      studentName: 'Marcus Thorne',
      mobile: '9876543210',
      preferredTime: '12:00 PM – 3:00 PM',
    ),
  ];

  ParentProfile _profile = const ParentProfile(
    name: 'Anita Thorne',
    mobile: '9876543210',
    email: 'anita@example.com',
    address: '12 Lake View Road, Hyderabad',
    relationship: 'Mother',
    occupation: 'Architect',
    alternateMobile: '9123456780',
    emergencyName: 'David Thorne',
    emergencyMobile: '9988776655',
    preferredLanguage: 'English',
    pushNotifications: true,
    whatsAppUpdates: true,
    emailUpdates: false,
  );

  @override
  Future<AppSession?> authenticateWithOtp(String mobile, String otp) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final normalized = mobile.replaceAll(RegExp(r'\D'), '');
    final number = normalized.length > 10
        ? normalized.substring(normalized.length - 10)
        : normalized;
    if (number.length != 10 || otp.trim().length != 4) return null;
    if (number == '9876543210') {
      return const AppSession(
        userId: 'PAR-DEMO',
        name: 'Anita Thorne',
        mobile: '9876543210',
        role: AppUserRole.parent,
      );
    }
    if (number == '9876510001') {
      return const AppSession(
        userId: 'TCH-001',
        name: 'Dr. Anita Rao',
        mobile: '9876510001',
        role: AppUserRole.teacher,
      );
    }
    if (number == '9876510002') {
      return const AppSession(
        userId: 'DIR-001',
        name: 'Dr. Rajesh Varma',
        mobile: '9876510002',
        role: AppUserRole.director,
      );
    }
    return null;
  }

  @override
  Future<LeadershipSnapshot> loadLeadershipHome(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const LeadershipSnapshot(
      profile: LeadershipProfile(
        id: 'DIR-001',
        name: 'Dr. Rajesh Varma',
        designation: 'Principal & Director',
        mobile: '9876510002',
        schoolName: 'Orison International School',
        campus: 'Main Campus',
      ),
      schoolHealth: 86,
      totalStudents: 1284,
      totalStaff: 96,
      studentAttendance: 92.8,
      staffAttendance: 94.6,
      collectedToday: 286500,
      outstandingFees: 703000,
      admissionConversion: 68.4,
      academicRiskStudents: 24,
      transportOnTime: 91.7,
      pendingApprovals: 6,
      alerts: [
        LeadershipAlert(
          id: 'ALERT-ACA-01',
          title: 'Grade 10-C needs academic intervention',
          detail: '12 students are below the support threshold in Science.',
          domain: 'Academics',
          severity: 'High',
          actionLabel: 'Review intervention',
        ),
        LeadershipAlert(
          id: 'ALERT-FEE-01',
          title: '₹7.03L remains outstanding',
          detail: '86 accounts crossed the current fee due date.',
          domain: 'Finance',
          severity: 'High',
          actionLabel: 'Open collection plan',
        ),
        LeadershipAlert(
          id: 'ALERT-BUS-01',
          title: 'Route 7 running 18 minutes late',
          detail: 'Parents were notified; operations response is pending.',
          domain: 'Transport',
          severity: 'Medium',
          actionLabel: 'View live route',
        ),
        LeadershipAlert(
          id: 'ALERT-HR-01',
          title: 'Substitute teacher required',
          detail: 'Two approved staff leaves overlap tomorrow morning.',
          domain: 'Staff',
          severity: 'Medium',
          actionLabel: 'Review allocation',
        ),
        LeadershipAlert(
          id: 'ALERT-ADM-01',
          title: '6 admission leads crossed 48 hours',
          detail: 'No counsellor follow-up is recorded for these inquiries.',
          domain: 'Admissions',
          severity: 'Medium',
          actionLabel: 'Review lead ownership',
        ),
        LeadershipAlert(
          id: 'ALERT-SVC-01',
          title: '2 parent concerns crossed response SLA',
          detail: 'Both cases are escalated and await service-owner closure.',
          domain: 'Service',
          severity: 'High',
          actionLabel: 'Open escalations',
        ),
      ],
      approvals: [
        LeadershipApproval(
          id: 'APR-001',
          type: 'Fee structure',
          title: 'Grade 11 tuition fee revision',
          subtitle: 'Locked fee structure · Academic year 2026–27',
          submittedBy: 'Accounts Office · Meera Shah',
          timeLabel: '42 min ago',
          status: 'Pending',
          amount: 360000,
          risk: 'High',
          reason:
              'Revised laboratory and digital learning costs were approved in the annual budget.',
          impact: '120 students · ₹3.60L annual collection impact',
          currentValue: '₹42,000 per student',
          proposedValue: '₹45,000 per student',
          policyTrigger: 'Locked fee structure change · Director approval',
          dueLabel: 'Decision due today',
          attachmentCount: 2,
        ),
        LeadershipApproval(
          id: 'APR-002',
          type: 'Academic year',
          title: 'Activate academic year 2027–28',
          subtitle: 'Structural calendar change affecting all modules',
          submittedBy: 'ERP Administrator · Arun Kumar',
          timeLabel: '1 hour ago',
          status: 'Pending',
          risk: 'Critical',
          reason: 'Academic planning and admissions have opened for 2027–28.',
          impact:
              'Affects fees, attendance, exams, timetable and 1,284 student records',
          currentValue: 'Active: 2026–27',
          proposedValue: 'Activate: 2027–28',
          policyTrigger: 'Locked academic year · Principal/Director approval',
          dueLabel: 'Review before 5:00 PM',
          attachmentCount: 1,
        ),
        LeadershipApproval(
          id: 'APR-003',
          type: 'Fee concession',
          title: 'Sibling concession request',
          subtitle: 'Grade 8-A and Grade 5-B',
          submittedBy: 'Accounts Office',
          timeLabel: '2 hours ago',
          status: 'Pending',
          amount: 12000,
          risk: 'Medium',
          reason: 'Eligible sibling concession was missed during admission.',
          impact: '₹12,000 reduction in current-year receivable',
          currentValue: 'No concession',
          proposedValue: '10% sibling concession',
          policyTrigger: 'Fee concession above finance-manager authority',
          dueLabel: 'Due tomorrow',
          attachmentCount: 3,
        ),
        LeadershipApproval(
          id: 'APR-004',
          type: 'Purchase',
          title: 'Physics laboratory equipment',
          subtitle: '12 optical benches and safety accessories',
          submittedBy: 'Purchase Committee',
          timeLabel: 'Yesterday',
          status: 'Pending',
          amount: 78500,
          risk: 'Medium',
          reason: 'Replacement required before the practical examination.',
          impact: 'Supports 168 senior-school students',
          currentValue: 'Approved vendor quote: ₹78,500',
          proposedValue: 'Release purchase order',
          policyTrigger: 'Purchase exceeds ₹50,000 Director threshold',
          dueLabel: 'Due in 2 days',
          attachmentCount: 4,
        ),
        LeadershipApproval(
          id: 'APR-005',
          type: 'Staff leave',
          title: 'Senior coordinator medical leave',
          subtitle: '8 working days · substitution plan attached',
          submittedBy: 'HR Office · Ms. Priya Shah',
          timeLabel: 'Yesterday',
          status: 'Pending',
          risk: 'High',
          reason: 'Medical recovery advised by treating hospital.',
          impact:
              'Impacts Grade 9–12 coordination; deputy assigned temporarily',
          currentValue: 'Leave balance: 11 days',
          proposedValue: '8 days paid medical leave',
          policyTrigger: 'Leadership staff leave longer than 5 days',
          dueLabel: 'Decision due today',
          attachmentCount: 2,
        ),
        LeadershipApproval(
          id: 'APR-006',
          type: 'Admission exception',
          title: 'Grade 6 capacity override',
          subtitle: 'Sibling admission · class currently at approved capacity',
          submittedBy: 'Admissions Head',
          timeLabel: 'Yesterday',
          status: 'Pending',
          risk: 'Medium',
          reason: 'Sibling already studies in Grade 9 at the same campus.',
          impact: 'Section B strength changes from 40 to 41',
          currentValue: '40 / 40 seats occupied',
          proposedValue: 'Approve one additional seat',
          policyTrigger: 'Admission capacity exception',
          dueLabel: 'Offer expires tomorrow',
          attachmentCount: 1,
        ),
      ],
      academics: [
        AcademicClassInsight(
          className: 'Grade 12',
          passPercentage: 96.4,
          average: 84.2,
          supportStudents: 4,
          topSubject: 'Computer Science',
          weakSubject: 'Chemistry',
          trend: 3.8,
        ),
        AcademicClassInsight(
          className: 'Grade 11',
          passPercentage: 91.7,
          average: 79.8,
          supportStudents: 8,
          topSubject: 'Mathematics',
          weakSubject: 'English',
          trend: 1.2,
        ),
        AcademicClassInsight(
          className: 'Grade 10',
          passPercentage: 86.1,
          average: 74.6,
          supportStudents: 12,
          topSubject: 'Social Studies',
          weakSubject: 'Science',
          trend: -2.4,
        ),
      ],
      teacherPerformance: [
        LeadershipTeacherPerformance(
          name: 'Dr. Anita Rao',
          subject: 'Physics',
          classes: 'Grades 11 & 12',
          studentAverage: 86.8,
          resultGrowth: 7.4,
          lessonPlanCompletion: 96,
          studentSupportClosure: 92,
          rating: 4.8,
          signal: 'Exceptional impact',
        ),
        LeadershipTeacherPerformance(
          name: 'Mr. Arjun Mehta',
          subject: 'Mathematics',
          classes: 'Grades 9 & 10',
          studentAverage: 82.1,
          resultGrowth: 4.9,
          lessonPlanCompletion: 94,
          studentSupportClosure: 88,
          rating: 4.6,
          signal: 'Strong performer',
        ),
        LeadershipTeacherPerformance(
          name: 'Ms. Nisha Kapoor',
          subject: 'English',
          classes: 'Grades 10 & 11',
          studentAverage: 74.2,
          resultGrowth: -1.8,
          lessonPlanCompletion: 81,
          studentSupportClosure: 63,
          rating: 4.1,
          signal: 'Coaching recommended',
        ),
        LeadershipTeacherPerformance(
          name: 'Mr. Rohan Sen',
          subject: 'Chemistry',
          classes: 'Grades 11 & 12',
          studentAverage: 71.6,
          resultGrowth: -3.2,
          lessonPlanCompletion: 76,
          studentSupportClosure: 58,
          rating: 3.9,
          signal: 'Needs intervention',
        ),
      ],
      studentPerformance: [
        LeadershipStudentPerformance(
          name: 'Aarav Sharma',
          className: 'Grade 12-A',
          average: 94.6,
          change: 5.8,
          strongestSubject: 'Computer Science',
          supportSubject: 'Chemistry',
          attendance: 96.2,
          signal: 'Top performer',
        ),
        LeadershipStudentPerformance(
          name: 'Diya Reddy',
          className: 'Grade 11-B',
          average: 88.4,
          change: 9.2,
          strongestSubject: 'Mathematics',
          supportSubject: 'English',
          attendance: 94.8,
          signal: 'Most improved',
        ),
        LeadershipStudentPerformance(
          name: 'Kabir Malhotra',
          className: 'Grade 10-C',
          average: 61.7,
          change: -8.4,
          strongestSubject: 'Social Studies',
          supportSubject: 'Science',
          attendance: 82.3,
          signal: 'Immediate support',
        ),
        LeadershipStudentPerformance(
          name: 'Sara Thomas',
          className: 'Grade 10-C',
          average: 67.9,
          change: -4.1,
          strongestSubject: 'English',
          supportSubject: 'Mathematics',
          attendance: 89.1,
          signal: 'Monitor closely',
        ),
      ],
      improvedStudentCount: 318,
      attentionStudentCount: 219,
      topPerformerCount: 164,
      attendanceDivisions: [
        AttendanceDivision(
          label: 'Senior School',
          studentsPresent: 398,
          totalStudents: 425,
          staffPresent: 31,
          totalStaff: 33,
        ),
        AttendanceDivision(
          label: 'Middle School',
          studentsPresent: 421,
          totalStudents: 452,
          staffPresent: 29,
          totalStaff: 31,
        ),
        AttendanceDivision(
          label: 'Primary School',
          studentsPresent: 373,
          totalStudents: 407,
          staffPresent: 30,
          totalStaff: 32,
        ),
      ],
      events: [
        LeadershipCalendarEvent(
          title: 'Academic review council',
          time: '10:30 AM',
          location: 'Conference Hall',
          category: 'Meeting',
        ),
        LeadershipCalendarEvent(
          title: 'Parent representatives meeting',
          time: '12:15 PM',
          location: 'Principal Office',
          category: 'Parents',
        ),
        LeadershipCalendarEvent(
          title: 'New faculty interviews',
          time: '03:00 PM',
          location: 'Board Room',
          category: 'HR',
        ),
      ],
      admissionFunnel: {
        'Inquiries': 428,
        'Applications': 286,
        'Assessments': 221,
        'Offers': 184,
        'Admissions': 153,
      },
      syllabusUnitsBehind: 3,
      openInterventions: 14,
      staleAdmissionLeads: 6,
      overdueFeeAccounts: 86,
      criticalParentTickets: 2,
      delayedRoutes: 1,
      substitutionGaps: 2,
      securityIncidents: 0,
      collectionProgress: 87.2,
      branches: [
        LeadershipBranchInsight(
          name: 'Main Campus',
          health: 89,
          attendance: 93.6,
          collectionProgress: 91.4,
          academicRisk: 10,
          openAlerts: 2,
        ),
        LeadershipBranchInsight(
          name: 'North Campus',
          health: 82,
          attendance: 91.2,
          collectionProgress: 84.8,
          academicRisk: 9,
          openAlerts: 3,
        ),
        LeadershipBranchInsight(
          name: 'Junior Campus',
          health: 86,
          attendance: 94.1,
          collectionProgress: 85.3,
          academicRisk: 5,
          openAlerts: 1,
        ),
      ],
    );
  }

  @override
  Future<bool> decideLeadershipApproval(
      String approvalId, String decision) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return approvalId.isNotEmpty &&
        (decision == 'Approved' ||
            decision == 'Rejected' ||
            decision == 'Needs changes');
  }

  @override
  Future<bool> resolveLeadershipAlert(String alertId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return alertId.isNotEmpty;
  }

  @override
  Future<bool> publishLeadershipAnnouncement(
      String title, String audience) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return title.trim().isNotEmpty && audience.isNotEmpty;
  }

  @override
  Future<bool> verifyOtp(String mobile, String otp) async {
    return (await authenticateWithOtp(mobile, otp)) != null;
  }

  @override
  Future<TeacherSnapshot> loadTeacherHome(String teacherId) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return TeacherSnapshot(
      profile: const TeacherProfile(
        id: 'TCH-001',
        name: 'Dr. Anita Rao',
        mobile: '9876510001',
        designation: 'Senior Physics Teacher',
        department: 'Science Department',
        employeeId: 'ORI-T-001',
        classTeacherOf: 'Grade 11 · Section B',
      ),
      classes: const [
        TeacherClass(
          id: 'class-11-b-physics',
          className: 'Grade 11',
          section: 'Section B',
          subjects: ['Physics', 'Mathematics'],
          studentCount: 32,
          room: 'Room 304',
          average: 84.6,
          attendanceMarked: false,
          canTakeAttendance: true,
        ),
        TeacherClass(
          id: 'class-12-a-physics',
          className: 'Grade 12',
          section: 'Section A',
          subjects: ['Physics'],
          studentCount: 29,
          room: 'Physics Lab',
          average: 81.2,
          attendanceMarked: false,
          canTakeAttendance: false,
        ),
        TeacherClass(
          id: 'class-10-c-science',
          className: 'Grade 10',
          section: 'Section C',
          subjects: ['Science', 'Environmental Studies'],
          studentCount: 34,
          room: 'Room 208',
          average: 78.9,
          attendanceMarked: false,
          canTakeAttendance: false,
        ),
      ],
      periods: const [
        TeacherPeriod(
          id: 'period-1',
          period: 1,
          classLabel: 'Grade 11 · Section B',
          subject: 'Physics',
          startTime: '08:40 AM',
          endTime: '09:25 AM',
          room: 'Room 304',
          status: 'Completed',
          weekday: DateTime.wednesday,
          classId: 'class-11-b-physics',
        ),
        TeacherPeriod(
          id: 'period-2',
          period: 3,
          classLabel: 'Grade 12 · Section A',
          subject: 'Physics',
          startTime: '10:30 AM',
          endTime: '11:15 AM',
          room: 'Physics Lab',
          status: 'Next class',
          weekday: DateTime.wednesday,
          classId: 'class-12-a-physics',
        ),
        TeacherPeriod(
          id: 'period-3',
          period: 5,
          classLabel: 'Grade 10 · Section C',
          subject: 'Science',
          startTime: '12:20 PM',
          endTime: '01:05 PM',
          room: 'Room 208',
          status: 'Upcoming',
          weekday: DateTime.wednesday,
          classId: 'class-10-c-science',
        ),
        TeacherPeriod(
          id: 'period-4',
          period: 7,
          classLabel: 'Grade 11 · Section B',
          subject: 'Physics practical',
          startTime: '02:00 PM',
          endTime: '02:45 PM',
          room: 'Physics Lab',
          status: 'Upcoming',
          weekday: DateTime.wednesday,
          classId: 'class-11-b-physics',
        ),
        TeacherPeriod(
          id: 'period-mon-1',
          period: 1,
          classLabel: 'Grade 10 · Section C',
          subject: 'Environmental Studies',
          startTime: '08:40 AM',
          endTime: '09:25 AM',
          room: 'Room 208',
          status: 'Scheduled',
          weekday: DateTime.monday,
          classId: 'class-10-c-science',
        ),
        TeacherPeriod(
          id: 'period-mon-2',
          period: 4,
          classLabel: 'Grade 11 · Section B',
          subject: 'Mathematics',
          startTime: '11:15 AM',
          endTime: '12:00 PM',
          room: 'Room 304',
          status: 'Scheduled',
          weekday: DateTime.monday,
          classId: 'class-11-b-physics',
        ),
        TeacherPeriod(
          id: 'period-tue-1',
          period: 2,
          classLabel: 'Grade 12 · Section A',
          subject: 'Physics',
          startTime: '09:25 AM',
          endTime: '10:10 AM',
          room: 'Physics Lab',
          status: 'Scheduled',
          weekday: DateTime.tuesday,
          classId: 'class-12-a-physics',
        ),
        TeacherPeriod(
          id: 'period-thu-1',
          period: 3,
          classLabel: 'Grade 11 · Section B',
          subject: 'Physics',
          startTime: '10:30 AM',
          endTime: '11:15 AM',
          room: 'Room 304',
          status: 'Scheduled',
          weekday: DateTime.thursday,
          classId: 'class-11-b-physics',
        ),
        TeacherPeriod(
          id: 'period-thu-2',
          period: 6,
          classLabel: 'Grade 10 · Section C',
          subject: 'Science',
          startTime: '01:15 PM',
          endTime: '02:00 PM',
          room: 'Science Lab',
          status: 'Scheduled',
          weekday: DateTime.thursday,
          classId: 'class-10-c-science',
        ),
        TeacherPeriod(
          id: 'period-fri-1',
          period: 2,
          classLabel: 'Grade 11 · Section B',
          subject: 'Mathematics',
          startTime: '09:25 AM',
          endTime: '10:10 AM',
          room: 'Room 304',
          status: 'Scheduled',
          weekday: DateTime.friday,
          classId: 'class-11-b-physics',
        ),
      ],
      tasks: const [
        TeacherTask(
          id: 'task-attendance-12a',
          title: 'Mark Grade 11-B attendance',
          subtitle: '32 students · First-period responsibility',
          category: 'Attendance',
          dueLabel: 'Before 11:30 AM',
          priority: 'Urgent',
        ),
        TeacherTask(
          id: 'task-plan-11b',
          title: 'Complete today’s lesson plan',
          subtitle: 'Grade 11-B · Laws of Motion',
          category: 'Lesson plan',
          dueLabel: 'After Period 1',
          priority: 'High',
        ),
        TeacherTask(
          id: 'task-homework-review',
          title: 'Review homework completion',
          subtitle: '12 parent updates received',
          category: 'Homework',
          dueLabel: 'Today',
          priority: 'Normal',
        ),
        TeacherTask(
          id: 'task-lesson-plan',
          title: 'Upload optics lesson plan',
          subtitle: 'Grade 12-A · Chapter 9',
          category: 'Lesson plan',
          dueLabel: 'Due tomorrow',
          priority: 'Normal',
        ),
      ],
      notices: const [
        TeacherNotice(
          id: 'teacher-notice-1',
          title: 'Staff briefing at 3:30 PM',
          body: 'Academic review meeting in the Conference Hall.',
          timeLabel: '1 hour ago',
          priority: 'Important',
        ),
        TeacherNotice(
          id: 'teacher-notice-2',
          title: 'Unit Test III dates confirmed',
          body: 'Question papers must be submitted before 25 August.',
          timeLabel: 'Yesterday',
          priority: 'Normal',
        ),
      ],
      students: const [
        TeacherStudent(
          id: 'EP-2024-0812',
          name: 'Marcus Thorne',
          roll: '042',
          performance: 91.0,
          attendance: 91.3,
          status: 'Improving',
          classId: 'class-11-b-physics',
          subjectScores: {'Physics': 91, 'Mathematics': 86},
        ),
        TeacherStudent(
          id: 'STU-11B-02',
          name: 'Aarav Sharma',
          roll: '018',
          performance: 86.0,
          attendance: 94.0,
          status: 'Strong',
          classId: 'class-11-b-physics',
          subjectScores: {'Physics': 88, 'Mathematics': 84},
        ),
        TeacherStudent(
          id: 'STU-11B-03',
          name: 'Sara Khan',
          roll: '027',
          performance: 62.0,
          attendance: 73.0,
          status: 'Needs support',
          classId: 'class-11-b-physics',
          subjectScores: {'Physics': 58, 'Mathematics': 61},
        ),
        TeacherStudent(
          id: 'STU-11B-04',
          name: 'Rohan Mehta',
          roll: '031',
          performance: 78.0,
          attendance: 88.0,
          status: 'Steady',
          classId: 'class-11-b-physics',
          subjectScores: {'Physics': 78, 'Mathematics': 76},
        ),
        TeacherStudent(
          id: 'STU-12A-01',
          name: 'Ishaan Verma',
          roll: '006',
          performance: 59,
          attendance: 81,
          status: 'Needs support',
          classId: 'class-12-a-physics',
          subjectScores: {'Physics': 59},
        ),
        TeacherStudent(
          id: 'STU-12A-02',
          name: 'Meera Iyer',
          roll: '014',
          performance: 92,
          attendance: 96,
          status: 'Strong',
          classId: 'class-12-a-physics',
          subjectScores: {'Physics': 92},
        ),
        TeacherStudent(
          id: 'STU-10C-01',
          name: 'Dev Patel',
          roll: '009',
          performance: 55,
          attendance: 72,
          status: 'Needs support',
          classId: 'class-10-c-science',
          subjectScores: {'Science': 55, 'Environmental Studies': 64},
        ),
        TeacherStudent(
          id: 'STU-10C-02',
          name: 'Naina Bose',
          roll: '021',
          performance: 60,
          attendance: 77,
          status: 'Needs support',
          classId: 'class-10-c-science',
          subjectScores: {'Science': 60, 'Environmental Studies': 58},
        ),
        TeacherStudent(
          id: 'STU-10C-03',
          name: 'Kabir Singh',
          roll: '028',
          performance: 82,
          attendance: 91,
          status: 'Steady',
          classId: 'class-10-c-science',
          subjectScores: {'Science': 82, 'Environmental Studies': 85},
        ),
      ],
      lessonPlans: [
        TeacherLessonPlan(
          id: 'LP-101',
          classId: 'class-11-b-physics',
          classLabel: 'Grade 11 · Section B',
          subject: 'Physics',
          lesson: 'Laws of Motion · Applications',
          objective: 'Apply Newton’s laws to real-world force diagrams.',
          startDate: DateTime(2026, 8, 19),
          endDate: DateTime(2026, 8, 19),
          periodLabel: 'Period 1 · 08:40 AM',
          status: 'Today',
        ),
        TeacherLessonPlan(
          id: 'LP-102',
          classId: 'class-12-a-physics',
          classLabel: 'Grade 12 · Section A',
          subject: 'Physics',
          lesson: 'Ray Optics · Lens formula',
          objective: 'Derive the lens formula and solve numerical problems.',
          startDate: DateTime(2026, 8, 19),
          endDate: DateTime(2026, 8, 21),
          periodLabel: 'Period 3 · 10:30 AM',
          status: 'In progress',
        ),
        TeacherLessonPlan(
          id: 'LP-103',
          classId: 'class-10-c-science',
          classLabel: 'Grade 10 · Section C',
          subject: 'Science',
          lesson: 'Human eye and colourful world',
          objective: 'Explain accommodation, defects and corrections.',
          startDate: DateTime(2026, 8, 20),
          endDate: DateTime(2026, 8, 24),
          periodLabel: 'Period 6 · 01:15 PM',
          status: 'Upcoming',
        ),
      ],
      leaveRequests: [
        TeacherLeaveRequest(
          id: 'TL-260812',
          type: 'Casual leave',
          from: DateTime(2026, 8, 12),
          to: DateTime(2026, 8, 12),
          reason: 'Personal appointment',
          status: 'Approved',
        ),
      ],
    );
  }

  @override
  Future<bool> submitTeacherAttendance({
    required String classId,
    required DateTime date,
    required Map<String, String> statuses,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));
    final today = DateTime.now();
    final selected = DateTime(date.year, date.month, date.day);
    final current = DateTime(today.year, today.month, today.day);
    final validStatuses = statuses.values
        .every((status) => status == 'Present' || status == 'Absent');
    return classId == 'class-11-b-physics' &&
        !selected.isAfter(current) &&
        statuses.isNotEmpty &&
        validStatuses;
  }

  @override
  Future<bool> assignTeacherHomework({
    required String classId,
    required String subject,
    required String title,
    required String instructions,
    required DateTime dueDate,
    required List<String> attachmentNames,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));
    return classId.isNotEmpty && subject.isNotEmpty && title.trim().isNotEmpty;
  }

  @override
  Future<bool> completeTeacherLessonPlan(String planId) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return planId.isNotEmpty;
  }

  @override
  Future<bool> applyTeacherLeave(TeacherLeaveRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return request.type.isNotEmpty && !request.to.isBefore(request.from);
  }

  @override
  Future<ParentSnapshot> loadParentHome() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return ParentSnapshot(
      students: const [
        Student(
            id: 'EP-2024-0812',
            name: 'Marcus Thorne',
            className: 'Grade 11 · Section B',
            roll: '042',
            balance: 11450),
        Student(
            id: 'EP-2024-0790',
            name: 'Benjamin Thorne',
            className: 'Grade 10 · Section A',
            roll: '012',
            balance: 0),
      ],
      attendance: [
        AttendanceRecord(
            DateTime(2025, 7, 31), 'Present', '08:14 AM', '02:30 PM'),
        AttendanceRecord(
            DateTime(2025, 7, 30), 'Present', '08:10 AM', '02:35 PM'),
        AttendanceRecord(
            DateTime(2025, 7, 29), 'Present', '08:15 AM', '02:32 PM'),
        AttendanceRecord(DateTime(2025, 7, 25), 'Absent', '—', '—'),
      ],
      grades: const [
        Grade('Mathematics', 22, 74, 96, 'A+'),
        Grade('Science', 24, 71, 95, 'A+'),
        Grade('English', 19, 68, 87, 'A'),
        Grade('Hindi', 20, 65, 85, 'A'),
        Grade('Social Studies', 21, 70, 91, 'A+'),
        Grade('Computer Science', 25, 72, 97, 'A+'),
      ],
      fees: [
        FeeItem(
          'fee-past-1',
          'Tuition Fee · Final instalment',
          DateTime(2026, 3, 15),
          12500,
          'Overdue',
          academicYear: '2025–26',
          paidAmount: 10500,
        ),
        FeeItem(
          'fee-past-2',
          'Annual & activities fee',
          DateTime(2025, 6, 10),
          3500,
          'Paid',
          academicYear: '2025–26',
          paidAmount: 3500,
          transactionId: 'ORP25061083',
          paidOn: DateTime(2025, 6, 10),
          receiptAmount: 3500,
        ),
        FeeItem(
          'fee-current-1',
          'Tuition Fee · Term I',
          DateTime(2026, 6, 15),
          18000,
          'Paid',
          academicYear: '2026–27',
          paidAmount: 18000,
          transactionId: 'ORP26061542',
          paidOn: DateTime(2026, 6, 15),
          receiptAmount: 18000,
        ),
        FeeItem(
          'fee-current-2',
          'Tuition Fee · Term II',
          DateTime(2026, 10, 15),
          8000,
          'Pending',
          academicYear: '2026–27',
        ),
        FeeItem(
          'fee-current-3',
          'Co-curricular activities',
          DateTime(2026, 9, 5),
          1450,
          'Pending',
          academicYear: '2026–27',
        ),
      ],
      homework: [
        Homework(
          id: 'hw-math-72',
          subject: 'Mathematics',
          title: 'Complete exercise 7.2',
          instructions:
              'Solve questions 1–12 and show every calculation step in the class notebook.',
          assignedDate: DateTime.now().subtract(const Duration(days: 1)),
          dueDate: DateTime.now().add(const Duration(days: 1)),
          teacher: 'Ms. Rao',
          completed: _homeworkStatuses['hw-math-72']!,
        ),
        Homework(
          id: 'hw-science-heart',
          subject: 'Science',
          title: 'Label the human heart diagram',
          instructions:
              'Draw a neat diagram, label all chambers and write two lines about blood flow.',
          assignedDate: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 2)),
          teacher: 'Mr. Sharma',
          completed: _homeworkStatuses['hw-science-heart']!,
        ),
        Homework(
          id: 'hw-english-ch6',
          subject: 'English',
          title: 'Read chapter 6 and summarize',
          instructions:
              'Write a 150-word summary and list five new vocabulary words with meanings.',
          assignedDate: DateTime.now().subtract(const Duration(days: 3)),
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
          teacher: 'Ms. Wilson',
          completed: _homeworkStatuses['hw-english-ch6']!,
          statusUpdatedAt: DateTime.now().subtract(const Duration(hours: 8)),
        ),
        Homework(
          id: 'hw-social-map',
          subject: 'Social Studies',
          title: 'Mark major rivers on the India map',
          instructions:
              'Use the outline map provided in class and include a colour-coded legend.',
          assignedDate: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 4)),
          teacher: 'Ms. Khan',
          completed: _homeworkStatuses['hw-social-map']!,
        ),
      ],
      leaveRequests: List<LeaveRequest>.unmodifiable(_leaveRequests),
      helpRequests: List<HelpRequest>.unmodifiable(_helpRequests),
      notices: [
        Notice(
          id: 'notice-ptm',
          title: 'Parent–Teacher Meeting this Saturday',
          body:
              'The Parent–Teacher Meeting for Grade 11 is scheduled this Saturday from 9:00 AM to 12:30 PM. Parents may meet all subject teachers in the Senior Wing. Please carry the student diary and arrive ten minutes before your selected slot.',
          time: DateTime.now().subtract(const Duration(hours: 2)),
          category: 'Events',
          priority: 'Urgent',
          issuer: 'Academic Coordinator',
          unread: !_readNoticeIds.contains('notice-ptm'),
          attachmentName: 'PTM-time-slots.pdf',
        ),
        Notice(
          id: 'notice-fee',
          title: 'Tuition fee payment reminder',
          body:
              'A previous academic-year tuition instalment remains outstanding. Please clear the due amount through the Fees section to avoid interruption to hall-ticket generation and other academic services.',
          time: DateTime.now().subtract(const Duration(days: 1)),
          category: 'Fees',
          priority: 'Important',
          issuer: 'Accounts Office',
          unread: !_readNoticeIds.contains('notice-fee'),
          attachmentName: 'fee-reminder.pdf',
        ),
        Notice(
          id: 'notice-bus',
          title: 'Route 12 morning timing updated',
          body:
              'Due to road maintenance near Jubilee Hills, Route 12 will begin ten minutes earlier tomorrow. Marcus’s revised pickup time at Central Park Stop is 7:08 AM. Live tracking will be available in the Transport section.',
          time: DateTime.now().subtract(const Duration(days: 2)),
          category: 'Transport',
          priority: 'Important',
          issuer: 'Transport Department',
          unread: !_readNoticeIds.contains('notice-bus'),
        ),
        Notice(
          id: 'notice-exam',
          title: 'Unit Test III timetable published',
          body:
              'The subject-wise timetable for Unit Test III has been published. Examinations begin on 18 September 2026. Parents can review the complete schedule from Exams or Hall Tickets.',
          time: DateTime.now().subtract(const Duration(days: 3)),
          category: 'Academics',
          priority: 'Normal',
          issuer: 'Examination Cell',
          unread: !_readNoticeIds.contains('notice-exam'),
          attachmentName: 'unit-test-III-timetable.pdf',
        ),
        Notice(
          id: 'notice-club',
          title: 'Inter-school science exhibition registrations',
          body:
              'Registrations are open for the annual inter-school science exhibition. Interested students should submit their project abstract to the Science Department by 28 August.',
          time: DateTime.now().subtract(const Duration(days: 5)),
          category: 'Events',
          priority: 'Normal',
          issuer: 'Science Department',
          unread: !_readNoticeIds.contains('notice-club'),
        ),
        Notice(
          id: 'notice-holiday',
          title: 'School holiday circular',
          body:
              'The school will remain closed on the notified public holiday. Regular classes and transport services resume on the next working day.',
          time: DateTime.now().subtract(const Duration(days: 8)),
          category: 'General',
          priority: 'Normal',
          issuer: 'School Office',
          unread: !_readNoticeIds.contains('notice-holiday'),
          attachmentName: 'holiday-circular.pdf',
        ),
      ],
      profile: _profile,
    );
  }

  @override
  Future<ParentProfile> updateProfile(ParentProfile profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _profile = profile;
    return _profile;
  }

  @override
  Future<LeaveRequest> applyLeave({
    required String studentId,
    required DateTime from,
    required DateTime to,
    required String type,
    required String description,
    String? attachmentName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final request = LeaveRequest(
      id: 'leave-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      from: from,
      to: to,
      description: description,
      status: 'Pending',
      appliedOn: DateTime.now(),
      attachmentName: attachmentName,
    );
    _leaveRequests.insert(0, request);
    return request;
  }

  @override
  Future<void> initiateFeePayment(String feeId) =>
      Future<void>.delayed(const Duration(milliseconds: 500));

  @override
  Future<bool> submitFeePaymentProof({
    required String feeId,
    required double amount,
    required String transactionId,
    required String proofName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return feeId.isNotEmpty &&
        amount > 0 &&
        transactionId.trim().length >= 8 &&
        proofName.isNotEmpty;
  }

  @override
  Future<bool> updateHomeworkStatus({
    required String studentId,
    required String homeworkId,
    required bool completed,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (studentId.isEmpty || !_homeworkStatuses.containsKey(homeworkId)) {
      return false;
    }
    _homeworkStatuses[homeworkId] = completed;
    return true;
  }

  @override
  Future<bool> markNoticeRead(String noticeId) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (noticeId.isEmpty) return false;
    _readNoticeIds.add(noticeId);
    return true;
  }

  @override
  Future<HelpRequest> submitHelpRequest({
    required String studentId,
    required String kind,
    required String category,
    required String description,
    required String priority,
    String? preferredTime,
    String? attachmentName,
    String? parentName,
    String? studentName,
    String? mobile,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final prefix = kind == 'School callback' ? 'CB' : 'APP';
    final request = HelpRequest(
      id: '$prefix-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      kind: kind,
      category: category,
      description: description,
      status: kind == 'School callback' ? 'Pending callback' : 'Open',
      createdAt: DateTime.now(),
      priority: priority,
      preferredTime: preferredTime,
      attachmentName: attachmentName,
      parentName: parentName,
      studentName: studentName,
      mobile: mobile,
    );
    _helpRequests.insert(0, request);
    return request;
  }
}

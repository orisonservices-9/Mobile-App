import '../models/models.dart';

abstract class OrisonRepository {
  Future<bool> verifyOtp(String mobile, String otp);
  Future<ParentSnapshot> loadParentHome();
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
  Future<bool> verifyOtp(String mobile, String otp) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return mobile.length == 10 && otp.length == 4;
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

import 'package:equatable/equatable.dart';

class Student extends Equatable {
  const Student(
      {required this.id,
      required this.name,
      required this.className,
      required this.roll,
      required this.balance});
  final String id;
  final String name;
  final String className;
  final String roll;
  final double balance;
  @override
  List<Object?> get props => [id, name, className, roll, balance];
}

class AttendanceRecord extends Equatable {
  const AttendanceRecord(this.date, this.status, this.checkIn, this.checkOut);
  final DateTime date;
  final String status;
  final String checkIn;
  final String checkOut;
  @override
  List<Object?> get props => [date, status, checkIn, checkOut];
}

class Grade extends Equatable {
  const Grade(
      this.subject, this.internal, this.external, this.total, this.grade);
  final String subject;
  final int internal;
  final int external;
  final int total;
  final String grade;
  @override
  List<Object?> get props => [subject, internal, external, total, grade];
}

class FeeItem extends Equatable {
  const FeeItem(
    this.id,
    this.title,
    this.dueDate,
    this.amount,
    this.status, {
    required this.academicYear,
    this.paidAmount = 0,
    this.transactionId,
    this.paidOn,
    this.receiptAmount,
  });
  final String id;
  final String title;
  final DateTime dueDate;
  final double amount;
  final String status;
  final String academicYear;
  final double paidAmount;
  final String? transactionId;
  final DateTime? paidOn;
  final double? receiptAmount;

  double get balance => (amount - paidAmount).clamp(0, amount);

  FeeItem copyWith({
    String? status,
    double? paidAmount,
    String? transactionId,
    DateTime? paidOn,
    double? receiptAmount,
  }) =>
      FeeItem(
        id,
        title,
        dueDate,
        amount,
        status ?? this.status,
        academicYear: academicYear,
        paidAmount: paidAmount ?? this.paidAmount,
        transactionId: transactionId ?? this.transactionId,
        paidOn: paidOn ?? this.paidOn,
        receiptAmount: receiptAmount ?? this.receiptAmount,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        dueDate,
        amount,
        status,
        academicYear,
        paidAmount,
        transactionId,
        paidOn,
        receiptAmount,
      ];
}

class Homework extends Equatable {
  const Homework({
    required this.id,
    required this.subject,
    required this.title,
    required this.instructions,
    required this.assignedDate,
    required this.dueDate,
    required this.teacher,
    required this.completed,
    this.statusUpdatedAt,
  });
  final String id;
  final String subject;
  final String title;
  final String instructions;
  final DateTime assignedDate;
  final DateTime dueDate;
  final String teacher;
  final bool completed;
  final DateTime? statusUpdatedAt;

  Homework copyWith({bool? completed, DateTime? statusUpdatedAt}) => Homework(
        id: id,
        subject: subject,
        title: title,
        instructions: instructions,
        assignedDate: assignedDate,
        dueDate: dueDate,
        teacher: teacher,
        completed: completed ?? this.completed,
        statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      );

  @override
  List<Object?> get props => [
        id,
        subject,
        title,
        instructions,
        assignedDate,
        dueDate,
        teacher,
        completed,
        statusUpdatedAt,
      ];
}

class Notice extends Equatable {
  const Notice({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.category,
    required this.priority,
    required this.issuer,
    this.unread = false,
    this.attachmentName,
  });
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final String category;
  final String priority;
  final String issuer;
  final bool unread;
  final String? attachmentName;

  Notice copyWith({bool? unread}) => Notice(
        id: id,
        title: title,
        body: body,
        time: time,
        category: category,
        priority: priority,
        issuer: issuer,
        unread: unread ?? this.unread,
        attachmentName: attachmentName,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        time,
        category,
        priority,
        issuer,
        unread,
        attachmentName,
      ];
}

class LeaveRequest extends Equatable {
  const LeaveRequest({
    required this.id,
    required this.type,
    required this.from,
    required this.to,
    required this.description,
    required this.status,
    required this.appliedOn,
    this.attachmentName,
  });
  final String id;
  final String type;
  final DateTime from;
  final DateTime to;
  final String description;
  final String status;
  final DateTime appliedOn;
  final String? attachmentName;

  int get days => to.difference(from).inDays + 1;

  @override
  List<Object?> get props => [
        id,
        type,
        from,
        to,
        description,
        status,
        appliedOn,
        attachmentName,
      ];
}

class HelpRequest extends Equatable {
  const HelpRequest({
    required this.id,
    required this.kind,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.priority,
    this.preferredTime,
    this.attachmentName,
    this.parentName,
    this.studentName,
    this.mobile,
  });
  final String id;
  final String kind;
  final String category;
  final String description;
  final String status;
  final DateTime createdAt;
  final String priority;
  final String? preferredTime;
  final String? attachmentName;
  final String? parentName;
  final String? studentName;
  final String? mobile;

  @override
  List<Object?> get props => [
        id,
        kind,
        category,
        description,
        status,
        createdAt,
        priority,
        preferredTime,
        attachmentName,
        parentName,
        studentName,
        mobile,
      ];
}

class ParentProfile extends Equatable {
  const ParentProfile({
    required this.name,
    required this.mobile,
    required this.email,
    required this.address,
    required this.relationship,
    required this.occupation,
    required this.alternateMobile,
    required this.emergencyName,
    required this.emergencyMobile,
    required this.preferredLanguage,
    required this.pushNotifications,
    required this.whatsAppUpdates,
    required this.emailUpdates,
  });
  final String name;
  final String mobile;
  final String email;
  final String address;
  final String relationship;
  final String occupation;
  final String alternateMobile;
  final String emergencyName;
  final String emergencyMobile;
  final String preferredLanguage;
  final bool pushNotifications;
  final bool whatsAppUpdates;
  final bool emailUpdates;

  ParentProfile copyWith({
    String? name,
    String? mobile,
    String? email,
    String? address,
    String? relationship,
    String? occupation,
    String? alternateMobile,
    String? emergencyName,
    String? emergencyMobile,
    String? preferredLanguage,
    bool? pushNotifications,
    bool? whatsAppUpdates,
    bool? emailUpdates,
  }) =>
      ParentProfile(
        name: name ?? this.name,
        mobile: mobile ?? this.mobile,
        email: email ?? this.email,
        address: address ?? this.address,
        relationship: relationship ?? this.relationship,
        occupation: occupation ?? this.occupation,
        alternateMobile: alternateMobile ?? this.alternateMobile,
        emergencyName: emergencyName ?? this.emergencyName,
        emergencyMobile: emergencyMobile ?? this.emergencyMobile,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
        pushNotifications: pushNotifications ?? this.pushNotifications,
        whatsAppUpdates: whatsAppUpdates ?? this.whatsAppUpdates,
        emailUpdates: emailUpdates ?? this.emailUpdates,
      );
  @override
  List<Object?> get props => [
        name,
        mobile,
        email,
        address,
        relationship,
        occupation,
        alternateMobile,
        emergencyName,
        emergencyMobile,
        preferredLanguage,
        pushNotifications,
        whatsAppUpdates,
        emailUpdates,
      ];
}

class ParentSnapshot extends Equatable {
  const ParentSnapshot(
      {required this.students,
      required this.attendance,
      required this.grades,
      required this.fees,
      required this.homework,
      required this.leaveRequests,
      required this.helpRequests,
      required this.notices,
      required this.profile});
  final List<Student> students;
  final List<AttendanceRecord> attendance;
  final List<Grade> grades;
  final List<FeeItem> fees;
  final List<Homework> homework;
  final List<LeaveRequest> leaveRequests;
  final List<HelpRequest> helpRequests;
  final List<Notice> notices;
  final ParentProfile profile;
  @override
  List<Object?> get props => [
        students,
        attendance,
        grades,
        fees,
        homework,
        leaveRequests,
        helpRequests,
        notices,
        profile,
      ];
}

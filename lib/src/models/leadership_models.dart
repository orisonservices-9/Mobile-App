import 'package:equatable/equatable.dart';

class LeadershipProfile extends Equatable {
  const LeadershipProfile({
    required this.id,
    required this.name,
    required this.designation,
    required this.mobile,
    required this.schoolName,
    required this.campus,
  });

  final String id;
  final String name;
  final String designation;
  final String mobile;
  final String schoolName;
  final String campus;

  @override
  List<Object?> get props =>
      [id, name, designation, mobile, schoolName, campus];
}

class LeadershipAlert extends Equatable {
  const LeadershipAlert({
    required this.id,
    required this.title,
    required this.detail,
    required this.domain,
    required this.severity,
    required this.actionLabel,
    this.resolved = false,
  });

  final String id;
  final String title;
  final String detail;
  final String domain;
  final String severity;
  final String actionLabel;
  final bool resolved;

  LeadershipAlert copyWith({bool? resolved}) => LeadershipAlert(
        id: id,
        title: title,
        detail: detail,
        domain: domain,
        severity: severity,
        actionLabel: actionLabel,
        resolved: resolved ?? this.resolved,
      );

  @override
  List<Object?> get props =>
      [id, title, detail, domain, severity, actionLabel, resolved];
}

class LeadershipApproval extends Equatable {
  const LeadershipApproval({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.submittedBy,
    required this.timeLabel,
    required this.status,
    this.amount,
    this.risk = 'Medium',
    this.reason = '',
    this.impact = '',
    this.currentValue,
    this.proposedValue,
    this.policyTrigger = '',
    this.dueLabel = 'Today',
    this.attachmentCount = 0,
    this.requiresReauthentication = true,
  });

  final String id;
  final String type;
  final String title;
  final String subtitle;
  final String submittedBy;
  final String timeLabel;
  final String status;
  final double? amount;
  final String risk;
  final String reason;
  final String impact;
  final String? currentValue;
  final String? proposedValue;
  final String policyTrigger;
  final String dueLabel;
  final int attachmentCount;
  final bool requiresReauthentication;

  LeadershipApproval copyWith({String? status}) => LeadershipApproval(
        id: id,
        type: type,
        title: title,
        subtitle: subtitle,
        submittedBy: submittedBy,
        timeLabel: timeLabel,
        status: status ?? this.status,
        amount: amount,
        risk: risk,
        reason: reason,
        impact: impact,
        currentValue: currentValue,
        proposedValue: proposedValue,
        policyTrigger: policyTrigger,
        dueLabel: dueLabel,
        attachmentCount: attachmentCount,
        requiresReauthentication: requiresReauthentication,
      );

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        subtitle,
        submittedBy,
        timeLabel,
        status,
        amount,
        risk,
        reason,
        impact,
        currentValue,
        proposedValue,
        policyTrigger,
        dueLabel,
        attachmentCount,
        requiresReauthentication,
      ];
}

class LeadershipBranchInsight extends Equatable {
  const LeadershipBranchInsight({
    required this.name,
    required this.health,
    required this.attendance,
    required this.collectionProgress,
    required this.academicRisk,
    required this.openAlerts,
  });

  final String name;
  final int health;
  final double attendance;
  final double collectionProgress;
  final int academicRisk;
  final int openAlerts;

  @override
  List<Object?> get props => [
        name,
        health,
        attendance,
        collectionProgress,
        academicRisk,
        openAlerts,
      ];
}

class AcademicClassInsight extends Equatable {
  const AcademicClassInsight({
    required this.className,
    required this.passPercentage,
    required this.average,
    required this.supportStudents,
    required this.topSubject,
    required this.weakSubject,
    required this.trend,
  });

  final String className;
  final double passPercentage;
  final double average;
  final int supportStudents;
  final String topSubject;
  final String weakSubject;
  final double trend;

  @override
  List<Object?> get props => [
        className,
        passPercentage,
        average,
        supportStudents,
        topSubject,
        weakSubject,
        trend,
      ];
}

class LeadershipTeacherPerformance extends Equatable {
  const LeadershipTeacherPerformance({
    required this.name,
    required this.subject,
    required this.classes,
    required this.studentAverage,
    required this.resultGrowth,
    required this.lessonPlanCompletion,
    required this.studentSupportClosure,
    required this.rating,
    required this.signal,
  });

  final String name;
  final String subject;
  final String classes;
  final double studentAverage;
  final double resultGrowth;
  final double lessonPlanCompletion;
  final double studentSupportClosure;
  final double rating;
  final String signal;

  @override
  List<Object?> get props => [
        name,
        subject,
        classes,
        studentAverage,
        resultGrowth,
        lessonPlanCompletion,
        studentSupportClosure,
        rating,
        signal,
      ];
}

class LeadershipStudentPerformance extends Equatable {
  const LeadershipStudentPerformance({
    required this.name,
    required this.className,
    required this.average,
    required this.change,
    required this.strongestSubject,
    required this.supportSubject,
    required this.attendance,
    required this.signal,
  });

  final String name;
  final String className;
  final double average;
  final double change;
  final String strongestSubject;
  final String supportSubject;
  final double attendance;
  final String signal;

  @override
  List<Object?> get props => [
        name,
        className,
        average,
        change,
        strongestSubject,
        supportSubject,
        attendance,
        signal,
      ];
}

class AttendanceDivision extends Equatable {
  const AttendanceDivision({
    required this.label,
    required this.studentsPresent,
    required this.totalStudents,
    required this.staffPresent,
    required this.totalStaff,
  });

  final String label;
  final int studentsPresent;
  final int totalStudents;
  final int staffPresent;
  final int totalStaff;

  double get studentRate => studentsPresent / totalStudents * 100;
  double get staffRate => staffPresent / totalStaff * 100;

  @override
  List<Object?> get props =>
      [label, studentsPresent, totalStudents, staffPresent, totalStaff];
}

class LeadershipCalendarEvent extends Equatable {
  const LeadershipCalendarEvent({
    required this.title,
    required this.time,
    required this.location,
    required this.category,
  });

  final String title;
  final String time;
  final String location;
  final String category;

  @override
  List<Object?> get props => [title, time, location, category];
}

class LeadershipSnapshot extends Equatable {
  const LeadershipSnapshot({
    required this.profile,
    required this.schoolHealth,
    required this.totalStudents,
    required this.totalStaff,
    required this.studentAttendance,
    required this.staffAttendance,
    required this.collectedToday,
    required this.outstandingFees,
    required this.admissionConversion,
    required this.academicRiskStudents,
    required this.transportOnTime,
    required this.pendingApprovals,
    required this.alerts,
    required this.approvals,
    required this.academics,
    required this.attendanceDivisions,
    required this.events,
    required this.admissionFunnel,
    required this.syllabusUnitsBehind,
    required this.openInterventions,
    required this.staleAdmissionLeads,
    required this.overdueFeeAccounts,
    required this.criticalParentTickets,
    required this.delayedRoutes,
    required this.substitutionGaps,
    required this.securityIncidents,
    required this.collectionProgress,
    required this.branches,
    required this.teacherPerformance,
    required this.studentPerformance,
    required this.improvedStudentCount,
    required this.attentionStudentCount,
    required this.topPerformerCount,
  });

  final LeadershipProfile profile;
  final int schoolHealth;
  final int totalStudents;
  final int totalStaff;
  final double studentAttendance;
  final double staffAttendance;
  final double collectedToday;
  final double outstandingFees;
  final double admissionConversion;
  final int academicRiskStudents;
  final double transportOnTime;
  final int pendingApprovals;
  final List<LeadershipAlert> alerts;
  final List<LeadershipApproval> approvals;
  final List<AcademicClassInsight> academics;
  final List<AttendanceDivision> attendanceDivisions;
  final List<LeadershipCalendarEvent> events;
  final Map<String, int> admissionFunnel;
  final int syllabusUnitsBehind;
  final int openInterventions;
  final int staleAdmissionLeads;
  final int overdueFeeAccounts;
  final int criticalParentTickets;
  final int delayedRoutes;
  final int substitutionGaps;
  final int securityIncidents;
  final double collectionProgress;
  final List<LeadershipBranchInsight> branches;
  final List<LeadershipTeacherPerformance> teacherPerformance;
  final List<LeadershipStudentPerformance> studentPerformance;
  final int improvedStudentCount;
  final int attentionStudentCount;
  final int topPerformerCount;

  LeadershipSnapshot copyWith({
    List<LeadershipAlert>? alerts,
    List<LeadershipApproval>? approvals,
  }) =>
      LeadershipSnapshot(
        profile: profile,
        schoolHealth: schoolHealth,
        totalStudents: totalStudents,
        totalStaff: totalStaff,
        studentAttendance: studentAttendance,
        staffAttendance: staffAttendance,
        collectedToday: collectedToday,
        outstandingFees: outstandingFees,
        admissionConversion: admissionConversion,
        academicRiskStudents: academicRiskStudents,
        transportOnTime: transportOnTime,
        pendingApprovals:
            approvals?.where((item) => item.status == 'Pending').length ??
                pendingApprovals,
        alerts: alerts ?? this.alerts,
        approvals: approvals ?? this.approvals,
        academics: academics,
        attendanceDivisions: attendanceDivisions,
        events: events,
        admissionFunnel: admissionFunnel,
        syllabusUnitsBehind: syllabusUnitsBehind,
        openInterventions: openInterventions,
        staleAdmissionLeads: staleAdmissionLeads,
        overdueFeeAccounts: overdueFeeAccounts,
        criticalParentTickets: criticalParentTickets,
        delayedRoutes: delayedRoutes,
        substitutionGaps: substitutionGaps,
        securityIncidents: securityIncidents,
        collectionProgress: collectionProgress,
        branches: branches,
        teacherPerformance: teacherPerformance,
        studentPerformance: studentPerformance,
        improvedStudentCount: improvedStudentCount,
        attentionStudentCount: attentionStudentCount,
        topPerformerCount: topPerformerCount,
      );

  @override
  List<Object?> get props => [
        profile,
        schoolHealth,
        totalStudents,
        totalStaff,
        studentAttendance,
        staffAttendance,
        collectedToday,
        outstandingFees,
        admissionConversion,
        academicRiskStudents,
        transportOnTime,
        pendingApprovals,
        alerts,
        approvals,
        academics,
        attendanceDivisions,
        events,
        admissionFunnel,
        syllabusUnitsBehind,
        openInterventions,
        staleAdmissionLeads,
        overdueFeeAccounts,
        criticalParentTickets,
        delayedRoutes,
        substitutionGaps,
        securityIncidents,
        collectionProgress,
        branches,
        teacherPerformance,
        studentPerformance,
        improvedStudentCount,
        attentionStudentCount,
        topPerformerCount,
      ];
}

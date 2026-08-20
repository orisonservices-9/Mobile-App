import 'package:equatable/equatable.dart';

class TeacherProfile extends Equatable {
  const TeacherProfile({
    required this.id,
    required this.name,
    required this.mobile,
    required this.designation,
    required this.department,
    required this.employeeId,
    required this.classTeacherOf,
  });

  final String id;
  final String name;
  final String mobile;
  final String designation;
  final String department;
  final String employeeId;
  final String classTeacherOf;

  @override
  List<Object?> get props => [
        id,
        name,
        mobile,
        designation,
        department,
        employeeId,
        classTeacherOf,
      ];
}

class TeacherClass extends Equatable {
  const TeacherClass({
    required this.id,
    required this.className,
    required this.section,
    required this.subjects,
    required this.studentCount,
    required this.room,
    required this.average,
    required this.attendanceMarked,
    required this.canTakeAttendance,
  });

  final String id;
  final String className;
  final String section;
  final List<String> subjects;
  final int studentCount;
  final String room;
  final double average;
  final bool attendanceMarked;
  final bool canTakeAttendance;

  String get label => '$className · $section';
  String get subject => subjects.first;

  TeacherClass copyWith({bool? attendanceMarked}) => TeacherClass(
        id: id,
        className: className,
        section: section,
        subjects: subjects,
        studentCount: studentCount,
        room: room,
        average: average,
        attendanceMarked: attendanceMarked ?? this.attendanceMarked,
        canTakeAttendance: canTakeAttendance,
      );

  @override
  List<Object?> get props => [
        id,
        className,
        section,
        subjects,
        studentCount,
        room,
        average,
        attendanceMarked,
        canTakeAttendance,
      ];
}

class TeacherPeriod extends Equatable {
  const TeacherPeriod({
    required this.id,
    required this.period,
    required this.classLabel,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.status,
    required this.weekday,
    required this.classId,
  });

  final String id;
  final int period;
  final String classLabel;
  final String subject;
  final String startTime;
  final String endTime;
  final String room;
  final String status;
  final int weekday;
  final String classId;

  @override
  List<Object?> get props => [
        id,
        period,
        classLabel,
        subject,
        startTime,
        endTime,
        room,
        status,
        weekday,
        classId,
      ];
}

class TeacherTask extends Equatable {
  const TeacherTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.dueLabel,
    required this.priority,
    this.completed = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String dueLabel;
  final String priority;
  final bool completed;

  TeacherTask copyWith({bool? completed}) => TeacherTask(
        id: id,
        title: title,
        subtitle: subtitle,
        category: category,
        dueLabel: dueLabel,
        priority: priority,
        completed: completed ?? this.completed,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        category,
        dueLabel,
        priority,
        completed,
      ];
}

class TeacherNotice extends Equatable {
  const TeacherNotice({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.priority,
    this.unread = true,
  });

  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final String priority;
  final bool unread;

  @override
  List<Object?> get props => [id, title, body, timeLabel, priority, unread];
}

class TeacherStudent extends Equatable {
  const TeacherStudent({
    required this.id,
    required this.name,
    required this.roll,
    required this.performance,
    required this.attendance,
    required this.status,
    required this.classId,
    required this.subjectScores,
  });

  final String id;
  final String name;
  final String roll;
  final double performance;
  final double attendance;
  final String status;
  final String classId;
  final Map<String, double> subjectScores;

  @override
  List<Object?> get props => [
        id,
        name,
        roll,
        performance,
        attendance,
        status,
        classId,
        subjectScores,
      ];
}

class TeacherLessonPlan extends Equatable {
  const TeacherLessonPlan({
    required this.id,
    required this.classId,
    required this.classLabel,
    required this.subject,
    required this.lesson,
    required this.objective,
    required this.startDate,
    required this.endDate,
    required this.periodLabel,
    required this.status,
  });

  final String id;
  final String classId;
  final String classLabel;
  final String subject;
  final String lesson;
  final String objective;
  final DateTime startDate;
  final DateTime endDate;
  final String periodLabel;
  final String status;

  TeacherLessonPlan copyWith({String? status}) => TeacherLessonPlan(
        id: id,
        classId: classId,
        classLabel: classLabel,
        subject: subject,
        lesson: lesson,
        objective: objective,
        startDate: startDate,
        endDate: endDate,
        periodLabel: periodLabel,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [
        id,
        classId,
        classLabel,
        subject,
        lesson,
        objective,
        startDate,
        endDate,
        periodLabel,
        status,
      ];
}

class TeacherLeaveRequest extends Equatable {
  const TeacherLeaveRequest({
    required this.id,
    required this.type,
    required this.from,
    required this.to,
    required this.reason,
    required this.status,
    this.attachmentName,
  });

  final String id;
  final String type;
  final DateTime from;
  final DateTime to;
  final String reason;
  final String status;
  final String? attachmentName;

  int get days => to.difference(from).inDays + 1;

  @override
  List<Object?> get props =>
      [id, type, from, to, reason, status, attachmentName];
}

class TeacherSnapshot extends Equatable {
  const TeacherSnapshot({
    required this.profile,
    required this.classes,
    required this.periods,
    required this.tasks,
    required this.notices,
    required this.students,
    required this.lessonPlans,
    required this.leaveRequests,
  });

  final TeacherProfile profile;
  final List<TeacherClass> classes;
  final List<TeacherPeriod> periods;
  final List<TeacherTask> tasks;
  final List<TeacherNotice> notices;
  final List<TeacherStudent> students;
  final List<TeacherLessonPlan> lessonPlans;
  final List<TeacherLeaveRequest> leaveRequests;

  TeacherSnapshot copyWith({
    List<TeacherClass>? classes,
    List<TeacherTask>? tasks,
    List<TeacherLessonPlan>? lessonPlans,
    List<TeacherLeaveRequest>? leaveRequests,
  }) =>
      TeacherSnapshot(
        profile: profile,
        classes: classes ?? this.classes,
        periods: periods,
        tasks: tasks ?? this.tasks,
        notices: notices,
        students: students,
        lessonPlans: lessonPlans ?? this.lessonPlans,
        leaveRequests: leaveRequests ?? this.leaveRequests,
      );

  @override
  List<Object?> get props => [
        profile,
        classes,
        periods,
        tasks,
        notices,
        students,
        lessonPlans,
        leaveRequests,
      ];
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/orison_repository.dart';
import '../models/teacher_models.dart';

sealed class TeacherEvent extends Equatable {
  const TeacherEvent();

  @override
  List<Object?> get props => [];
}

class TeacherLoaded extends TeacherEvent {
  const TeacherLoaded(this.teacherId);
  final String teacherId;

  @override
  List<Object?> get props => [teacherId];
}

class TeacherAttendanceSubmitted extends TeacherEvent {
  const TeacherAttendanceSubmitted(this.classId, this.date, this.statuses);
  final String classId;
  final DateTime date;
  final Map<String, String> statuses;

  @override
  List<Object?> get props => [classId, date, statuses];
}

class TeacherHomeworkAssigned extends TeacherEvent {
  const TeacherHomeworkAssigned({
    required this.classId,
    required this.subject,
    required this.title,
    required this.instructions,
    required this.dueDate,
    required this.attachmentNames,
  });

  final String classId;
  final String subject;
  final String title;
  final String instructions;
  final DateTime dueDate;
  final List<String> attachmentNames;

  @override
  List<Object?> get props => [
        classId,
        subject,
        title,
        instructions,
        dueDate,
        attachmentNames,
      ];
}

class TeacherLessonPlanCompleted extends TeacherEvent {
  const TeacherLessonPlanCompleted(this.planId);
  final String planId;

  @override
  List<Object?> get props => [planId];
}

class TeacherLeaveSubmitted extends TeacherEvent {
  const TeacherLeaveSubmitted(this.request);
  final TeacherLeaveRequest request;

  @override
  List<Object?> get props => [request];
}

class TeacherTaskToggled extends TeacherEvent {
  const TeacherTaskToggled(this.taskId);
  final String taskId;

  @override
  List<Object?> get props => [taskId];
}

sealed class TeacherState extends Equatable {
  const TeacherState();

  @override
  List<Object?> get props => [];
}

class TeacherInitial extends TeacherState {}

class TeacherLoading extends TeacherState {}

class TeacherReady extends TeacherState {
  const TeacherReady(this.data, {this.message});
  final TeacherSnapshot data;
  final String? message;

  TeacherReady copyWith({TeacherSnapshot? data, String? message}) =>
      TeacherReady(data ?? this.data, message: message);

  @override
  List<Object?> get props => [data, message];
}

class TeacherFailure extends TeacherState {
  const TeacherFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  TeacherBloc(this.repository) : super(TeacherInitial()) {
    on<TeacherLoaded>((event, emit) async {
      emit(TeacherLoading());
      try {
        emit(TeacherReady(await repository.loadTeacherHome(event.teacherId)));
      } catch (_) {
        emit(const TeacherFailure('Unable to load the teacher workspace.'));
      }
    });

    on<TeacherAttendanceSubmitted>((event, emit) async {
      final current = state;
      if (current is! TeacherReady) return;
      final assignedClass = current.data.classes
          .where((item) => item.id == event.classId && item.canTakeAttendance);
      if (assignedClass.isEmpty) {
        emit(current.copyWith(
          message:
              'Only the teacher assigned to this class’s first period can mark attendance.',
        ));
        return;
      }
      final saved = await repository.submitTeacherAttendance(
        classId: event.classId,
        date: event.date,
        statuses: event.statuses,
      );
      if (!saved) {
        emit(current.copyWith(message: 'Attendance could not be saved.'));
        return;
      }
      emit(current.copyWith(
        data: current.data.copyWith(
          classes: current.data.classes
              .map((item) => item.id == event.classId
                  ? item.copyWith(attendanceMarked: true)
                  : item)
              .toList(),
        ),
        message: 'Attendance saved for the selected date',
      ));
    });

    on<TeacherHomeworkAssigned>((event, emit) async {
      final current = state;
      if (current is! TeacherReady) return;
      final saved = await repository.assignTeacherHomework(
        classId: event.classId,
        subject: event.subject,
        title: event.title,
        instructions: event.instructions,
        dueDate: event.dueDate,
        attachmentNames: event.attachmentNames,
      );
      emit(current.copyWith(
        message: saved
            ? 'Homework published to students and parents'
            : 'Homework could not be published.',
      ));
    });

    on<TeacherLessonPlanCompleted>((event, emit) async {
      final current = state;
      if (current is! TeacherReady) return;
      final saved = await repository.completeTeacherLessonPlan(event.planId);
      if (!saved) {
        emit(current.copyWith(message: 'Lesson plan could not be updated.'));
        return;
      }
      emit(current.copyWith(
        data: current.data.copyWith(
          lessonPlans: current.data.lessonPlans
              .map((plan) => plan.id == event.planId
                  ? plan.copyWith(status: 'Completed')
                  : plan)
              .toList(),
        ),
        message: 'Lesson plan marked complete',
      ));
    });

    on<TeacherLeaveSubmitted>((event, emit) async {
      final current = state;
      if (current is! TeacherReady) return;
      final saved = await repository.applyTeacherLeave(event.request);
      if (!saved) {
        emit(
            current.copyWith(message: 'Leave request could not be submitted.'));
        return;
      }
      emit(current.copyWith(
        data: current.data.copyWith(
          leaveRequests: [event.request, ...current.data.leaveRequests],
        ),
        message: 'Leave request sent for approval',
      ));
    });

    on<TeacherTaskToggled>((event, emit) {
      final current = state;
      if (current is! TeacherReady) return;
      emit(current.copyWith(
        data: current.data.copyWith(
          tasks: current.data.tasks
              .map((task) => task.id == event.taskId
                  ? task.copyWith(completed: !task.completed)
                  : task)
              .toList(),
        ),
        message: 'Task status updated',
      ));
    });
  }

  final OrisonRepository repository;
}

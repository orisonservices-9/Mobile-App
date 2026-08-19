import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/orison_repository.dart';
import '../models/models.dart';

sealed class ParentEvent extends Equatable {
  const ParentEvent();
  @override
  List<Object?> get props => [];
}

class ParentLoaded extends ParentEvent {}

class StudentSelected extends ParentEvent {
  const StudentSelected(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

class ProfileSaved extends ParentEvent {
  const ProfileSaved(this.profile);
  final ParentProfile profile;
  @override
  List<Object?> get props => [profile];
}

class LeaveSubmitted extends ParentEvent {
  const LeaveSubmitted({
    required this.studentId,
    required this.from,
    required this.to,
    required this.type,
    required this.description,
    this.attachmentName,
  });
  final String studentId;
  final DateTime from;
  final DateTime to;
  final String type;
  final String description;
  final String? attachmentName;
  @override
  List<Object?> get props =>
      [studentId, from, to, type, description, attachmentName];
}

class FeePaymentRequested extends ParentEvent {
  const FeePaymentRequested(this.feeId);
  final String feeId;
  @override
  List<Object?> get props => [feeId];
}

class FeePaymentProofSubmitted extends ParentEvent {
  const FeePaymentProofSubmitted({
    required this.feeId,
    required this.amount,
    required this.transactionId,
    required this.proofName,
  });
  final String feeId;
  final double amount;
  final String transactionId;
  final String proofName;
  @override
  List<Object?> get props => [feeId, amount, transactionId, proofName];
}

class HomeworkStatusChanged extends ParentEvent {
  const HomeworkStatusChanged({
    required this.homeworkId,
    required this.completed,
  });
  final String homeworkId;
  final bool completed;
  @override
  List<Object?> get props => [homeworkId, completed];
}

class NoticeOpened extends ParentEvent {
  const NoticeOpened(this.noticeId);
  final String noticeId;
  @override
  List<Object?> get props => [noticeId];
}

class HelpRequestSubmitted extends ParentEvent {
  const HelpRequestSubmitted({
    required this.kind,
    required this.category,
    required this.description,
    required this.priority,
    this.preferredTime,
    this.attachmentName,
    this.parentName,
    this.studentName,
    this.mobile,
  });
  final String kind;
  final String category;
  final String description;
  final String priority;
  final String? preferredTime;
  final String? attachmentName;
  final String? parentName;
  final String? studentName;
  final String? mobile;
  @override
  List<Object?> get props => [
        kind,
        category,
        description,
        priority,
        preferredTime,
        attachmentName,
        parentName,
        studentName,
        mobile,
      ];
}

sealed class ParentState extends Equatable {
  const ParentState();
  @override
  List<Object?> get props => [];
}

class ParentInitial extends ParentState {}

class ParentLoading extends ParentState {}

class ParentReady extends ParentState {
  const ParentReady(this.data, {this.selectedStudent = 0, this.message});
  final ParentSnapshot data;
  final int selectedStudent;
  final String? message;
  Student get student => data.students[selectedStudent];
  ParentReady copyWith(
          {ParentSnapshot? data, int? selectedStudent, String? message}) =>
      ParentReady(data ?? this.data,
          selectedStudent: selectedStudent ?? this.selectedStudent,
          message: message);
  @override
  List<Object?> get props => [data, selectedStudent, message];
}

class ParentFailure extends ParentState {
  const ParentFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class ParentBloc extends Bloc<ParentEvent, ParentState> {
  ParentBloc(this.repository) : super(ParentInitial()) {
    on<ParentLoaded>((event, emit) async {
      emit(ParentLoading());
      try {
        emit(ParentReady(await repository.loadParentHome()));
      } catch (_) {
        emit(const ParentFailure('Unable to load parent information.'));
      }
    });
    on<StudentSelected>((event, emit) {
      final s = state;
      if (s is ParentReady) emit(s.copyWith(selectedStudent: event.index));
    });
    on<ProfileSaved>((event, emit) async {
      final s = state;
      if (s is! ParentReady) return;
      final profile = await repository.updateProfile(event.profile);
      emit(s.copyWith(
          data: ParentSnapshot(
              students: s.data.students,
              attendance: s.data.attendance,
              grades: s.data.grades,
              fees: s.data.fees,
              homework: s.data.homework,
              leaveRequests: s.data.leaveRequests,
              helpRequests: s.data.helpRequests,
              notices: s.data.notices,
              profile: profile),
          message: 'Profile and preferences updated'));
    });
    on<LeaveSubmitted>((event, emit) async {
      final s = state;
      if (s is! ParentReady) return;
      final request = await repository.applyLeave(
        studentId: event.studentId,
        from: event.from,
        to: event.to,
        type: event.type,
        description: event.description,
        attachmentName: event.attachmentName,
      );
      emit(s.copyWith(
        data: ParentSnapshot(
          students: s.data.students,
          attendance: s.data.attendance,
          grades: s.data.grades,
          fees: s.data.fees,
          homework: s.data.homework,
          leaveRequests: [request, ...s.data.leaveRequests],
          helpRequests: s.data.helpRequests,
          notices: s.data.notices,
          profile: s.data.profile,
        ),
        message: 'Leave request submitted for school approval',
      ));
    });
    on<FeePaymentRequested>((event, emit) async {
      final s = state;
      if (s is! ParentReady) return;
      await repository.initiateFeePayment(event.feeId);
      emit(s.copyWith(message: 'Payment request started'));
    });
    on<FeePaymentProofSubmitted>((event, emit) async {
      final s = state;
      if (s is! ParentReady) return;
      final verified = await repository.submitFeePaymentProof(
        feeId: event.feeId,
        amount: event.amount,
        transactionId: event.transactionId,
        proofName: event.proofName,
      );
      if (!verified) {
        emit(s.copyWith(message: 'Payment details could not be verified'));
        return;
      }
      final updatedFees = s.data.fees.map((fee) {
        if (fee.id != event.feeId) return fee;
        final updatedAmount = fee.paidAmount + event.amount;
        final paidAmount =
            updatedAmount > fee.amount ? fee.amount : updatedAmount;
        return fee.copyWith(
          paidAmount: paidAmount,
          status: paidAmount >= fee.amount ? 'Paid' : 'Partially paid',
          transactionId: event.transactionId,
          paidOn: DateTime.now(),
          receiptAmount: event.amount,
        );
      }).toList();
      emit(s.copyWith(
        data: ParentSnapshot(
          students: s.data.students,
          attendance: s.data.attendance,
          grades: s.data.grades,
          fees: updatedFees,
          homework: s.data.homework,
          leaveRequests: s.data.leaveRequests,
          helpRequests: s.data.helpRequests,
          notices: s.data.notices,
          profile: s.data.profile,
        ),
        message: 'Payment verified and fee status updated',
      ));
    });
    on<HomeworkStatusChanged>((event, emit) async {
      final s = state;
      if (s is! ParentReady) return;
      final updated = await repository.updateHomeworkStatus(
        studentId: s.student.id,
        homeworkId: event.homeworkId,
        completed: event.completed,
      );
      if (!updated) {
        emit(s.copyWith(message: 'Unable to update homework status'));
        return;
      }
      final homework = s.data.homework.map((item) {
        if (item.id != event.homeworkId) return item;
        return item.copyWith(
          completed: event.completed,
          statusUpdatedAt: DateTime.now(),
        );
      }).toList();
      emit(s.copyWith(
        data: ParentSnapshot(
          students: s.data.students,
          attendance: s.data.attendance,
          grades: s.data.grades,
          fees: s.data.fees,
          homework: homework,
          leaveRequests: s.data.leaveRequests,
          helpRequests: s.data.helpRequests,
          notices: s.data.notices,
          profile: s.data.profile,
        ),
        message: event.completed
            ? 'Homework marked as done and shared with school'
            : 'Homework moved back to pending',
      ));
    });
    on<NoticeOpened>((event, emit) async {
      final s = state;
      if (s is! ParentReady) return;
      final notice = s.data.notices.where((item) => item.id == event.noticeId);
      if (notice.isEmpty || !notice.first.unread) return;
      final updated = await repository.markNoticeRead(event.noticeId);
      if (!updated) return;
      final notices = s.data.notices
          .map((item) =>
              item.id == event.noticeId ? item.copyWith(unread: false) : item)
          .toList();
      emit(s.copyWith(
        data: ParentSnapshot(
          students: s.data.students,
          attendance: s.data.attendance,
          grades: s.data.grades,
          fees: s.data.fees,
          homework: s.data.homework,
          leaveRequests: s.data.leaveRequests,
          helpRequests: s.data.helpRequests,
          notices: notices,
          profile: s.data.profile,
        ),
      ));
    });
    on<HelpRequestSubmitted>((event, emit) async {
      final s = state;
      if (s is! ParentReady) return;
      final request = await repository.submitHelpRequest(
        studentId: s.student.id,
        kind: event.kind,
        category: event.category,
        description: event.description,
        priority: event.priority,
        preferredTime: event.preferredTime,
        attachmentName: event.attachmentName,
        parentName: event.parentName,
        studentName: event.studentName,
        mobile: event.mobile,
      );
      emit(s.copyWith(
        data: ParentSnapshot(
          students: s.data.students,
          attendance: s.data.attendance,
          grades: s.data.grades,
          fees: s.data.fees,
          homework: s.data.homework,
          leaveRequests: s.data.leaveRequests,
          helpRequests: [request, ...s.data.helpRequests],
          notices: s.data.notices,
          profile: s.data.profile,
        ),
        message: event.kind == 'School callback'
            ? 'School callback request submitted'
            : 'Orison app support ticket raised',
      ));
    });
  }
  final OrisonRepository repository;
}

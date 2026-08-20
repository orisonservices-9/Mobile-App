import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/orison_repository.dart';
import '../models/leadership_models.dart';

sealed class LeadershipEvent extends Equatable {
  const LeadershipEvent();
  @override
  List<Object?> get props => [];
}

class LeadershipLoaded extends LeadershipEvent {
  const LeadershipLoaded(this.userId);
  final String userId;
  @override
  List<Object?> get props => [userId];
}

class LeadershipApprovalDecided extends LeadershipEvent {
  const LeadershipApprovalDecided(this.approvalId, this.decision);
  final String approvalId;
  final String decision;
  @override
  List<Object?> get props => [approvalId, decision];
}

class LeadershipAlertResolved extends LeadershipEvent {
  const LeadershipAlertResolved(this.alertId);
  final String alertId;
  @override
  List<Object?> get props => [alertId];
}

class LeadershipAnnouncementPublished extends LeadershipEvent {
  const LeadershipAnnouncementPublished(this.title, this.audience);
  final String title;
  final String audience;
  @override
  List<Object?> get props => [title, audience];
}

sealed class LeadershipState extends Equatable {
  const LeadershipState();
  @override
  List<Object?> get props => [];
}

class LeadershipInitial extends LeadershipState {}

class LeadershipLoading extends LeadershipState {}

class LeadershipReady extends LeadershipState {
  const LeadershipReady(this.data, {this.message});
  final LeadershipSnapshot data;
  final String? message;

  LeadershipReady copyWith({LeadershipSnapshot? data, String? message}) =>
      LeadershipReady(data ?? this.data, message: message);

  @override
  List<Object?> get props => [data, message];
}

class LeadershipFailure extends LeadershipState {
  const LeadershipFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class LeadershipBloc extends Bloc<LeadershipEvent, LeadershipState> {
  LeadershipBloc(this.repository) : super(LeadershipInitial()) {
    on<LeadershipLoaded>((event, emit) async {
      emit(LeadershipLoading());
      try {
        emit(
            LeadershipReady(await repository.loadLeadershipHome(event.userId)));
      } catch (_) {
        emit(const LeadershipFailure('Unable to load leadership workspace.'));
      }
    });

    on<LeadershipApprovalDecided>((event, emit) async {
      final current = state;
      if (current is! LeadershipReady) return;
      final saved = await repository.decideLeadershipApproval(
        event.approvalId,
        event.decision,
      );
      if (!saved) {
        emit(current.copyWith(message: 'Approval could not be updated.'));
        return;
      }
      emit(current.copyWith(
        data: current.data.copyWith(
          approvals: current.data.approvals
              .map((item) => item.id == event.approvalId
                  ? item.copyWith(status: event.decision)
                  : item)
              .toList(),
        ),
        message: 'Request ${event.decision.toLowerCase()}',
      ));
    });

    on<LeadershipAlertResolved>((event, emit) async {
      final current = state;
      if (current is! LeadershipReady) return;
      final saved = await repository.resolveLeadershipAlert(event.alertId);
      if (!saved) return;
      emit(current.copyWith(
        data: current.data.copyWith(
          alerts: current.data.alerts
              .map((item) => item.id == event.alertId
                  ? item.copyWith(resolved: true)
                  : item)
              .toList(),
        ),
        message: 'Leadership action marked resolved',
      ));
    });

    on<LeadershipAnnouncementPublished>((event, emit) async {
      final current = state;
      if (current is! LeadershipReady) return;
      final saved = await repository.publishLeadershipAnnouncement(
        event.title,
        event.audience,
      );
      emit(current.copyWith(
        message: saved
            ? 'Announcement published to ${event.audience}'
            : 'Announcement could not be published.',
      ));
    });
  }

  final OrisonRepository repository;
}

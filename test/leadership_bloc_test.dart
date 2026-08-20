import 'package:flutter_test/flutter_test.dart';
import 'package:orison_parent_app/src/data/orison_repository.dart';
import 'package:orison_parent_app/src/state/leadership_bloc.dart';

void main() {
  test('loads school leadership dashboard', () async {
    final bloc = LeadershipBloc(DemoOrisonRepository());
    bloc.add(const LeadershipLoaded('DIR-001'));
    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<LeadershipLoading>(),
        isA<LeadershipReady>()
            .having((state) => state.data.schoolHealth, 'health', 86)
            .having((state) => state.data.pendingApprovals, 'approvals', 6)
            .having((state) => state.data.branches.length, 'branches', 3)
            .having((state) => state.data.criticalParentTickets,
                'service escalations', 2)
            .having((state) => state.data.teacherPerformance.length,
                'teacher performance', 4)
            .having((state) => state.data.studentPerformance.length,
                'student performance', 4),
      ]),
    );
    await bloc.close();
  });

  test('director approves a pending request', () async {
    final bloc = LeadershipBloc(DemoOrisonRepository());
    bloc.add(const LeadershipLoaded('DIR-001'));
    await bloc.stream.firstWhere((state) => state is LeadershipReady);
    bloc.add(const LeadershipApprovalDecided('APR-001', 'Approved'));
    final ready = await bloc.stream.firstWhere(
      (state) => state is LeadershipReady && state.message != null,
    ) as LeadershipReady;
    expect(
      ready.data.approvals.firstWhere((item) => item.id == 'APR-001').status,
      'Approved',
    );
    expect(ready.data.pendingApprovals, 5);
    await bloc.close();
  });

  test('director can request changes without approving the request', () async {
    final bloc = LeadershipBloc(DemoOrisonRepository());
    bloc.add(const LeadershipLoaded('DIR-001'));
    await bloc.stream.firstWhere((state) => state is LeadershipReady);
    bloc.add(const LeadershipApprovalDecided('APR-002', 'Needs changes'));
    final ready = await bloc.stream.firstWhere(
      (state) => state is LeadershipReady && state.message != null,
    ) as LeadershipReady;
    expect(
      ready.data.approvals.firstWhere((item) => item.id == 'APR-002').status,
      'Needs changes',
    );
    expect(ready.data.pendingApprovals, 5);
    await bloc.close();
  });

  test('director resolves a priority alert', () async {
    final bloc = LeadershipBloc(DemoOrisonRepository());
    bloc.add(const LeadershipLoaded('DIR-001'));
    await bloc.stream.firstWhere((state) => state is LeadershipReady);
    bloc.add(const LeadershipAlertResolved('ALERT-ACA-01'));
    final ready = await bloc.stream.firstWhere(
      (state) => state is LeadershipReady && state.message != null,
    ) as LeadershipReady;
    expect(
      ready.data.alerts
          .firstWhere((item) => item.id == 'ALERT-ACA-01')
          .resolved,
      isTrue,
    );
    await bloc.close();
  });
}

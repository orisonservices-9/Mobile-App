import 'package:flutter_test/flutter_test.dart';
import 'package:orison_parent_app/src/data/orison_repository.dart';
import 'package:orison_parent_app/src/state/parent_bloc.dart';

void main() {
  test('submitted leave is added to history as pending', () async {
    final bloc = ParentBloc(DemoOrisonRepository());
    final loaded = bloc.stream.firstWhere((state) => state is ParentReady);
    bloc.add(ParentLoaded());
    final initial = (await loaded) as ParentReady;
    final initialCount = initial.data.leaveRequests.length;

    final submitted = bloc.stream.firstWhere(
      (state) =>
          state is ParentReady &&
          state.message == 'Leave request submitted for school approval',
    );
    bloc.add(LeaveSubmitted(
      studentId: initial.student.id,
      from: DateTime(2026, 9, 7),
      to: DateTime(2026, 9, 8),
      type: 'Medical leave',
      description: 'Doctor advised rest.',
      attachmentName: 'medical-note.pdf',
    ));

    final state = (await submitted) as ParentReady;
    expect(state.data.leaveRequests.length, initialCount + 1);
    expect(state.data.leaveRequests.first.status, 'Pending');
    expect(state.data.leaveRequests.first.days, 2);
    expect(state.data.leaveRequests.first.attachmentName, 'medical-note.pdf');
    await bloc.close();
  });
}

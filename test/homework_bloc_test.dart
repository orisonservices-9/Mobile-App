import 'package:flutter_test/flutter_test.dart';
import 'package:orison_parent_app/src/data/orison_repository.dart';
import 'package:orison_parent_app/src/state/parent_bloc.dart';

void main() {
  test('homework status is synchronized as done and pending', () async {
    final bloc = ParentBloc(DemoOrisonRepository());
    final loaded = bloc.stream.firstWhere((state) => state is ParentReady);
    bloc.add(ParentLoaded());
    await loaded;

    final doneState = bloc.stream.firstWhere(
      (state) =>
          state is ParentReady &&
          state.message == 'Homework marked as done and shared with school',
    );
    bloc.add(const HomeworkStatusChanged(
      homeworkId: 'hw-math-72',
      completed: true,
    ));
    final done = (await doneState) as ParentReady;
    expect(
      done.data.homework
          .firstWhere((item) => item.id == 'hw-math-72')
          .completed,
      isTrue,
    );

    final pendingState = bloc.stream.firstWhere(
      (state) =>
          state is ParentReady &&
          state.message == 'Homework moved back to pending',
    );
    bloc.add(const HomeworkStatusChanged(
      homeworkId: 'hw-math-72',
      completed: false,
    ));
    final pending = (await pendingState) as ParentReady;
    expect(
      pending.data.homework
          .firstWhere((item) => item.id == 'hw-math-72')
          .completed,
      isFalse,
    );
    await bloc.close();
  });
}

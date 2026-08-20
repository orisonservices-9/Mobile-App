import 'package:flutter_test/flutter_test.dart';
import 'package:orison_parent_app/src/data/orison_repository.dart';
import 'package:orison_parent_app/src/models/teacher_models.dart';
import 'package:orison_parent_app/src/state/teacher_bloc.dart';

void main() {
  test('loads the teacher workspace and assigned classes', () async {
    final bloc = TeacherBloc(DemoOrisonRepository());
    bloc.add(const TeacherLoaded('TCH-001'));
    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<TeacherLoading>(),
        isA<TeacherReady>()
            .having((state) => state.data.profile.id, 'teacher id', 'TCH-001')
            .having((state) => state.data.classes.length, 'classes', 3),
      ]),
    );
    await bloc.close();
  });

  test('submitted attendance marks the assigned class complete', () async {
    final bloc = TeacherBloc(DemoOrisonRepository());
    bloc.add(const TeacherLoaded('TCH-001'));
    await bloc.stream.firstWhere((state) => state is TeacherReady);
    bloc.add(TeacherAttendanceSubmitted(
      'class-11-b-physics',
      DateTime(2026, 8, 19),
      {'STU-11B-02': 'Present'},
    ));
    final ready = await bloc.stream.firstWhere(
      (state) => state is TeacherReady && state.message != null,
    ) as TeacherReady;
    expect(
      ready.data.classes
          .firstWhere((item) => item.id == 'class-11-b-physics')
          .attendanceMarked,
      isTrue,
    );
    await bloc.close();
  });

  test('teacher cannot mark attendance outside first-period responsibility',
      () async {
    final bloc = TeacherBloc(DemoOrisonRepository());
    bloc.add(const TeacherLoaded('TCH-001'));
    await bloc.stream.firstWhere((state) => state is TeacherReady);
    bloc.add(TeacherAttendanceSubmitted(
      'class-12-a-physics',
      DateTime.now(),
      const {'STU-11B-02': 'Present'},
    ));
    final ready = await bloc.stream.firstWhere(
      (state) => state is TeacherReady && state.message != null,
    ) as TeacherReady;
    expect(ready.message, contains('first period'));
    expect(
      ready.data.classes
          .firstWhere((item) => item.id == 'class-12-a-physics')
          .attendanceMarked,
      isFalse,
    );
    await bloc.close();
  });

  test('teacher completes an admin-assigned lesson plan', () async {
    final bloc = TeacherBloc(DemoOrisonRepository());
    bloc.add(const TeacherLoaded('TCH-001'));
    await bloc.stream.firstWhere((state) => state is TeacherReady);
    bloc.add(const TeacherLessonPlanCompleted('LP-101'));
    final ready = await bloc.stream.firstWhere(
      (state) => state is TeacherReady && state.message != null,
    ) as TeacherReady;
    expect(
      ready.data.lessonPlans.firstWhere((plan) => plan.id == 'LP-101').status,
      'Completed',
    );
    await bloc.close();
  });

  test('submitted staff leave is added with pending status', () async {
    final bloc = TeacherBloc(DemoOrisonRepository());
    bloc.add(const TeacherLoaded('TCH-001'));
    await bloc.stream.firstWhere((state) => state is TeacherReady);
    final request = TeacherLeaveRequest(
      id: 'TL-TEST',
      type: 'Casual leave',
      from: DateTime.now().add(const Duration(days: 1)),
      to: DateTime.now().add(const Duration(days: 1)),
      reason: 'Personal appointment',
      status: 'Pending',
    );
    bloc.add(TeacherLeaveSubmitted(request));
    final ready = await bloc.stream.firstWhere(
      (state) => state is TeacherReady && state.message != null,
    ) as TeacherReady;
    expect(ready.data.leaveRequests.first.id, 'TL-TEST');
    expect(ready.data.leaveRequests.first.status, 'Pending');
    await bloc.close();
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:orison_parent_app/src/data/orison_repository.dart';
import 'package:orison_parent_app/src/models/app_session.dart';
import 'package:orison_parent_app/src/state/auth_bloc.dart';

void main() {
  test('valid demo credentials authenticate a parent', () async {
    final bloc = AuthBloc(DemoOrisonRepository());
    bloc.add(const SignInRequested('9876543210', '1234'));
    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<AuthLoading>(),
        isA<Authenticated>().having(
          (state) => state.session.role,
          'role',
          AppUserRole.parent,
        ),
      ]),
    );
    await bloc.close();
  });

  test('teacher number opens a teacher session', () async {
    final bloc = AuthBloc(DemoOrisonRepository());
    bloc.add(const SignInRequested('9876510001', '1234'));
    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<AuthLoading>(),
        isA<Authenticated>().having(
          (state) => state.session.role,
          'role',
          AppUserRole.teacher,
        ),
      ]),
    );
    await bloc.close();
  });

  test('director number opens a leadership session', () async {
    final bloc = AuthBloc(DemoOrisonRepository());
    bloc.add(const SignInRequested('9876510002', '1234'));
    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<AuthLoading>(),
        isA<Authenticated>().having(
          (state) => state.session.role,
          'role',
          AppUserRole.director,
        ),
      ]),
    );
    await bloc.close();
  });
}

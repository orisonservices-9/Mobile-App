import 'package:flutter_test/flutter_test.dart';
import 'package:orison_parent_app/src/data/orison_repository.dart';
import 'package:orison_parent_app/src/state/auth_bloc.dart';

void main() {
  test('valid demo credentials authenticate a parent', () async {
    final bloc = AuthBloc(DemoOrisonRepository());
    bloc.add(const SignInRequested('9876543210', '1234'));
    await expectLater(
        bloc.stream, emitsInOrder([isA<AuthLoading>(), isA<Authenticated>()]));
    await bloc.close();
  });
}

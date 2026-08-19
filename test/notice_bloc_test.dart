import 'package:flutter_test/flutter_test.dart';
import 'package:orison_parent_app/src/data/orison_repository.dart';
import 'package:orison_parent_app/src/state/parent_bloc.dart';

void main() {
  test('opening a notice marks it as read', () async {
    final bloc = ParentBloc(DemoOrisonRepository());
    final loaded = bloc.stream.firstWhere((state) => state is ParentReady);
    bloc.add(ParentLoaded());
    final initial = (await loaded) as ParentReady;
    final notice = initial.data.notices.firstWhere((item) => item.unread);

    final updated = bloc.stream.firstWhere(
      (state) =>
          state is ParentReady &&
          !state.data.notices.firstWhere((item) => item.id == notice.id).unread,
    );
    bloc.add(NoticeOpened(notice.id));

    final state = (await updated) as ParentReady;
    expect(
      state.data.notices.firstWhere((item) => item.id == notice.id).unread,
      isFalse,
    );
    await bloc.close();
  });
}

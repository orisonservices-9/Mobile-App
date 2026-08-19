import 'package:flutter_test/flutter_test.dart';
import 'package:orison_parent_app/src/data/orison_repository.dart';
import 'package:orison_parent_app/src/state/parent_bloc.dart';

void main() {
  test('school callback and app ticket are added to support history', () async {
    final bloc = ParentBloc(DemoOrisonRepository());
    final loaded = bloc.stream.firstWhere((state) => state is ParentReady);
    bloc.add(ParentLoaded());
    final initial = (await loaded) as ParentReady;
    final initialCount = initial.data.helpRequests.length;

    final callbackState = bloc.stream.firstWhere(
      (state) =>
          state is ParentReady &&
          state.message == 'School callback request submitted',
    );
    bloc.add(const HelpRequestSubmitted(
      kind: 'School callback',
      category: 'Academics & performance',
      description: 'Need guidance for improving Mathematics problem solving.',
      priority: 'Normal',
      preferredTime: '4:00 PM – 6:00 PM',
    ));
    final callback = (await callbackState) as ParentReady;
    expect(callback.data.helpRequests.length, initialCount + 1);
    expect(callback.data.helpRequests.first.status, 'Pending callback');

    final ticketState = bloc.stream.firstWhere(
      (state) =>
          state is ParentReady &&
          state.message == 'Orison app support ticket raised',
    );
    bloc.add(const HelpRequestSubmitted(
      kind: 'App support',
      category: 'Transport tracking',
      description: 'The live bus location does not refresh on my phone.',
      priority: 'Urgent',
      attachmentName: 'tracking-screen.png',
      preferredTime: '6:00 PM – 8:00 PM',
      parentName: 'Arjun Thorne',
      studentName: 'Marcus Thorne',
      mobile: '9876543210',
    ));
    final ticket = (await ticketState) as ParentReady;
    expect(ticket.data.helpRequests.first.status, 'Open');
    expect(ticket.data.helpRequests.first.priority, 'Urgent');
    expect(
        ticket.data.helpRequests.first.attachmentName, 'tracking-screen.png');
    expect(ticket.data.helpRequests.first.parentName, 'Arjun Thorne');
    expect(ticket.data.helpRequests.first.studentName, 'Marcus Thorne');
    expect(ticket.data.helpRequests.first.mobile, '9876543210');
    expect(ticket.data.helpRequests.first.preferredTime, '6:00 PM – 8:00 PM');
    await bloc.close();
  });
}

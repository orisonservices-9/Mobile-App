import 'package:flutter_test/flutter_test.dart';
import 'package:orison_parent_app/src/data/orison_repository.dart';
import 'package:orison_parent_app/src/state/parent_bloc.dart';

void main() {
  test('verified payment proof updates the fee status and balance', () async {
    final bloc = ParentBloc(DemoOrisonRepository());
    final loaded = bloc.stream.firstWhere((state) => state is ParentReady);
    bloc.add(ParentLoaded());
    await loaded;

    final updated = bloc.stream.firstWhere(
      (state) =>
          state is ParentReady &&
          state.message == 'Payment verified and fee status updated',
    );
    bloc.add(const FeePaymentProofSubmitted(
      feeId: 'fee-past-1',
      amount: 2000,
      transactionId: 'TXN12345678',
      proofName: 'payment-proof.jpg',
    ));

    final state = (await updated) as ParentReady;
    final fee = state.data.fees.firstWhere((item) => item.id == 'fee-past-1');
    expect(fee.status, 'Paid');
    expect(fee.balance, 0);
    expect(fee.transactionId, 'TXN12345678');
    await bloc.close();
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:orison_parent_app/src/data/parent_api_contract.dart';

void main() {
  test('parent API paths preserve child ownership scope', () {
    expect(
      ParentApiPaths.homeworkStatus('STU-42', 'HW-8'),
      '/api/parent/students/STU-42/homework/HW-8/status',
    );
    expect(
      ParentApiPaths.markNoticeRead('STU-42', 'NTC-9'),
      '/api/parent/students/STU-42/notices/NTC-9/read',
    );
    expect(
      ParentApiPaths.paymentProof('FEE-12'),
      '/api/parent/fees/FEE-12/payment-proof',
    );
  });
}

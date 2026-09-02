import 'package:flutter_test/flutter_test.dart';
import 'package:campustrust/utils/contact_utils.dart';

void main() {
  test('normalizes Ugandan mobile formats', () {
    expect(normalizeUgandaPhone('0772 123 456'), '256772123456');
    expect(normalizeUgandaPhone('+256 772 123 456'), '256772123456');
    expect(normalizeUgandaPhone('00256772123456'), '256772123456');
  });

  test('rejects malformed or non-Ugandan numbers', () {
    expect(normalizeUgandaPhone('not a number'), isNull);
    expect(normalizeUgandaPhone('+254 712 123 456'), isNull);
    expect(normalizeUgandaPhone('0772 123'), isNull);
  });
}

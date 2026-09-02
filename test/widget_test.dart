import 'package:flutter_test/flutter_test.dart';
import 'package:campustrust/main.dart';

void main() {
  testWidgets('CampusTrust presents the directory search', (tester) async {
    await tester.pumpWidget(const CampusTrustApp());
    expect(find.text('CampusTrust'), findsOneWidget);
    expect(find.text('Search for verified campus services...'), findsOneWidget);
  });
}

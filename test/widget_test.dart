import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campustrust/firebase_options.dart';
import 'package:campustrust/main.dart';

void main() {
  setUpAll(() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  });

  testWidgets('CampusTrust presents the directory search', (tester) async {
    await tester.pumpWidget(const CampusTrustApp());
    expect(find.text('CampusTrust'), findsOneWidget);
    expect(find.text('Search for verified campus services...'), findsOneWidget);
  });
}

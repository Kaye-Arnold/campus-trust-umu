import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:campustrust/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CampusTrust launches with its primary discovery controls', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('CampusTrust'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Search listed campus services...'), findsOneWidget);
  });
}

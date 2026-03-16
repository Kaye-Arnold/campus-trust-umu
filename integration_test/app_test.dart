import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Import your app's main entry point
import 'package:campustrust/main.dart' as app;

void main() {
  // This line ensures the test runs fully on your physical device
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full App Integrity Test', () {
    testWidgets('Verify app launches and review sheet opens', (tester) async {
      // 1. Boot up the app
      app.main();
      
      // Wait for the app to finish loading its initial frames and Firebase data
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // 2. Tap a Category
      // 🚨 REPLACE 'Plumbing' WITH A REAL CATEGORY ON YOUR HOME SCREEN
      final categoryCard = find.text('Electricians'); 
      await tester.tap(categoryCard);
      await tester.pumpAndSettle(); 

      // 3. Tap a Provider from the list
      // 🚨 REPLACE 'John Doe' WITH A REAL PROVIDER NAME UNDER THAT CATEGORY
      final providerCard = find.text('joana belle'); 
      await tester.tap(providerCard);
      await tester.pumpAndSettle();

      // 4. Tap the Write Review Button
      final writeReviewBtn = find.text('Write a Review'); 
      await tester.tap(writeReviewBtn);
      await tester.pumpAndSettle();

      // --- THE BOTTOM SHEET IS NOW OPEN ---

      // 5. Find the stars and tap the 5th star (Index 4)
      final stars = find.byIcon(Icons.star);
      await tester.tap(stars.at(4));
      await tester.pumpAndSettle();

      // 6. Type a comment into the text field
      final commentField = find.byType(TextField);
      await tester.enterText(commentField, 'Automated integration test review. Fast and reliable!');
      await tester.pumpAndSettle();

      // 7. Dismiss the keyboard so the buttons are fully visible
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // 8. The Smart Authentication Check & Hybrid Pause
      final normalSubmitButton = find.text('Submit Review');
      final googleSignInButton = find.text('Sign in with Google to Submit');

      if (tester.any(googleSignInButton)) {
        // The ghost pauses and hands you the controller!
        debugPrint('\n\n⚠️ QUICK! The ghost paused the test. You have 15 seconds to tap the Google button and select your account!\n\n');
        
        // Wait 15 seconds for you to manually complete the Google Sign-In popup
        await Future.delayed(const Duration(seconds: 15));
        await tester.pumpAndSettle();

        // The ghost takes the controller back! 
        // It checks if you successfully logged in and the 'Submit Review' button appeared.
        expect(find.text('Submit Review'), findsOneWidget, 
            reason: 'You took too long or the login failed! The Submit button did not appear.');
        
        // Tap the newly appeared Submit button
        await tester.tap(find.text('Submit Review'));
      } else {
        // You were already logged in! The ghost proceeds normally.
        await tester.tap(normalSubmitButton);
      }
      
      // Wait a few seconds for Firebase to process the live data submission
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // 9. The Integrity Check: Look for the success Snackbar!
      expect(find.text('Review submitted! Thank you.'), findsOneWidget);

      // Check if the Google button is on the screen instead of the Submit button
      if (tester.any(googleSignInButton)) {
        // We fail the test gracefully with a custom message!
        fail(
          '\n\n❌ TEST STOPPED: You are not logged in!\n'
          'Flutter cannot automate the native Google Sign-In popup.\n'
          'Please open the app normally on your phone, sign in manually, '
          'and then run this test again.\n\n'
        );
      } else {
        // We are logged in! Proceed as normal.
        await tester.tap(normalSubmitButton);
        
        // Wait a few seconds for Firebase to process the live data submission
        await Future.delayed(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        // 9. The Integrity Check: Look for the success Snackbar!
        expect(find.text('Review submitted! Thank you.'), findsOneWidget);
      }
    });
  });
}
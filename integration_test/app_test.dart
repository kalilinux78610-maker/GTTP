import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gttp/main.dart' as app;

void main() {
  // Initialize the Integration Test binding
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('GTTP E2E Tests', () {
    testWidgets('Login Flow Basic UI Interaction', (WidgetTester tester) async {
      // 1. Launch the app
      app.main();
      
      // Wait for animations/futures to settle on launch
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 2. Try to find the Login screen inputs
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;

      // Note: If the app skips login due to cached tokens, this test will need logic 
      // to handle the already-logged-in state (e.g. log out first).
      if (emailField.evaluate().isNotEmpty) {
        // Enter valid (or mock) credentials
        await tester.enterText(emailField, 'shreyanshvasava@efsouls.com');
        await tester.enterText(passwordField, 'shreyansh1');
        await tester.pumpAndSettle();

        // Find the 'Login' button and tap it
        final loginButton = find.text('Login');
        if (loginButton.evaluate().isNotEmpty) {
          await tester.tap(loginButton);
          
          // Wait for network requests or navigation to settle
          await tester.pumpAndSettle(const Duration(seconds: 3));
          
          // Handle the Verify OTP screen
          if (find.text('Verify OTP').evaluate().isNotEmpty) {
            final otpFields = find.byType(TextFormField);
            if (otpFields.evaluate().length >= 6) {
              final otpChars = '334750'.split('');
              for (int i = 0; i < 6; i++) {
                await tester.enterText(otpFields.at(i), otpChars[i]);
              }
              await tester.pumpAndSettle();

              // Tap the Verify OTP button (it uses CustomButton which wraps an ElevatedButton)
              final verifyButton = find.byType(ElevatedButton).last;
              await tester.tap(verifyButton);
              await tester.pumpAndSettle(const Duration(seconds: 4)); // Wait for Dashboard load
            }
          }
          
          // ── Smoke Test: Navigate through main tabs ──
          
          // 1. Verify we reached Dashboard (Dashboard tab is active by default)
          expect(find.text('Dashboard'), findsWidgets);

          // 2. Tap Notices Tab
          final noticesTab = find.text('Notices').last;
          if (noticesTab.evaluate().isNotEmpty) {
            await tester.tap(noticesTab);
            await tester.pumpAndSettle(const Duration(seconds: 2));
            expect(find.text('Notices'), findsWidgets);
          }

          // 3. Tap Courses Tab
          final coursesTab = find.text('Courses').last;
          if (coursesTab.evaluate().isNotEmpty) {
            await tester.tap(coursesTab);
            await tester.pumpAndSettle(const Duration(seconds: 3));
            expect(find.text('Courses'), findsWidgets);

            // 3.1 Test clicking a course if one exists
            final viewCourseButton = find.text('View Course').first;
            if (viewCourseButton.evaluate().isNotEmpty) {
              await tester.tap(viewCourseButton);
              await tester.pumpAndSettle(const Duration(seconds: 4)); // Wait for course details
              
              // 3.2 Navigate back using standard Back button icon
              final backButton = find.byType(IconButton).first;
              if (backButton.evaluate().isNotEmpty) {
                 await tester.tap(backButton);
                 await tester.pumpAndSettle(const Duration(seconds: 2));
              }
            }
          }

          // 4. Tap Profile Tab
          final profileTab = find.text('Profile').last;
          if (profileTab.evaluate().isNotEmpty) {
            await tester.tap(profileTab);
            await tester.pumpAndSettle(const Duration(seconds: 2));
            expect(find.text('Profile'), findsWidgets);
          }
          
          // 5. Return to Dashboard
          final dashboardTab = find.text('Dashboard').last;
          if (dashboardTab.evaluate().isNotEmpty) {
            await tester.tap(dashboardTab);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }
      }
    });
  });
}

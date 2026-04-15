// =============================================================================
// Smart Trolly — Genuine End-to-End Happy Path Test
// Focus: Real Registration → Real Login → Home → Orders → Logout
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smart_trolly/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Unique email per run to avoid "already registered" errors
  final testEmail =
      'genuine_user_${DateTime.now().millisecondsSinceEpoch}@smarttrolly.test';
  const testPassword = 'TestPassword123!';
  const testName = 'Genuine Tester';
  const testPhone = '9876543210';

  Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 500));
      if (tester.any(finder)) return;
    }
    expect(finder, findsWidgets,
        reason: 'Widget not found within ${timeout.inSeconds}s: $finder');
  }

  Future<void> safeTap(WidgetTester tester, Finder finder,
      {Duration settle = const Duration(seconds: 5)}) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder, warnIfMissed: false);
    await tester.pumpAndSettle(settle);
  }

  Future<void> fillField(
      WidgetTester tester, String label, String value) async {
    final field = find.widgetWithText(TextFormField, label);
    await tester.ensureVisible(field);
    await tester.tap(field, warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.enterText(field, value);
    await tester.pumpAndSettle();
  }

  group('Genuine User End-to-End Flow', () {
    testWidgets('1. Fresh App Launch & Navigate to Signup', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Wait for login screen
      await waitForWidget(tester, find.text('Welcome Back'));
      
      // Tap "Sign Up" flat button
      await safeTap(tester, find.text('Sign Up'));
      await waitForWidget(tester, find.text('Create Account'));
      
      expect(find.text('Create Account'), findsWidgets);
      printTestResult('Navigated to Signup');
    });

    testWidgets('2. Genuine User Registration (Firebase)', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // If we are somehow on Login, go to Signup
      if (tester.any(find.text('Welcome Back'))) {
        await safeTap(tester, find.text('Sign Up'));
        await waitForWidget(tester, find.text('Create Account'));
      }

      // Fill valid registration info
      await fillField(tester, 'Full Name', testName);
      await fillField(tester, 'Email', testEmail);
      await fillField(tester, 'Phone Number', testPhone);
      await fillField(tester, 'Password', testPassword);
      await fillField(tester, 'Confirm Password', testPassword);

      // Submit Registration
      await safeTap(
          tester, find.widgetWithText(ElevatedButton, 'Create Account'));

      // Wait for Firebase to process registration and route to Home
      await waitForWidget(tester, find.text('Smart Trolley'),
          timeout: const Duration(seconds: 30));

      expect(find.text('Smart Trolley'), findsWidgets);
      expect(find.text('Scan QR Code'), findsOneWidget);
      
      printTestResult('Registration Successful & Logged in -> Home screen');
    });

    testWidgets('3. Check My Orders', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));
      await waitForWidget(tester, find.text('Smart Trolley'));

      // Open Popup Menu
      await safeTap(tester, find.byIcon(Icons.more_vert));
      await safeTap(tester, find.text('My Orders'));
      await waitForWidget(tester, find.text('My Orders'));

      // New user = no orders
      expect(find.text('No orders yet'), findsOneWidget);
      
      // Go back Home
      await safeTap(tester, find.text('Start Shopping'));
      await waitForWidget(tester, find.text('Smart Trolley'));
      
      printTestResult('Orders screen verified as newly created user');
    });

    testWidgets('4. Logout the user gracefully', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));
      await waitForWidget(tester, find.text('Smart Trolley'));

      // Open Popup Menu and Logout
      await safeTap(tester, find.byIcon(Icons.more_vert));
      await safeTap(tester, find.text('Logout'));
      
      // Wait for Login Screen
      await waitForWidget(tester, find.text('Welcome Back'),
          timeout: const Duration(seconds: 20));

      expect(find.text('Welcome Back'), findsOneWidget);
      printTestResult('Logout successful');
    });

    testWidgets('5. Login existing genuine user', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      if (!tester.any(find.text('Welcome Back'))) {
        await waitForWidget(tester, find.text('Welcome Back'));
      }

      await fillField(tester, 'Email', testEmail);
      await fillField(tester, 'Password', testPassword);
      await safeTap(tester, find.widgetWithText(ElevatedButton, 'Login'));

      // Wait for Firebase to process login and route to Home
      await waitForWidget(tester, find.text('Smart Trolley'),
          timeout: const Duration(seconds: 30));

      expect(find.text('Smart Trolley'), findsWidgets);
      printTestResult('Re-Login successful -> End of E2E Flow ✅');
    });
  });
}

void printTestResult(String msg) {
  // ignore: avoid_print
  print('\n🎯 E2E CHECKPOINT: $msg\n');
}

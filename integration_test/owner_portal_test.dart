import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smart_trolly/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final testEmail = 'owner_${DateTime.now().millisecondsSinceEpoch}@smarttrolly.test';
  final testPassword = 'OwnerPassword123!';

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
      {Duration settle = const Duration(seconds: 3)}) async {
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

  group('Owner Portal End-to-End Flow', () {
    testWidgets('1. Launch App & Login as Owner', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Programmatically create the owner user to guarantee successful login
      try {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );
        if (cred.user != null) {
          await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
            'uid': cred.user!.uid,
            'email': testEmail,
            'name': 'Test Owner',
            'phoneNumber': '1234567890',
            'photoUrl': '',
            'role': 'owner',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'isActive': true,
          });
        }
      } catch (e) {
        // May already exist or throw, ignore
        print('Warning during user setup: $e');
      }

      // Wait for login screen
      await waitForWidget(tester, find.text('Welcome Back'));

      // If already logged in, skip login
      if (!tester.any(find.text('Owner Portal'))) {
        // Fill in Owner credentials
        await fillField(tester, 'Email', testEmail);
        await fillField(tester, 'Password', testPassword);

        // Tap Login
        await safeTap(tester, find.widgetWithText(ElevatedButton, 'Login'));
      }

      // Wait for Owner Dashboard
      await waitForWidget(tester, find.text('Owner Portal'),
          timeout: const Duration(seconds: 30));

      expect(find.text("Today's Sales"), findsWidgets);
      printTestResult('Logged in successfully and reached Owner Dashboard! ✅');
    });

    testWidgets('2. Navigate through Owner Tabs', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));
      
      // Wait for dashboard to load
      await waitForWidget(tester, find.text('Owner Portal'));

      // Tap Products Tab
      await safeTap(tester, find.byIcon(Icons.inventory_2_rounded));
      await waitForWidget(tester, find.text('Products'));
      expect(find.text('Products'), findsWidgets);
      printTestResult('Navigated to Products tab ✅');

      // Tap Customers Tab
      await safeTap(tester, find.byIcon(Icons.people_alt_rounded));
      await waitForWidget(tester, find.text('Customers'));
      expect(find.text('Customers'), findsWidgets);
      printTestResult('Navigated to Customers tab ✅');

      // Tap Analytics Tab
      await safeTap(tester, find.byIcon(Icons.bar_chart_rounded));
      await waitForWidget(tester, find.text('Analytics'));
      expect(find.text('Overview'), findsWidgets);
      printTestResult('Navigated to Analytics tab ✅');
      
      // Go back to Home
      await safeTap(tester, find.byIcon(Icons.dashboard_rounded));
    });

    testWidgets('3. Add a New Product', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 8));
      await waitForWidget(tester, find.text('Owner Portal'));

      // Tap Add Product Quick Action
      await safeTap(tester, find.text('Add Product'));
      await waitForWidget(tester, find.text('Add New Product'));

      // Fill Add Product Form
      await fillField(tester, 'Product Name', 'Automated Apple');
      await fillField(tester, 'Price (₹)', '120');
      await fillField(tester, 'Stock Quantity', '50');
      await fillField(tester, 'Weight/Volume', '1 kg');
      await fillField(tester, 'Description', 'Added via automated test');

      // Select Category
      final categoryDropdown = find.text('Select Category');
      await tester.ensureVisible(categoryDropdown);
      await safeTap(tester, categoryDropdown);
      await safeTap(tester, find.text('Fruits & Vegetables').last);

      // Save Product
      await safeTap(tester, find.widgetWithText(ElevatedButton, 'Save Product'));

      // Should show the QR code dialog
      await waitForWidget(tester, find.text('Close'), timeout: const Duration(seconds: 15));
      expect(find.text('Automated Apple'), findsWidgets);
      printTestResult('Product created and QR code generated! ✅');
      
      // Close QR dialog
      await safeTap(tester, find.text('Close'));
      
      printTestResult('Owner Portal E2E Flow Completed Successfully! 🚀');
    });
  });
}

void printTestResult(String msg) {
  // ignore: avoid_print
  print('\n🎯 E2E CHECKPOINT: $msg\n');
}

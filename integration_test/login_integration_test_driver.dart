import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:applanner/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:applanner/member/member_dashboard.dart';
import 'package:applanner/club_organizer/co_dashboard.dart';
import 'package:applanner/admin/admin_dashboard.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Integration Tests', () {
    Future<void> performLogin(WidgetTester tester, String email, String password) async {
      // Wait for splash screen
      await tester.pumpAndSettle();

      // Enter email
      final emailField = find.byKey(const ValueKey('emailField'));
      await tester.pumpAndSettle(); 
      expect(emailField, findsOneWidget);
      await tester.pumpAndSettle(); 
      await tester.enterText(emailField, email);

      // Enter password
      await tester.pumpAndSettle();
      final passwordField = find.byKey(const ValueKey('passwordField'));
      await tester.pumpAndSettle();
      expect(passwordField, findsOneWidget);
      await tester.pumpAndSettle(); 
      await tester.enterText(passwordField, password);

      // Tap login
      await tester.pumpAndSettle();
      final loginButton = find.byKey(const ValueKey('loginButton'));
      await tester.pumpAndSettle();
      expect(loginButton, findsOneWidget);
      await tester.pumpAndSettle(); 
      await tester.tap(loginButton);

      // Wait for navigation
      await tester.pumpAndSettle();
    }

    testWidgets('Student login redirects to MemberMenu', (tester) async {
      app.main(); // run the app
      await performLogin(tester, 'student1@uni.edu', 'abc123');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('member_dashboard')), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('Club Organizer login redirects to ClubOrgMenu', (tester) async {
      app.main();
      await performLogin(tester, 'cluborg1@uni.edu', 'abc123');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('cluborg_dashboard')), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('Admin login redirects to AdminMenu', (tester) async {
      app.main();
      await performLogin(tester, 'admin1@uni.edu', 'abc123');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('admin_dashboard')), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });
}

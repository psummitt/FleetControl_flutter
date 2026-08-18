import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fleetcontrol_flutter/main.dart';

void main() {
  testWidgets('FleetControl app renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FleetControlApp());
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('FleetControl'), findsWidgets);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('Login form validates empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(const FleetControlApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Enter email'), findsOneWidget);
  });

  testWidgets('Login form shows register link', (WidgetTester tester) async {
    await tester.pumpWidget(const FleetControlApp());
    await tester.pumpAndSettle();

    expect(find.text('Need an account? Register'), findsOneWidget);
  });

  testWidgets('Password visibility toggle works', (WidgetTester tester) async {
    await tester.pumpWidget(const FleetControlApp());
    await tester.pumpAndSettle();

    final toggleButton = find.byIcon(Icons.visibility);
    expect(toggleButton, findsOneWidget);

    await tester.tap(toggleButton);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });

  testWidgets('App has correct title', (WidgetTester tester) async {
    await tester.pumpWidget(const FleetControlApp());
    await tester.pumpAndSettle();

    expect(find.text('FleetControl'), findsWidgets);
  });
}

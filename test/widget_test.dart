// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:fleetcontrol_flutter/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: This test might require Firebase mocking if you want to test deep logic,
    // but for a basic UI smoke test it should load the MaterialApp.
    await tester.pumpWidget(const MyApp());

    // Verify that the title is present.
    expect(find.text('FleetControl'), findsWidgets);

    // Verify that we are on the sign-in page by default.
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}

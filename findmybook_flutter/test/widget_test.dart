// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_library_app/src/app.dart';

void main() {
  testWidgets('App shows Smart Library app bar', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // AppBar with title 'Smart Library' should be present immediately.
    expect(find.text('Smart Library'), findsOneWidget);

    // The app's data source uses a small artificial delay (250ms). Wait for it
    // to complete so no timers remain pending after the test finishes.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  });
}

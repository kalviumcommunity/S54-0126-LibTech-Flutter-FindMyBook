import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "package:smart_library_app/shared/widgets/empty_state.dart";

void main() {
  testWidgets("EmptyState renders title and subtitle", (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EmptyState(
          icon: Icons.book,
          title: "No data",
          subtitle: "Try again later",
        ),
      ),
    );

    expect(find.text("No data"), findsOneWidget);
    expect(find.text("Try again later"), findsOneWidget);
  });
}

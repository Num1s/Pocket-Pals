import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('CapyPalApp renders and responds to user action', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const CapyPalApp());

    // Verify initial UI elements
    expect(find.text('CAPY PAL'), findsOneWidget);
    expect(find.text('MILO'), findsOneWidget);
    expect(find.text('FEED'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('SLEEP'), findsOneWidget);

    // Tap FEED button
    await tester.tap(find.text('FEED'));
    await tester.pump();

    // Verify mood changed to eating ('nom nom, so yummy!')
    expect(find.text('nom nom, so yummy!'), findsOneWidget);

    // Clean up timers by unmounting app
    await tester.pumpWidget(const SizedBox());
  });
}

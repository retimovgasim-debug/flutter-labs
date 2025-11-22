import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:password_generator/main.dart';

void main() {
  testWidgets('Password generator app launches', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app shows the main screen elements
    expect(find.text('Генератор паролей'), findsOneWidget);
    expect(find.text('Сгенерированный пароль'), findsOneWidget);
    expect(find.text('СГЕНЕРИРОВАТЬ'), findsOneWidget);
  });

  testWidgets('Generate password button shows result', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tap the generate button
    await tester.tap(find.text('СГЕНЕРИРОВАТЬ'));
    await tester.pump();

    // Verify that placeholder text is replaced with actual password
    expect(find.text('Нажмите "Сгенерировать"'), findsNothing);
  });
}
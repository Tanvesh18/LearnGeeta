import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learngeetagames/core/widgets/app_text_input.dart';

void main() {
  testWidgets('AppTextInput toggles obscured text', (tester) async {
    final controller = TextEditingController(text: 'Secret123!');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextInput(
            controller: controller,
            label: 'Password',
            obscureText: true,
          ),
        ),
      ),
    );

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).obscureText,
      isTrue,
    );

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).obscureText,
      isFalse,
    );
  });
}

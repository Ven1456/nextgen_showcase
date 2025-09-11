import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextgen_showcase/nextgen_showcase.dart';

void main() {
  testWidgets('controller shows and hides overlay', (WidgetTester tester) async {
    final GlobalKey buttonKey = GlobalKey();
    final NextgenShowcaseController controller = NextgenShowcaseController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ElevatedButton(key: buttonKey, onPressed: () {}, child: const Text('Tap')),
          ),
        ),
      ),
    );

    controller.show(
      context: tester.element(find.byType(ElevatedButton)),
      targetKey: buttonKey,
      title: 'Title',
      description: 'Description',
    );
    await tester.pump();

    expect(find.text('Title'), findsOneWidget);

    controller.hide();
    await tester.pump();

    expect(find.text('Title'), findsNothing);
  });
}



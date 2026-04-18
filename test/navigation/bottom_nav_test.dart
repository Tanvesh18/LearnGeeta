import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learngeetagames/navigation/bottom_nav.dart';

void main() {
  testWidgets('BottomNav preserves screen state with IndexedStack', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BottomNav(
          screens: const [
            _CounterScreen(label: 'Home'),
            Text('Learn'),
            Text('Play'),
            Text('Progress'),
          ],
        ),
      ),
    );

    expect(find.text('Count 0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('Count 1'), findsOneWidget);

    await tester.tap(find.text('Learn'));
    await tester.pump();
    await tester.tap(find.text('Home'));
    await tester.pump();

    expect(find.text('Count 1'), findsOneWidget);
  });
}

class _CounterScreen extends StatefulWidget {
  const _CounterScreen({required this.label});

  final String label;

  @override
  State<_CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<_CounterScreen> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Count $count')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            count += 1;
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

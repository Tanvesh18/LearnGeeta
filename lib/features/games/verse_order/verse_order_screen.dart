import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import 'package:flutter/foundation.dart';

class VerseOrderScreen extends StatefulWidget {
  const VerseOrderScreen({super.key});

  @override
  State<VerseOrderScreen> createState() => _VerseOrderScreenState();
}

class _VerseOrderScreenState extends State<VerseOrderScreen> {
  final List<String> correctOrder = [
    'कर्मण्येवाधिकारस्ते',
    'मा फलेषु कदाचन',
    'मा कर्मफलहेतुर्भूः',
    'मा ते सङ्गोऽस्त्वकर्मणि',
  ];

  late List<String> shuffled;

  @override
  void initState() {
    super.initState();
    shuffled = List.from(correctOrder)..shuffle();
  }

  void _checkOrder() {
    if (listEquals(shuffled, correctOrder)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correct Order! 🎉')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Try Again 🙏')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verse Order')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Arrange the shloka in correct order',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = shuffled.removeAt(oldIndex);
                    shuffled.insert(newIndex, item);
                  });
                },
                children: [
                  for (final line in shuffled)
                    Card(
                      key: ValueKey(line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(line, textAlign: TextAlign.center),
                      ),
                    ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _checkOrder,
              child: const Text('Check Order'),
            ),
          ],
        ),
      ),
    );
  }
}
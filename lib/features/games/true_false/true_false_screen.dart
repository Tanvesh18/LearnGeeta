import 'dart:math';
import 'package:flutter/material.dart';

class TrueFalseScreen extends StatefulWidget {
  const TrueFalseScreen({super.key});

  @override
  State<TrueFalseScreen> createState() => _TrueFalseScreenState();
}

class _TrueFalseScreenState extends State<TrueFalseScreen> {
  // Expanded pool of Gita-based statements
  final List<String> _questions = [
    'Bhagavad Gita teaches detachment from the results of actions.',
    'According to the Gita, avoiding all work is the best path.',
    'Krishna spoke the Bhagavad Gita to Arjuna on the battlefield of Kurukshetra.',
    'The Gita says only monks can reach the Supreme.',
    'Bhagavad Gita is part of the Mahabharata.',
    'The Gita encourages doing one’s swadharma (own duty) sincerely.',
    'According to the Gita, controlling the mind is compared to controlling the wind.',
    'Bhakti (devotion) is mentioned in the Gita as a path to the Divine.',
  ];

  // Match each statement to its correct answer
  late final Map<String, bool> _answers = {
    _questions[0]: true,
    _questions[1]: false,
    _questions[2]: true,
    _questions[3]: false,
    _questions[4]: true,
    _questions[5]: true,
    _questions[6]: true,
    _questions[7]: true,
  };

  late String question;
  late bool correctAnswer;
  String? result;

  @override
  void initState() {
    super.initState();
    _pickRandomQuestion();
  }

  void _pickRandomQuestion() {
    final random = Random();
    question = _questions[random.nextInt(_questions.length)];
    correctAnswer = _answers[question] ?? false;
    result = null;
  }

  void _answer(bool choice) {
    setState(() {
      final isCorrect = choice == correctAnswer;
      result = isCorrect ? 'Correct 🎉' : 'Wrong 🙏';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('True or False')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _answer(true),
                    child: const Text('True'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _answer(false),
                    child: const Text('False'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (result != null) ...[
              Text(
                result!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    _pickRandomQuestion();
                  });
                },
                child: const Text('Next Question'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
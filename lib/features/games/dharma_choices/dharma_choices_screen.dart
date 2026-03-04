import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'models/dharma_model.dart';

class DharmaChoicesScreen extends StatefulWidget {
  const DharmaChoicesScreen({super.key});

  @override
  State<DharmaChoicesScreen> createState() => _DharmaChoicesScreenState();
}

class _DharmaChoicesScreenState extends State<DharmaChoicesScreen> {
  late GameState gameState;
  bool _isLoading = true;
  late LifeSituation currentSituation;
  int? selectedChoiceIndex;
  bool hasAnswered = false;
  bool isCorrect = false;

  late ConfettiController _confettiController;
  final Set<String> _seenSituations = {};

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    final prefs = await SharedPreferences.getInstance();
    gameState = GameState(
      level: prefs.getInt('dharmaLevel') ?? 1,
      score: prefs.getInt('dharmaScore') ?? 0,
      streak: prefs.getInt('dharmaStreak') ?? 0,
      maxStreak: prefs.getInt('dharmaMaxStreak') ?? 0,
    );
    _seenSituations.clear();
    _loadNewSituation();
    setState(() => _isLoading = false);
  }

  void _loadNewSituation() {
    if (_seenSituations.length == situationDatabase.length) {
      _seenSituations.clear();
    }

    final remaining = situationDatabase
        .where((s) => !_seenSituations.contains(s.title))
        .toList();

    final targetDifficulty = _getDifficultyForLevel(gameState.level);
    final matching = remaining
        .where((s) => s.difficulty == targetDifficulty || remaining.length <= 2)
        .toList();

    if (matching.isEmpty) {
      currentSituation = remaining[0];
    } else {
      currentSituation = matching[0];
    }

    _seenSituations.add(currentSituation.title);
    selectedChoiceIndex = null;
    hasAnswered = false;
    isCorrect = false;
  }

  String _getDifficultyForLevel(int level) {
    if (level <= 2) return 'beginner';
    if (level <= 5) return 'intermediate';
    return 'advanced';
  }

  void _selectChoice(int index) {
    if (hasAnswered) return;

    final choice = currentSituation.choices[index];
    final correct = choice.isCorrect;

    setState(() {
      selectedChoiceIndex = index;
      hasAnswered = true;
      isCorrect = correct;

      if (correct) {
        int points = 15 + (gameState.streak >= 3 ? 10 : 0);
        gameState = gameState.copyWith(
          score: gameState.score + points,
          streak: gameState.streak + 1,
          maxStreak: max(gameState.maxStreak, gameState.streak + 1),
          level: gameState.level + 1,
        );
        _confettiController.play();
      } else {
        gameState = gameState.copyWith(streak: 0);
      }
    });

    _saveGameState();
    Future.delayed(const Duration(milliseconds: 800), _showResultDialog);
  }

  void _showResultDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isCorrect ? 'Perfect Wisdom! 🧘' : 'Learning Moment',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(height: 20),
                if (isCorrect)
                  Text(
                    '+${15 + (gameState.streak >= 3 ? 10 : 0)} XP earned',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  const Text(
                    'Try to understand the teaching',
                    style: TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bhagavad Gita ${currentSituation.gitaTeaching.chapter}.${currentSituation.gitaTeaching.verse}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentSituation.gitaTeaching.teaching,
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentSituation.gitaTeaching.explanation,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => _loadNewSituation());
                    },
                    child: const Text('Next Situation'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dharmaScore', gameState.score);
    await prefs.setInt('dharmaStreak', gameState.streak);
    await prefs.setInt('dharmaLevel', gameState.level);
    await prefs.setInt('dharmaMaxStreak', gameState.maxStreak);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dharma Choices'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'L${gameState.level}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  '${gameState.score}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.shade50,
                  Colors.blue.shade50,
                  Colors.green.shade50,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '🔥 ${gameState.streak}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(Max: ${gameState.maxStreak})',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Chip(
                        label: Text(
                          _getDifficultyForLevel(gameState.level).toUpperCase(),
                        ),
                        backgroundColor: Colors.orange.shade200,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // situation title
                  Text(
                    currentSituation.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // scenario
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      currentSituation.scenario,
                      style: const TextStyle(fontSize: 15, height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // choices
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentSituation.choices.length,
                      itemBuilder: (context, idx) {
                        final choice = currentSituation.choices[idx];
                        final isSelected = selectedChoiceIndex == idx;

                        Color bgColor = Colors.white;
                        if (hasAnswered && isSelected) {
                          bgColor = choice.isCorrect
                              ? Colors.green.shade100
                              : Colors.red.shade100;
                        } else if (hasAnswered && choice.isCorrect) {
                          bgColor = Colors.green.shade100;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: !hasAnswered
                                ? () => _selectChoice(idx)
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? (choice.isCorrect
                                            ? Colors.green
                                            : Colors.red)
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      choice.text,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            hasAnswered &&
                                                !choice.isCorrect &&
                                                isSelected
                                            ? Colors.red
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  if (hasAnswered && choice.isCorrect)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                  else if (hasAnswered &&
                                      isSelected &&
                                      !choice.isCorrect)
                                    const Icon(Icons.close, color: Colors.red),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }
}

int max(int a, int b) => a > b ? a : b;

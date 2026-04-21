import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../../core/app_dependencies.dart';
import 'models/shloka_speedrun_model.dart';

class ShlokaSpeedRunScreen extends StatefulWidget {
  const ShlokaSpeedRunScreen({super.key});

  @override
  State<ShlokaSpeedRunScreen> createState() => _ShlokaSpeedRunScreenState();
}

class _ShlokaSpeedRunScreenState extends State<ShlokaSpeedRunScreen> {
  late GameState gameState;
  late List<SpeedRunQuestion> currentRound;
  int currentQuestionIndex = 0;
  int roundScore = 0;
  int roundCombo = 0;
  late int timeRemaining;
  Timer? gameTimer;
  bool isReady = false;
  bool gameOver = false;
  bool answered = false;
  int? selectedIndex;

  static const int GAME_DURATION = 45; // 45 seconds

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    final prefs = await SharedPreferences.getInstance();
    final speedRunJson = prefs.getString('speedRunGameState');

    if (speedRunJson != null) {
      try {
        final data = jsonDecode(speedRunJson) as Map<String, dynamic>;
        gameState = GameState.fromJson(data);
      } catch (_) {
        gameState = GameState(level: 1, score: 0, streak: 0, maxStreak: 0);
      }
    } else {
      gameState = GameState(level: 1, score: 0, streak: 0, maxStreak: 0);
    }

    _startNewRound();

    setState(() {
      isReady = true;
    });
  }

  void _startNewRound() {
    timeRemaining = GAME_DURATION;
    roundScore = 0;
    roundCombo = 0;
    gameOver = false;
    answered = false;
    currentQuestionIndex = 0;
    selectedIndex = null;

    // Shuffle and select questions based on difficulty
    currentRound =
        speedRunDatabase.where((q) => q.difficulty <= gameState.level).toList()
          ..shuffle();

    if (currentRound.length > 20) {
      currentRound = currentRound.take(20).toList();
    }

    if (mounted) {
      setState(() {});
    }
    Future.microtask(() => _startTimer());
  }

  void _startTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        timeRemaining--;
        if (timeRemaining <= 0) {
          _endRound();
        }
      });
    });
  }

  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('speedRunGameState', jsonEncode(gameState.toJson()));
  }

  void _answerQuestion(int index) {
    if (answered || gameOver) return;

    setState(() {
      selectedIndex = index;
      answered = true;

      final isCorrect =
          index == currentRound[currentQuestionIndex].correctOptionIndex;

      if (isCorrect) {
        final earnedXp = 10 * gameState.comboMultiplier;
        roundScore += earnedXp;
        roundCombo++;
        gameState.streak++;
        unawaited(AppDependencies.xpService.awardXp(earnedXp));

        if (roundCombo % 5 == 0) {
          gameState.comboMultiplier = (gameState.comboMultiplier % 3) + 1;
        }

        if (gameState.streak > gameState.maxStreak) {
          gameState.maxStreak = gameState.streak;
        }

        if (gameState.streak % 5 == 0) {
          gameState.level = (gameState.level % 5) + 1;
        }
      } else {
        gameState.streak = 0;
        gameState.comboMultiplier = 1;
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && !gameOver) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < currentRound.length - 1) {
      setState(() {
        currentQuestionIndex++;
        answered = false;
        selectedIndex = null;
      });
    } else {
      _endRound();
    }
  }

  void _endRound() {
    gameTimer?.cancel();

    setState(() {
      gameOver = true;
      gameState.score += roundScore;
    });

    _saveGameState();

    Future.delayed(const Duration(milliseconds: 500), () {
      _showRoundSummary();
    });
  }

  void _showRoundSummary() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🏁 Round Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '$roundScore',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Points', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      '$roundCombo',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Correct',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${currentRound.length - roundCombo}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Incorrect',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${gameState.streak}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const Text(
                      'Streak',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Level: ${gameState.level}'),
                  Text('Total Score: ${gameState.score}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startNewRound();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Shloka Speed Run'),
          backgroundColor: Colors.orange.shade700,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (currentRound.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Shloka Speed Run'),
          backgroundColor: Colors.orange.shade700,
        ),
        body: const Center(child: Text('No questions available.')),
      );
    }

    final currentQuestion = currentRound[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / currentRound.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shloka Speed Run'),
        backgroundColor: Colors.orange,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '⏱️ ${timeRemaining}s',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: timeRemaining <= 10 ? Colors.red : Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade50, Colors.red.shade50],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress Bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Question ${currentQuestionIndex + 1}/${currentRound.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Combo: x${gameState.comboMultiplier}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Question Card
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade600,
                              Colors.red.shade600,
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getQuestionTypeLabel(currentQuestion.type),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              currentQuestion.question,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    // Answer Options
                    ...List.generate(
                      currentQuestion.options.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildSpeedRunOptionButton(
                          index,
                          currentQuestion,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Score Display
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('Round Score: $roundScore'),
                          Text('Correct: $roundCombo'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getQuestionTypeLabel(String type) {
    switch (type) {
      case 'meaning':
        return '📚 Meaning';
      case 'missing_word':
        return '❓ Fill in the Blank';
      case 'chapter':
        return '📖 Chapter';
      default:
        return 'Question';
    }
  }

  Widget _buildSpeedRunOptionButton(int index, SpeedRunQuestion question) {
    final isSelected = selectedIndex == index;
    final isAnswered = answered;
    final isCorrectOption = index == question.correctOptionIndex;

    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade300;

    if (isAnswered) {
      if (isCorrectOption) {
        backgroundColor = Colors.green.withOpacity(0.2);
        borderColor = Colors.green;
      } else if (isSelected) {
        backgroundColor = Colors.red.withOpacity(0.2);
        borderColor = Colors.red;
      }
    }

    return GestureDetector(
      onTap: answered ? null : () => _answerQuestion(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isAnswered && isCorrectOption
                    ? Colors.green
                    : isAnswered && isSelected
                    ? Colors.red
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isAnswered && (isCorrectOption || isSelected)
                        ? Colors.white
                        : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                question.options[index],
                softWrap: true,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isAnswered && (isCorrectOption || (isSelected))
                      ? Colors.black87
                      : Colors.black54,
                ),
              ),
            ),
            if (isAnswered && selectedIndex != null && isCorrectOption)
              const Icon(Icons.check, color: Colors.green, size: 18)
            else if (isAnswered && selectedIndex != null && isSelected)
              const Icon(Icons.close, color: Colors.red, size: 18),
          ],
        ),
      ),
    );
  }
}

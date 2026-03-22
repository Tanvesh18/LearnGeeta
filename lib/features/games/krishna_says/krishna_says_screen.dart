import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/krishna_says_model.dart';

class KrishnaSaysScreen extends StatefulWidget {
  const KrishnaSaysScreen({super.key});

  @override
  State<KrishnaSaysScreen> createState() => _KrishnaSaysScreenState();
}

class _KrishnaSaysScreenState extends State<KrishnaSaysScreen>
    with TickerProviderStateMixin {
  late GameState gameState;
  late int currentQuestionIndex;
  late WisdomQuestion currentQuestion;
  bool isReady = false;
  bool answered = false;
  bool isCorrect = false;
  int? selectedIndex;
  late AnimationController _animationController;
  late AnimationController _resultAnimationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _initializeGame();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _resultAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    final prefs = await SharedPreferences.getInstance();
    final levelJson = prefs.getString('krishnaSaysGameState');

    if (levelJson != null) {
      try {
        final data = jsonDecode(levelJson) as Map<String, dynamic>;
        gameState = GameState.fromJson(data);
      } catch (_) {
        gameState = GameState(level: 1, score: 0, streak: 0, maxStreak: 0);
      }
    } else {
      gameState = GameState(level: 1, score: 0, streak: 0, maxStreak: 0);
    }

    _loadNextQuestion();

    setState(() {
      isReady = true;
    });
  }

  void _loadNextQuestion() {
    final difficultyQuestions = wisdomDatabase
        .where((q) => q.difficulty == gameState.level)
        .toList();

    if (difficultyQuestions.isEmpty) {
      currentQuestionIndex = 0;
      currentQuestion = wisdomDatabase[0];
    } else {
      currentQuestionIndex =
          DateTime.now().millisecond % difficultyQuestions.length;
      currentQuestion = difficultyQuestions[currentQuestionIndex];
    }

    answered = false;
    selectedIndex = null;
    setState(() {});
  }

  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'krishnaSaysGameState',
      jsonEncode(gameState.toJson()),
    );
  }

  void _answerQuestion(int index) {
    if (answered) return;

    setState(() {
      selectedIndex = index;
      answered = true;
      isCorrect = index == currentQuestion.correctOptionIndex;

      if (isCorrect) {
        gameState.score += 10;
        gameState.streak++;
        if (gameState.streak > gameState.maxStreak) {
          gameState.maxStreak = gameState.streak;
        }
        if (gameState.streak % 3 == 0) {
          gameState.level = (gameState.level % 5) + 1;
        }
      } else {
        gameState.streak = 0;
      }

      _saveGameState();
    });

    _resultAnimationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _showResultDialog();
        }
      });
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text(
              isCorrect ? '✅ Correct!' : '❌ Incorrect',
              style: TextStyle(
                color: isCorrect ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Correct Answer: ${currentQuestion.options[currentQuestion.correctOptionIndex]}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bhagavad Gita ${currentQuestion.chapter}.${currentQuestion.verse}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"${currentQuestion.shloka}"',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentQuestion.explanation,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'XP Earned: ${isCorrect ? '+10' : '+0'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Level: ${gameState.level}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadNextQuestion();
            },
            child: const Text('Next Question'),
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
          title: const Text('Krishna Says'),
          backgroundColor: Colors.purple.shade700,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Krishna Says'),
        backgroundColor: Colors.purple.shade700,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'L${gameState.level}',
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                ),
                Text(
                  '${gameState.score}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade50, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                                  Colors.purple.shade600,
                                  Colors.blue.shade600,
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Question',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.white70),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  currentQuestion.question,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Answer Options
                        ...List.generate(
                          currentQuestion.options.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildOptionButton(index),
                          ),
                        ),
                        const Spacer(),
                        // Streak Info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Current Streak: ${gameState.streak}'),
                              Text('Best Streak: ${gameState.maxStreak}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(int index) {
    final isSelected = selectedIndex == index;
    final isAnswered = answered;
    final isCorrectOption = index == currentQuestion.correctOptionIndex;

    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade300;

    if (isAnswered) {
      if (isCorrectOption) {
        backgroundColor = Colors.green.withOpacity(0.2);
        borderColor = Colors.green;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.withOpacity(0.2);
        borderColor = Colors.red;
      }
    }

    return ScaleTransition(
      scale: isSelected
          ? Tween<double>(begin: 1.0, end: 1.05).animate(
              CurvedAnimation(
                parent: _resultAnimationController,
                curve: Curves.elasticOut,
              ),
            )
          : AlwaysStoppedAnimation(1.0),
      child: GestureDetector(
        onTap: answered ? null : () => _answerQuestion(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
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
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isAnswered && (isCorrectOption || isSelected)
                          ? Colors.white
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  currentQuestion.options[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color:
                        isAnswered &&
                            (isCorrectOption || (isSelected && !isCorrect))
                        ? Colors.black87
                        : Colors.black54,
                  ),
                ),
              ),
              if (isAnswered && selectedIndex != null && isCorrectOption)
                const Icon(Icons.check, color: Colors.green, size: 20)
              else if (isAnswered &&
                  selectedIndex != null &&
                  isSelected &&
                  !isCorrect)
                const Icon(Icons.close, color: Colors.red, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

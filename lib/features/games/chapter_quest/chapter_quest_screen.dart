import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import '../../../core/app_dependencies.dart';
import '../../../core/constants/colors.dart';
import 'models/quest_model.dart';

class ChapterQuestScreen extends StatefulWidget {
  const ChapterQuestScreen({super.key});

  @override
  State<ChapterQuestScreen> createState() => _ChapterQuestScreenState();
}

class _ChapterQuestScreenState extends State<ChapterQuestScreen> {
  late GameState gameState;
  bool _isLoading = true;
  late QuestData currentQuest;
  int? selectedOptionIndex;
  bool hasAnswered = false;
  bool isCorrect = false;
  int _lastEarnedXp = 0;
  int _timeLeft = 25;
  Timer? _timer;

  late ConfettiController _confettiController;
  final Set<String> _seenQuests = {};

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _initializeGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    final prefs = await SharedPreferences.getInstance();
    gameState = GameState(
      level: prefs.getInt('chapterQuestLevel') ?? 1,
      score: prefs.getInt('chapterQuestScore') ?? 0,
      streak: prefs.getInt('chapterQuestStreak') ?? 0,
      maxStreak: prefs.getInt('chapterQuestMaxStreak') ?? 0,
    );
    _seenQuests.clear();
    _loadNewQuest();
    setState(() => _isLoading = false);
  }

  void _loadNewQuest() {
    if (_seenQuests.length == questDatabase.length) {
      _seenQuests.clear();
    }

    final remaining = questDatabase
        .where((q) => !_seenQuests.contains(q.question))
        .toList();

    final targetDifficulty = _getDifficultyForLevel(gameState.level);
    final matching = remaining
        .where((q) => q.difficulty == targetDifficulty || remaining.length <= 2)
        .toList();

    if (matching.isEmpty) {
      currentQuest = remaining[0];
    } else {
      currentQuest = matching[0];
    }

    _seenQuests.add(currentQuest.question);
    selectedOptionIndex = null;
    hasAnswered = false;
    isCorrect = false;
    _timeLeft = 25;
    _startTimer();
  }

  String _getDifficultyForLevel(int level) {
    if (level <= 3) return 'easy';
    if (level <= 7) return 'medium';
    return 'hard';
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        _checkAnswer();
      }
    });
  }

  void _selectOption(int index) {
    if (hasAnswered) return;

    final selectedChapter = currentQuest.options[index].chapter;
    final correct = selectedChapter == currentQuest.correctChapter;

    setState(() {
      selectedOptionIndex = index;
      hasAnswered = true;
      isCorrect = correct;

      if (correct) {
        int points = 15 + (gameState.streak >= 3 ? 10 : 0);
        _lastEarnedXp = points;
        gameState = gameState.copyWith(
          score: gameState.score + points,
          streak: gameState.streak + 1,
          maxStreak: max(gameState.maxStreak, gameState.streak + 1),
          level: gameState.level + 1,
        );
        _confettiController.play();
        unawaited(AppDependencies.xpService.awardXp(points));
      } else {
        _lastEarnedXp = 0;
        gameState = gameState.copyWith(streak: 0);
      }
    });

    _timer?.cancel();
    _saveGameState();
    Future.delayed(const Duration(milliseconds: 800), _showResultDialog);
  }

  void _checkAnswer() {
    if (hasAnswered) return;

    setState(() {
      hasAnswered = true;
      isCorrect = false;
      _lastEarnedXp = 0;
      gameState = gameState.copyWith(streak: 0);
    });

    _timer?.cancel();
    _saveGameState();
    Future.delayed(const Duration(milliseconds: 800), _showResultDialog);
  }

  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('chapterQuestLevel', gameState.level);
    await prefs.setInt('chapterQuestScore', gameState.score);
    await prefs.setInt('chapterQuestStreak', gameState.streak);
    await prefs.setInt('chapterQuestMaxStreak', gameState.maxStreak);
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
                  isCorrect ? 'Chapter Master! 📚' : 'Study More',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(height: 20),
                if (isCorrect)
                  Text(
                    '+$_lastEarnedXp XP earned',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Text(
                    'Correct chapter: ${currentQuest.correctChapter}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.saffron,
                    ),
                  ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentQuest.explanation,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _loadNewQuest();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.saffron,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Next Quest'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chapter Quest'),
        backgroundColor: AppColors.saffron,
        foregroundColor: Colors.white,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Level ${gameState.level}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E8), Color(0xFFF1F8E9)],
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Timer and score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _timeLeft <= 10 ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '$_timeLeft s',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Score: ${gameState.score}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Question
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          currentQuest.question,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.saffron,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            currentQuest.teaching,
                            style: const TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Options
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentQuest.options.length,
                      itemBuilder: (context, index) {
                        final option = currentQuest.options[index];
                        final isSelected = selectedOptionIndex == index;
                        final isCorrectOption =
                            option.chapter == currentQuest.correctChapter;

                        Color? backgroundColor;
                        if (hasAnswered) {
                          if (isCorrectOption) {
                            backgroundColor = Colors.green.shade100;
                          } else if (isSelected && !isCorrect) {
                            backgroundColor = Colors.red.shade100;
                          } else {
                            backgroundColor = Colors.white;
                          }
                        } else if (isSelected) {
                          backgroundColor = AppColors.saffron.withValues(
                            alpha: 0.1,
                          );
                        } else {
                          backgroundColor = Colors.white;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: hasAnswered
                                  ? null
                                  : () => _selectOption(index),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: hasAnswered && isCorrectOption
                                        ? Colors.green
                                        : Colors.grey.shade300,
                                    width: hasAnswered && isCorrectOption
                                        ? 2
                                        : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Chapter ${option.chapter}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: hasAnswered && isCorrectOption
                                            ? Colors.green.shade800
                                            : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        option.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: hasAnswered && isCorrectOption
                                              ? Colors.green.shade700
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    if (hasAnswered && isCorrectOption)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    else if (hasAnswered &&
                                        isSelected &&
                                        !isCorrect)
                                      const Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                      ),
                                  ],
                                ),
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

            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [Colors.green, Colors.lightGreen, Colors.teal],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

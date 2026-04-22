import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

import '../../../core/app_dependencies.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/game_stats.dart';
import '../../../features/progress/repositories/game_stats_repository.dart';
import 'models/true_false_model.dart';

class TrueFalseScreen extends StatefulWidget {
  const TrueFalseScreen({super.key});

  @override
  State<TrueFalseScreen> createState() => _TrueFalseScreenState();
}

class _TrueFalseScreenState extends State<TrueFalseScreen> {
  // replaced by questionDatabase from model file

  late String question;
  late bool correctAnswer;
  String? result;

  // game state
  late GameState gameState;
  bool _isLoading = true;
  int score = 0;
  int totalAnswered = 0;
  int streak = 0;

  // timer
  Timer? _timer;
  int remainingSeconds = 15;

  // keep track of asked questions so we don't repeat until cycle complete
  final Set<String> _asked = {};

  bool _hasAnswered = false;

  late ConfettiController _confettiController;
  late GameStatsRepository _gameStatsRepository;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _gameStatsRepository = GameStatsRepository();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      final remote = await _gameStatsRepository.fetchGameStats('True False');
      if (remote != null) {
        gameState = GameState(
          level: remote.level,
          score: remote.score,
          streak: 0,
          maxStreak: remote.maxStreak,
        );
        totalAnswered = remote.totalGames;
      } else {
        gameState = GameState();
      }
    } catch (_) {
      gameState = GameState();
    }
    score = gameState.score;
    streak = gameState.streak;
    _pickRandomQuestion();
    _startTimer();
    setState(() {
      _isLoading = false;
    });
  }

  void _pickRandomQuestion() {
    if (_asked.length == questionDatabase.length) {
      _asked.clear();
    }
    final remaining = questionDatabase
        .where((q) => !_asked.contains(q.statement))
        .toList();
    final random = Random();
    final picked = remaining[random.nextInt(remaining.length)];
    question = picked.statement;
    correctAnswer = picked.isTrue;
    result = null;
    _hasAnswered = false;
    _asked.add(question);
    remainingSeconds = 15 - (gameState.level ~/ 3); // faster at higher levels
    remainingSeconds = remainingSeconds.clamp(5, 15);
    _startTimer();
  }

  void _answer(bool choice) {
    if (_hasAnswered) return;
    if (_timer?.isActive ?? false) _timer?.cancel();
    final isCorrect = choice == correctAnswer;

    setState(() {
      _hasAnswered = true;
      totalAnswered++;
      if (isCorrect) {
        int points = 10 + (gameState.streak >= 3 ? 5 : 0);
        final qobj = questionDatabase.firstWhere((q) => q.statement == question);
        if (qobj.difficulty == 'hard') points += 5;
        score += points;
        streak++;
        gameState = gameState.copyWith(
          score: gameState.score + points,
          streak: streak,
          maxStreak: max(gameState.maxStreak, streak),
          level: gameState.level + 1,
        );
        result = 'Correct 🎉';
        _confettiController.play();
        unawaited(AppDependencies.xpService.awardXp(points));
      } else {
        streak = 0;
        gameState = gameState.copyWith(streak: 0);
        result = 'Wrong 🙏';
      }
    });

    _saveGameState();

    if (_asked.length == questionDatabase.length) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) _showCycleComplete();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() { _pickRandomQuestion(); });
      });
    }
  }

  void _showCycleComplete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cycle Complete'),
        content: Text(
          'You answered $totalAnswered questions and scored $score points.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                // reset stats and start new cycle
                score = 0;
                totalAnswered = 0;
                streak = 0;
                gameState = GameState();
                _asked.clear();
                _pickRandomQuestion();
              });
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        remainingSeconds--;
      });
      if (remainingSeconds <= 0) {
        timer.cancel();
        _handleTimeExpired();
      }
    });
  }

  void _handleTimeExpired() {
    setState(() {
      _hasAnswered = true;
      streak = 0;
      gameState = gameState.copyWith(streak: 0);
      result = 'Time up ⏰';
    });
    _saveGameState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() { _pickRandomQuestion(); });
    });
  }

  Future<void> _saveGameState() async {
    try {
      final stats = GameStats(
        gameName: 'True False',
        level: gameState.level,
        score: score,
        maxStreak: gameState.maxStreak,
        totalGames: totalAnswered,
        lastPlayed: DateTime.now(),
      );
      await _gameStatsRepository.saveGameStats(stats);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('True or False'),
        elevation: 0,
        backgroundColor: AppColors.saffron,
        foregroundColor: Colors.white,

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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // score & progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Score: $score',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Streak: $streak',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Answered: $totalAnswered',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // timer
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: remainingSeconds <= 5
                            ? AppColors.error
                            : AppColors.saffron,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$remainingSeconds s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _asked.isEmpty
                        ? 0
                        : _asked.length / questionDatabase.length,
                  ),
                  const SizedBox(height: 24),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _hasAnswered ? null : () => _answer(true),
                          child: const Text(
                            'True',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _hasAnswered ? null : () => _answer(false),
                          child: const Text(
                            'False',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: result != null
                        ? Container(
                            key: ValueKey(result),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            decoration: BoxDecoration(
                              color: result!.startsWith('Correct')
                                  ? AppColors.success.withValues(alpha: 0.15)
                                  : AppColors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: result!.startsWith('Correct') ? AppColors.success : AppColors.error,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  result!.startsWith('Correct') ? Icons.check_circle : Icons.cancel,
                                  color: result!.startsWith('Correct') ? AppColors.success : AppColors.error,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  result!,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          // confetti overlay
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

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }
}

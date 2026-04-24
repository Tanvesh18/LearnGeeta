import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'dart:math';
import '../../../core/app_dependencies.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/game_stats.dart';
import '../../../features/progress/repositories/game_stats_repository.dart';
import 'models/verse_model.dart';

class VerseOrderScreen extends StatefulWidget {
  const VerseOrderScreen({super.key});

  @override
  State<VerseOrderScreen> createState() => _VerseOrderScreenState();
}

class _VerseOrderScreenState extends State<VerseOrderScreen>
    with TickerProviderStateMixin {
  // Game state
  late GameState gameState;
  late Verse currentVerse;
  late List<int> shuffledOrder;
  Timer? countdownTimer;
  int remainingSeconds = 30;
  bool isAnswerChecked = false;
  bool isAnswerCorrect = false;
  late IGameStatsRepository _gameStatsRepository;
  int _lastEarnedXp = 0;
  bool isCheckButtonDisabled = false;
  bool showAnswer = false;
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late AnimationController _slideController;

  // UI
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _gameStatsRepository = GameStatsRepository();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      final remote = await _gameStatsRepository.fetchGameStats('Verse Order');
      if (remote != null) {
        gameState = GameState(
          level: remote.level,
          score: remote.score,
          streak: 0,
          maxStreak: remote.maxStreak,
        );
      } else {
        gameState = GameState();
      }
    } catch (_) {
      gameState = GameState();
    }

    _loadNewVerse();
    setState(() {
      isLoading = false;
    });
  }

  void _loadNewVerse() {
    final difficulty = _getDifficultyForLevel(gameState.level);
    final versesWithDifficulty = verseDatabase
        .where((v) => v.difficulty == difficulty)
        .toList();

    currentVerse =
        versesWithDifficulty[Random().nextInt(versesWithDifficulty.length)];
    shuffledOrder = _shuffleOrder(currentVerse.lines.length);

    // Check if shuffle equals original
    if (_isInOriginalOrder(shuffledOrder)) {
      _loadNewVerse();
      return;
    }

    remainingSeconds = 30;
    isAnswerChecked = false;
    isAnswerCorrect = false;
    isCheckButtonDisabled = false;
    showAnswer = false;

    _startTimer();
  }

  String _getDifficultyForLevel(int level) {
    if (level <= 3) return 'easy';
    if (level <= 7) return 'medium';
    return 'hard';
  }

  List<int> _shuffleOrder(int length) {
    final shuffled = List<int>.generate(length, (index) => index);
    shuffled.shuffle();
    return shuffled;
  }

  bool _isInOriginalOrder(List<int> order) {
    for (int i = 0; i < order.length; i++) {
      if (order[i] != i) return false;
    }
    return true;
  }

  void _startTimer() {
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    HapticFeedback.vibrate();
    setState(() {
      gameState = gameState.copyWith(
        score: max(0, gameState.score - 5),
        streak: 0,
      );
      isAnswerChecked = true;
      isAnswerCorrect = false;
    });

    _showFeedbackDialog(
      title: 'Time\'s Up!',
      message: 'You ran out of time. -5 points',
      isCorrect: false,
    );
  }

  void _checkAnswer() {
    if (isCheckButtonDisabled) return;

    countdownTimer?.cancel();
    HapticFeedback.heavyImpact();

    bool isCorrect = _isInOriginalOrder(shuffledOrder);

    setState(() {
      isCheckButtonDisabled = true;
      isAnswerChecked = true;
      isAnswerCorrect = isCorrect;

      if (isCorrect) {
        int points = 10 + (currentVerse.difficulty == 'hard' ? 5 : 0);

        // Streak bonus
        if (gameState.streak >= 3) {
          points += 5;
        }
        if (gameState.streak >= 5) {
          points += 10;
        }
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
        HapticFeedback.vibrate();
        _shakeController.forward().then((_) {
          _shakeController.reverse();
        });

        gameState = gameState.copyWith(
          score: max(0, gameState.score - 2),
          streak: 0,
        );
      }
    });

    _saveGameState();
    _showFeedbackDialog(
      title: isCorrect ? 'Correct! 🎉' : 'Incorrect ❌',
      message: isCorrect
          ? 'Well done! +$_lastEarnedXp XP'
          : 'Try again! -2 points',
      isCorrect: isCorrect,
    );
  }

  void _showAnswer() {
    setState(() {
      showAnswer = true;
    });

    setState(() {
      gameState = gameState.copyWith(score: max(0, gameState.score - 3));
    });

    _saveGameState();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Answer revealed. -3 points'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _skipVerse() {
    countdownTimer?.cancel();

    setState(() {
      gameState = gameState.copyWith(
        score: max(0, gameState.score - 5),
        streak: 0,
      );
    });

    _saveGameState();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verse skipped. -5 points'),
        duration: Duration(seconds: 2),
      ),
    );

    _loadNewVerse();
    setState(() {});
  }

  void _restartLevel() {
    countdownTimer?.cancel();

    setState(() {
      gameState = gameState.copyWith(
        level: 1,
        score: 0,
        streak: 0,
        maxStreak: 0,
      );
    });

    _saveGameState();
    _loadNewVerse();
  }

  Future<void> _saveGameState() async {
    try {
      final stats = GameStats(
        gameName: 'Verse Order',
        level: gameState.level,
        score: gameState.score,
        maxStreak: gameState.maxStreak,
        totalGames: 0,
        lastPlayed: DateTime.now(),
      );
      await _gameStatsRepository.saveGameStats(stats);
    } catch (_) {}
  }

  void _showFeedbackDialog({
    required String title,
    required String message,
    required bool isCorrect,
  }) {
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
                  title,
                  style: GoogleFonts.notoSerifDevanagari(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                if (isCorrect) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.gradientStart,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chapter ${currentVerse.chapter}, Verse ${currentVerse.verseNumber}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentVerse.englishMeaning,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentVerse.hindiMeaning,
                          style: GoogleFonts.notoSerifDevanagari(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _loadNewVerse();
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.saffron,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(isCorrect ? 'Next Level' : 'Try Again'),
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

  @override
  void dispose() {
    countdownTimer?.cancel();
    _confettiController.dispose();
    _shakeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verse Order')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Verse Order'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: AppColors.saffron,
            foregroundColor: Colors.white,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'L${gameState.level}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
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
                  ],
                ),
              ),
            ],
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Timer and Streak
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Timer
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: remainingSeconds < 10
                                  ? Colors.red.shade100
                                  : AppColors.gradientEnd,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: remainingSeconds < 10
                                    ? Colors.red
                                    : AppColors.saffron,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Time',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '${remainingSeconds}s',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: remainingSeconds < 10
                                        ? Colors.red
                                        : AppColors.deepBrown,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Streak
                          if (gameState.streak > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gradientEnd,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Streak',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        '🔥',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${gameState.streak}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.saffron,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Sanskrit Text (Fixed)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          currentVerse.sanskrit,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSerifDevanagari(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.saffron,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Instructions
                      const Text(
                        'Arrange the lines in correct order',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Draggable Lines (Reorderable)
                      ReorderableListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final item = shuffledOrder.removeAt(oldIndex);
                            shuffledOrder.insert(newIndex, item);
                            _slideController.forward().then((_) {
                              _slideController.reset();
                            });
                          });
                          isCheckButtonDisabled = false;
                        },
                        children: [
                          for (int i = 0; i < shuffledOrder.length; i++)
                            Container(
                              key: ValueKey(shuffledOrder[i]),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ScaleTransition(
                                scale: Tween<double>(
                                  begin: 1,
                                  end: 1.02,
                                ).animate(_slideController),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isAnswerCheckAndWrong(i)
                                        ? Colors.red.shade100
                                        : isAnswerCheckAndCorrect
                                        ? Colors.green.shade100
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isAnswerCheckAndWrong(i)
                                          ? Colors.red
                                          : isAnswerCheckAndCorrect
                                          ? Colors.green
                                          : AppColors.saffron,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.06,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      ReorderableDragStartListener(
                                        index: i,
                                        child: const Icon(
                                          Icons.drag_handle,
                                          color: AppColors.saffron,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          currentVerse.lines[shuffledOrder[i]],
                                          style:
                                              GoogleFonts.notoSerifDevanagari(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      if (isAnswerChecked)
                                        Icon(
                                          isAnswerCheckAndWrong(i)
                                              ? Icons.close
                                              : Icons.check,
                                          color: isAnswerCheckAndWrong(i)
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Buttons Row
                      // Buttons Row
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          if (showAnswer == false && !isAnswerChecked)
                            SizedBox(
                              width: 150,
                              child: ElevatedButton.icon(
                                onPressed: _showAnswer,
                                icon: const Icon(Icons.visibility),
                                label: const Text('Show Answer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            )
                          else if (showAnswer)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  for (
                                    int i = 0;
                                    i < currentVerse.lines.length;
                                    i++
                                  )
                                    Chip(
                                      label: Text(
                                        currentVerse.lines[i],
                                        style:
                                            GoogleFonts.notoSerifDevanagari(),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                          if (!isAnswerChecked)
                            SizedBox(
                              width: 130,
                              child: ElevatedButton.icon(
                                onPressed: _skipVerse,
                                icon: const Icon(Icons.skip_next),
                                label: const Text('Skip (-5)'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),

                          if (!isAnswerChecked)
                            SizedBox(
                              width: 120,
                              child: ElevatedButton.icon(
                                onPressed: isCheckButtonDisabled
                                    ? null
                                    : _checkAnswer,
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Check'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),

                          if (isAnswerChecked)
                            SizedBox(
                              width: 150,
                              child: ElevatedButton.icon(
                                onPressed: _restartLevel,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Restart'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.saffron,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.1,
            shouldLoop: false,
            colors: const [
              Colors.red,
              Colors.orange,
              Colors.yellow,
              Colors.green,
              Colors.blue,
            ],
          ),
        ),
      ],
    );
  }

  bool get isAnswerCheckAndCorrect => isAnswerChecked && isAnswerCorrect;

  bool isAnswerCheckAndWrong(int index) =>
      isAnswerChecked && !isAnswerCorrect && shuffledOrder[index] != index;
}

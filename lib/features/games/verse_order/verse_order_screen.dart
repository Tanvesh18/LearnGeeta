import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import '../../../core/app_dependencies.dart';
import '../../../core/constants/colors.dart';
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
  late List<String> shuffledLines;
  Timer? countdownTimer;
  int remainingSeconds = 30;
  bool isAnswerChecked = false;
  bool isAnswerCorrect = false;
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
    final prefs = await SharedPreferences.getInstance();
    final savedStateJson = prefs.getString('verseOrderGameState');

    if (savedStateJson != null) {
      gameState = GameState.fromJson(
        Map<String, dynamic>.from({
          'level': 1,
          'score': 0,
          'streak': 0,
          'maxStreak': 0,
        }),
      );
    } else {
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
    shuffledLines = _shuffleLines(currentVerse.lines);

    // Check if shuffle equals original
    if (shuffledLines.join() == currentVerse.lines.join()) {
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

  List<String> _shuffleLines(List<String> lines) {
    final shuffled = List<String>.from(lines);
    shuffled.shuffle();
    return shuffled;
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

    bool isCorrect = shuffledLines.join() == currentVerse.lines.join();

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
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('verseOrderGameState', '${gameState.toJson()}');
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
                      color: Colors.blue.shade50,
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
                    if (!isCorrect)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _loadNewVerse();
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Try Again'),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _loadNewVerse();
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Next Level'),
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
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
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
                            color: Colors.grey,
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.purple.shade50,
                  Colors.orange.shade50,
                ],
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
                                  : Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: remainingSeconds < 10
                                    ? Colors.red
                                    : Colors.blue,
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
                                  '$remainingSeconds"',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: remainingSeconds < 10
                                        ? Colors.red
                                        : Colors.blue,
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
                                color: Colors.orange.shade100,
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
                                          color: Colors.orange,
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
                              color: Colors.black.withOpacity(0.08),
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
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final item = shuffledLines.removeAt(oldIndex);
                            shuffledLines.insert(newIndex, item);
                            _slideController.forward().then((_) {
                              _slideController.reset();
                            });
                          });
                          isCheckButtonDisabled = false;
                        },
                        children: [
                          for (int i = 0; i < shuffledLines.length; i++)
                            Container(
                              key: ValueKey(i),
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
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.drag_handle,
                                        color: AppColors.saffron,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          shuffledLines[i],
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (showAnswer == false && !isAnswerChecked)
                              ElevatedButton.icon(
                                onPressed: _showAnswer,
                                icon: const Icon(Icons.visibility),
                                label: const Text('Show Answer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              )
                            else if (showAnswer)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Wrap(
                                  children: [
                                    for (
                                      int i = 0;
                                      i < currentVerse.lines.length;
                                      i++
                                    )
                                      Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Chip(
                                          label: Text(
                                            currentVerse.lines[i],
                                            style:
                                                GoogleFonts.notoSerifDevanagari(),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            if (!isAnswerChecked) ...[
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: _skipVerse,
                                icon: const Icon(Icons.skip_next),
                                label: const Text('Skip (-5)'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: isCheckButtonDisabled
                                    ? null
                                    : _checkAnswer,
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Check'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                            if (isAnswerChecked) ...[
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: _restartLevel,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Restart'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
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
      isAnswerChecked &&
      !isAnswerCorrect &&
      shuffledLines[index] != currentVerse.lines[index];
}

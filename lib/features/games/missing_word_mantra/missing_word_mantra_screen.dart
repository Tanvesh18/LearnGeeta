import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import '../../../core/app_dependencies.dart';
import '../../../core/constants/colors.dart';
import 'models/mantra_model.dart';

class MissingWordMantraScreen extends StatefulWidget {
  const MissingWordMantraScreen({super.key});

  @override
  State<MissingWordMantraScreen> createState() =>
      _MissingWordMantraScreenState();
}

class _MissingWordMantraScreenState extends State<MissingWordMantraScreen> {
  late GameState gameState;
  bool _isLoading = true;
  late MantraData currentMantra;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  bool hasAnswered = false;
  bool isCorrect = false;
  int _lastEarnedXp = 0;
  int _timeLeft = 30;
  Timer? _timer;

  late ConfettiController _confettiController;
  final Set<String> _seenMantras = {};

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
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    final prefs = await SharedPreferences.getInstance();
    gameState = GameState(
      level: prefs.getInt('missingWordLevel') ?? 1,
      score: prefs.getInt('missingWordScore') ?? 0,
      streak: prefs.getInt('missingWordStreak') ?? 0,
      maxStreak: prefs.getInt('missingWordMaxStreak') ?? 0,
    );
    _seenMantras.clear();
    _loadNewMantra();
    setState(() => _isLoading = false);
  }

  void _loadNewMantra() {
    if (_seenMantras.length == mantraDatabase.length) {
      _seenMantras.clear();
    }

    final remaining = mantraDatabase
        .where((m) => !_seenMantras.contains(m.title))
        .toList();

    final targetDifficulty = _getDifficultyForLevel(gameState.level);
    final matching = remaining
        .where((m) => m.difficulty == targetDifficulty || remaining.length <= 2)
        .toList();

    if (matching.isEmpty) {
      currentMantra = remaining[Random().nextInt(remaining.length)];
    } else {
      currentMantra = matching[Random().nextInt(matching.length)];
    }

    _seenMantras.add(currentMantra.title);

    // Initialize controllers and focus nodes for blanks
    _controllers.clear();
    _focusNodes.clear();
    for (int i = 0; i < currentMantra.correctWords.length; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }

    hasAnswered = false;
    isCorrect = false;
    _timeLeft = 30;
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

  void _checkAnswer() {
    if (hasAnswered) return;

    bool allCorrect = true;
    for (int i = 0; i < _controllers.length; i++) {
      final userAnswer = _controllers[i].text.trim().toLowerCase();
      final correctAnswer = currentMantra.correctWords[i].toLowerCase();
      if (userAnswer != correctAnswer) {
        allCorrect = false;
        break;
      }
    }

    setState(() {
      hasAnswered = true;
      isCorrect = allCorrect;

      if (allCorrect) {
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

  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('missingWordLevel', gameState.level);
    await prefs.setInt('missingWordScore', gameState.score);
    await prefs.setInt('missingWordStreak', gameState.streak);
    await prefs.setInt('missingWordMaxStreak', gameState.maxStreak);
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
                  isCorrect ? 'Perfect Recitation! 🕉️' : 'Keep Practicing',
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
                  const Text(
                    'Review the correct words',
                    style: TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chapter ${currentMantra.gitaReference.chapter}, Verse ${currentMantra.gitaReference.verse}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentMantra.gitaReference.explanation,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _loadNewMantra();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.saffron,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Continue'),
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
        title: const Text('Missing Word Mantra'),
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
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
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
                          color: _timeLeft <= 10 ? Colors.red : AppColors.saffron,
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

                  // Mantra text with input fields
                  Expanded(
                    child: Container(
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
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              currentMantra.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.saffron,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 12,
                              children: _buildMantraWidgets(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: hasAnswered ? null : _checkAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.saffron,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        hasAnswered
                            ? (isCorrect ? 'Correct!' : 'Try Again')
                            : 'Check Answer',
                        style: const TextStyle(fontSize: 18),
                      ),
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
                colors: const [Colors.yellow, Colors.orange, Colors.red],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMantraWidgets() {
    final widgets = <Widget>[];
    int blankIndex = 0;

    for (final word in currentMantra.mantra) {
      if (word.isBlank) {
        widgets.add(
          SizedBox(
            width: 120,
            child: TextField(
              controller: _controllers[blankIndex],
              focusNode: _focusNodes[blankIndex],
              enabled: !hasAnswered,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: hasAnswered
                    ? (_controllers[blankIndex].text.trim().toLowerCase() ==
                              currentMantra.correctWords[blankIndex]
                                  .toLowerCase()
                          ? Colors.green.shade50
                          : Colors.red.shade50)
                    : Colors.grey.shade50,
                hintText: '_____',
              ),
              onSubmitted: (_) {
                if (blankIndex < _focusNodes.length - 1) {
                  _focusNodes[blankIndex + 1].requestFocus();
                } else {
                  _checkAnswer();
                }
              },
            ),
          ),
        );
        blankIndex++;
      } else {
        widgets.add(
          Text(word.text, style: const TextStyle(fontSize: 16, height: 1.5)),
        );
      }
    }

    return widgets;
  }
}

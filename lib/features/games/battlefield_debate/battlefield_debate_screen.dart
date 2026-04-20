import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import '../../../core/app_dependencies.dart';
import '../../../core/constants/colors.dart';
import 'models/debate_model.dart';

class BattlefieldDebateScreen extends StatefulWidget {
  const BattlefieldDebateScreen({super.key});

  @override
  State<BattlefieldDebateScreen> createState() =>
      _BattlefieldDebateScreenState();
}

class _BattlefieldDebateScreenState extends State<BattlefieldDebateScreen> {
  late GameState gameState;
  bool _isLoading = true;
  late DebateScenario currentScenario;
  List<DebateOption> shuffledOptions = [];
  List<int> originalIndices = [];
  int? selectedOptionIndex;
  bool hasAnswered = false;
  bool isCorrect = false;
  int _lastEarnedXp = 0;
  int _timeLeft = 30;
  Timer? _timer;

  late ConfettiController _confettiController;
  final Set<String> _seenScenarios = {};

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
      level: prefs.getInt('battlefieldDebateLevel') ?? 1,
      score: prefs.getInt('battlefieldDebateScore') ?? 0,
      streak: prefs.getInt('battlefieldDebateStreak') ?? 0,
      maxStreak: prefs.getInt('battlefieldDebateMaxStreak') ?? 0,
    );
    _seenScenarios.clear();
    _loadNewScenario();
    setState(() => _isLoading = false);
  }

  void _loadNewScenario() {
    if (_seenScenarios.length == debateDatabase.length) {
      _seenScenarios.clear();
    }

    final remaining = debateDatabase
        .where((s) => !_seenScenarios.contains(s.arjunaQuestion))
        .toList();

    final targetDifficulty = _getDifficultyForLevel(gameState.level);
    final matching = remaining
        .where((s) => s.difficulty == targetDifficulty || remaining.length <= 2)
        .toList();

    if (matching.isEmpty) {
      currentScenario = remaining[0];
    } else {
      currentScenario = matching[0];
    }

    _seenScenarios.add(currentScenario.arjunaQuestion);

    // Shuffle the options
    _shuffleOptions();

    selectedOptionIndex = null;
    hasAnswered = false;
    isCorrect = false;
    _timeLeft = 30;
    _startTimer();
  }

  void _shuffleOptions() {
    // Create a list of indices and shuffle them
    originalIndices = List.generate(
      currentScenario.krishnaResponses.length,
      (i) => i,
    );
    originalIndices.shuffle(Random());

    // Create shuffled options list
    shuffledOptions = originalIndices
        .map((i) => currentScenario.krishnaResponses[i])
        .toList();
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

    final selectedOption = shuffledOptions[index];
    final correct = selectedOption.isCorrect;

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
    await prefs.setInt('battlefieldDebateLevel', gameState.level);
    await prefs.setInt('battlefieldDebateScore', gameState.score);
    await prefs.setInt('battlefieldDebateStreak', gameState.streak);
    await prefs.setInt('battlefieldDebateMaxStreak', gameState.maxStreak);
  }

  void _showResultDialog() {
    if (!mounted) return;

    final selectedOption = selectedOptionIndex != null
        ? shuffledOptions[selectedOptionIndex!]
        : null;

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
                  isCorrect ? 'Divine Wisdom! 🙏' : 'Keep Seeking Truth',
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
                else if (selectedOption != null)
                  Text(
                    'Krishna would say: ${shuffledOptions.firstWhere((o) => o.isCorrect).text}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.saffron,
                    ),
                    textAlign: TextAlign.center,
                  )
                else
                  const Text(
                    'Time ran out! Krishna\'s wisdom awaits your next attempt.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
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
                        'Chapter ${currentScenario.chapter}, Verse ${currentScenario.verse}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentScenario.context,
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (selectedOption != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Why this response?',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedOption.explanation,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _loadNewScenario();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.saffron,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Next Debate'),
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
        title: const Text('Battlefield Debate'),
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
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
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
                          color: _timeLeft <= 10 ? Colors.red : Colors.brown,
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

                  // Arjuna's Question
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
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                'A',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Arjuna asks:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentScenario.arjunaQuestion,
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.saffron.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.saffron.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.saffron,
                                child: Text(
                                  'K',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'What would Krishna say?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.saffron,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Krishna's Response Options
                  Expanded(
                    child: ListView.builder(
                      itemCount: shuffledOptions.length,
                      itemBuilder: (context, index) {
                        final option = shuffledOptions[index];
                        final isSelected = selectedOptionIndex == index;
                        final isCorrectOption = option.isCorrect;

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
                                    Expanded(
                                      child: Text(
                                        option.text,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: hasAnswered && isCorrectOption
                                              ? Colors.green.shade800
                                              : Colors.black,
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
                colors: const [Colors.orange, Colors.deepOrange, Colors.amber],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

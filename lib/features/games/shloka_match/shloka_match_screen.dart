import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../../core/app_dependencies.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/game_stats.dart';
import '../../../features/progress/repositories/game_stats_repository.dart';
import 'models/shloka_model.dart';

class ShlokaMatchScreen extends StatefulWidget {
  const ShlokaMatchScreen({super.key});

  @override
  State<ShlokaMatchScreen> createState() => _ShlokaMatchScreenState();
}

class _ShlokaMatchScreenState extends State<ShlokaMatchScreen> {
  late GameState gameState;
  Shloka? currentShloka;
  List<String>? shuffledMeanings;
  String? selectedMeaning;
  bool hasAnswered = false;
  bool isCorrect = false;
  int _lastEarnedXp = 0;
  int remainingSeconds = 30;
  Timer? _timer;
  late IGameStatsRepository _gameStatsRepository;

  @override
  void initState() {
    super.initState();
    _gameStatsRepository = GameStatsRepository();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    final prefs = await SharedPreferences.getInstance();
    final savedState = prefs.getString('shlokaMatchGameState');

    gameState = savedState != null
        ? GameState.fromJson(
            savedState.split(',').asMap().entries.fold(<String, dynamic>{}, (
              map,
              entry,
            ) {
              final parts = entry.value.split(':');
              if (parts.length == 2) {
                map[parts[0].trim()] = int.tryParse(parts[1].trim());
              }
              return map;
            }),
          )
        : GameState();

    _loadNewShloka();
    _startTimer();
  }

  void _loadNewShloka() {
    setState(() {
      selectedMeaning = null;
      hasAnswered = false;
      isCorrect = false;
      remainingSeconds = 30;
    });

    // Determine difficulty based on level
    String difficulty;
    if (gameState.level <= 3) {
      difficulty = 'easy';
    } else if (gameState.level <= 7) {
      difficulty = 'medium';
    } else {
      difficulty = 'hard';
    }

    // Get shlokas of current difficulty and select random one
    final availableShlokas = shlokaDatabase
        .where((s) => s.difficulty == difficulty)
        .toList();
    currentShloka = availableShlokas[Random().nextInt(availableShlokas.length)];

    // Shuffle meanings
    shuffledMeanings = List<String>.from(currentShloka!.meaningOptions);
    shuffledMeanings!.shuffle();

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    remainingSeconds = 30;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        remainingSeconds--;
      });

      if (remainingSeconds <= 0) {
        _timer?.cancel();
        if (!hasAnswered) {
          setState(() {
            hasAnswered = true;
            isCorrect = false;
          });
          _showFeedbackAndContinue();
        }
      }
    });
  }

  void _checkAnswer(String selectedAnswer) {
    if (hasAnswered) return;

    _timer?.cancel();

    bool correct = selectedAnswer == currentShloka!.englishMeaning;

    setState(() {
      selectedMeaning = selectedAnswer;
      hasAnswered = true;
      isCorrect = correct;
    });

    if (correct) {
      // Calculate score
      int points = 10; // Base points
      if (currentShloka!.difficulty == 'hard') points += 5;
      if (gameState.streak >= 3) points += 5;
      if (gameState.streak >= 5) points += 10;
      _lastEarnedXp = points;

      gameState = gameState.copyWith(
        score: gameState.score + points,
        streak: gameState.streak + 1,
        maxStreak: max(gameState.streak + 1, gameState.maxStreak),
        level: gameState.level + 1,
      );
      unawaited(AppDependencies.xpService.awardXp(points));
    } else {
      // Wrong match - reset streak
      _lastEarnedXp = 0;
      gameState = gameState.copyWith(streak: 0);
    }

    _saveGameState();
    Future.delayed(const Duration(milliseconds: 800), _showFeedbackAndContinue);
  }

  void _showFeedbackAndContinue() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          isCorrect ? 'Correct! 🎉' : 'Oops!',
          style: TextStyle(color: isCorrect ? AppColors.saffron : Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chapter ${currentShloka!.chapter}, Verse ${currentShloka!.verseNumber}',
            ),
            const SizedBox(height: 12),
            Text('Shloka: ${currentShloka!.sanskrit}'),
            const SizedBox(height: 12),
            Text('English: ${currentShloka!.englishMeaning}'),
            const SizedBox(height: 8),
            Text('Hindi: ${currentShloka!.hindiMeaning}'),
            if (isCorrect) ...[
              const SizedBox(height: 12),
              Text(
                '+$_lastEarnedXp XP earned',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            if (!isCorrect) ...[
              const SizedBox(height: 12),
              Text(
                'Your answer: $selectedMeaning',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadNewShloka();
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shlokaMatchGameState', '${gameState.toJson()}');

    // Also save to Supabase
    try {
      final stats = GameStats(
        gameName: 'Shloka Match',
        level: gameState.level,
        score: gameState.score,
        maxStreak: gameState.maxStreak,
        totalGames: 0,
        lastPlayed: DateTime.now(),
      );
      await _gameStatsRepository.saveGameStats(stats);
    } catch (e) {
      // If Supabase fails, continue with local save
    }
  }

  void _restartLevel() {
    gameState = GameState();
    _saveGameState();
    _loadNewShloka();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentShloka == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shloka Match'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.saffron,
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
              ],
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Timer and Streak
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '🔥 ${gameState.streak}',
                        style: const TextStyle(
                          fontSize: 18,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: remainingSeconds <= 10 ? Colors.red : AppColors.saffron,
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
                ],
              ),
              const SizedBox(height: 20),

              // Shloka
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      currentShloka!.sanskrit,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ch ${currentShloka!.chapter}, V ${currentShloka!.verseNumber}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Instructions
              const Text(
                'Select the correct meaning:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Meaning Options
              Expanded(
                child: ListView.builder(
                  itemCount: shuffledMeanings!.length,
                  itemBuilder: (context, index) {
                    final meaning = shuffledMeanings![index];
                    final isSelected = selectedMeaning == meaning;
                    final isCorrectAnswer =
                        meaning == currentShloka!.englishMeaning;

                    Color cardColor = Colors.white;
                    if (hasAnswered && isSelected) {
                      cardColor = isCorrect
                          ? Colors.green.shade50
                          : Colors.red.shade50;
                    } else if (hasAnswered && isCorrectAnswer) {
                      cardColor = Colors.green.shade50;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: !hasAnswered
                            ? () => _checkAnswer(meaning)
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? (isCorrect ? Colors.green : Colors.red)
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  meaning,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        hasAnswered &&
                                            !isCorrectAnswer &&
                                            isSelected
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              if (hasAnswered && isCorrectAnswer)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                              if (hasAnswered && isSelected && !isCorrect)
                                Icon(Icons.close, color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Action Buttons
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _restartLevel,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Restart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


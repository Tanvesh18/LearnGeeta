import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../../core/app_dependencies.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/game_stats.dart';
import '../../../features/progress/repositories/game_stats_repository.dart';
import 'models/memory_model.dart';

class KrishnaMemoryCardsScreen extends StatefulWidget {
  const KrishnaMemoryCardsScreen({super.key});

  @override
  State<KrishnaMemoryCardsScreen> createState() =>
      _KrishnaMemoryCardsScreenState();
}

class _KrishnaMemoryCardsScreenState extends State<KrishnaMemoryCardsScreen> {
  late GameState gameState;
  late IGameStatsRepository _gameStatsRepository;
  bool _isLoading = true;
  List<MemoryCard> gameCards = [];
  List<bool> cardFlipped = [];
  List<bool> cardMatched = [];
  int? firstSelectedIndex;
  int? secondSelectedIndex;
  bool _isChecking = false;
  int _moves = 0;
  int _matches = 0;
  int _lastEarnedXp = 0;
  int _timeLeft = 60;
  Timer? _timer;

  late ConfettiController _confettiController;
  final Set<String> _seenPairs = {};

  @override
  void initState() {
    super.initState();
    _gameStatsRepository = GameStatsRepository();
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
    try {
      final remote = await _gameStatsRepository.fetchGameStats(
        'Krishna Memory Cards',
      );
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
    _seenPairs.clear();
    _loadNewGame();
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _loadNewGame() {
    final targetDifficulty = _getDifficultyForLevel(gameState.level);
    final allAtDifficulty = memoryDatabase
        .where((p) => p.card1.difficulty == targetDifficulty)
        .toList();

    if (allAtDifficulty.isEmpty) {
      return;
    }

    if (_seenPairs.length >= allAtDifficulty.length) {
      _seenPairs.clear();
    }

    final unseenAtDifficulty = allAtDifficulty
        .where((p) => !_seenPairs.contains('${p.card1.id}_${p.card2.id}'))
        .toList();

    // Select 3-5 pairs based on level
    final pairCount = 3 + (gameState.level ~/ 2).clamp(0, 2); // 3-5 pairs
    final selectedPairs = <CardPair>[];
    final random = Random();
    final selectionPool = <CardPair>[...unseenAtDifficulty];

    if (selectionPool.length < pairCount) {
      final extraPairs = allAtDifficulty
          .where((p) => !selectionPool.contains(p))
          .toList()
        ..shuffle(random);
      selectionPool.addAll(extraPairs);
    }

    final targetPairs = min(pairCount, selectionPool.length);

    for (int i = 0; i < targetPairs && selectionPool.isNotEmpty; i++) {
      final index = random.nextInt(selectionPool.length);
      final pair = selectionPool[index];
      selectedPairs.add(pair);
      _seenPairs.add('${pair.card1.id}_${pair.card2.id}');
      selectionPool.removeAt(index);
    }

    // Create shuffled deck with all cards from selected pairs
    gameCards = [];
    for (final pair in selectedPairs) {
      gameCards.addAll([pair.card1, pair.card2]);
    }
    gameCards.shuffle(random);

    cardFlipped = List.filled(gameCards.length, false);
    cardMatched = List.filled(gameCards.length, false);
    firstSelectedIndex = null;
    secondSelectedIndex = null;
    _isChecking = false;
    _moves = 0;
    _matches = 0;
    _timeLeft = 60;
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
        _endGame(false);
      }
    });
  }

  void _onCardTap(int index) {
    if (cardFlipped[index] || cardMatched[index] || _isChecking) return;

    setState(() {
      cardFlipped[index] = true;

      if (firstSelectedIndex == null) {
        firstSelectedIndex = index;
      } else {
        secondSelectedIndex = index;
        _moves++;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    setState(() => _isChecking = true);

    final card1 = gameCards[firstSelectedIndex!];
    final card2 = gameCards[secondSelectedIndex!];

    final isPairMatch =
        card1.matchId == card2.id && card2.matchId == card1.id;

    if (isPairMatch) {
      // Match found
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          cardMatched[firstSelectedIndex!] = true;
          cardMatched[secondSelectedIndex!] = true;
          _matches++;
          _isChecking = false;
          firstSelectedIndex = null;
          secondSelectedIndex = null;

          if (_matches == gameCards.length ~/ 2) {
            _endGame(true);
          }
        });
      });
    } else {
      // No match
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          cardFlipped[firstSelectedIndex!] = false;
          cardFlipped[secondSelectedIndex!] = false;
          _isChecking = false;
          firstSelectedIndex = null;
          secondSelectedIndex = null;
        });
      });
    }
  }

  void _endGame(bool completed) {
    _timer?.cancel();

    if (completed) {
      // Calculate score based on moves and time
      int basePoints = 20;
      int timeBonus = (_timeLeft ~/ 10) * 5; // 5 points per 10 seconds left
      int movePenalty = max(0, (_moves - 4) * 2); // Penalty for extra moves
      int points = max(10, basePoints + timeBonus - movePenalty);

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

    _saveGameState();
    _showResultDialog(completed);
  }

  Future<void> _saveGameState() async {
    try {
      final stats = GameStats(
        gameName: 'Krishna Memory Cards',
        level: gameState.level,
        score: gameState.score,
        maxStreak: gameState.maxStreak,
        totalGames: 0,
        lastPlayed: DateTime.now(),
      );
      await _gameStatsRepository.saveGameStats(stats);
    } catch (_) {
      // Supabase-only stats: intentionally no local fallback.
    }
  }

  void _showResultDialog(bool completed) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                completed ? 'Memory Master! 🧠' : 'Time\'s Up',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: completed ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 20),
              if (completed)
                Column(
                  children: [
                    Text(
                      '+$_lastEarnedXp XP earned',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Moves: $_moves | Time: ${60 - _timeLeft}s',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                )
              else
                const Text(
                  'Try to match all pairs faster next time!',
                  style: TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _loadNewGame();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.saffron,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Play Again'),
              ),
            ],
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
        title: const Text('Krishna Memory Cards'),
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
                  // Stats
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
                        'Moves: $_moves',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

                  // Card Grid
                  Expanded(
                    child: GridView.builder(
                      itemCount: gameCards.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                      itemBuilder: (context, index) {
                        return _MemoryCard(
                          card: gameCards[index],
                          isFlipped: cardFlipped[index],
                          isMatched: cardMatched[index],
                          onTap: () => _onCardTap(index),
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
                colors: const [AppColors.saffron, AppColors.gold, Colors.white],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    required this.card,
    required this.isFlipped,
    required this.isMatched,
    required this.onTap,
  });

  final MemoryCard card;
  final bool isFlipped;
  final bool isMatched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isMatched
              ? Colors.green.shade200
              : isFlipped
              ? Colors.white
              : AppColors.saffron,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: isFlipped || isMatched
              ? Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    card.content,
                    style: TextStyle(
                      fontSize: _getFontSize(card.type),
                      fontWeight: FontWeight.bold,
                      color: isMatched ? Colors.green.shade800 : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : const Icon(Icons.question_mark, size: 40, color: Colors.white),
        ),
      ),
    );
  }

  double _getFontSize(CardType type) {
    switch (type) {
      case CardType.symbol:
        return 48;
      case CardType.shloka:
        return 12;
      case CardType.meaning:
      case CardType.teaching:
        return 14;
    }
  }
}

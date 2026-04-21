import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/app_dependencies.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/game_stats.dart';
import '../../../features/progress/repositories/game_stats_repository.dart';
import 'models/karma_path_model.dart';

class KarmaPathScreen extends StatefulWidget {
  const KarmaPathScreen({super.key});

  @override
  State<KarmaPathScreen> createState() => _KarmaPathScreenState();
}

class _KarmaPathScreenState extends State<KarmaPathScreen> {
  late GameState gameState;
  late StoryNode currentNode;
  bool isReady = false;
  bool isEnding = false;
  GameEnding? endingCard;
  int _lastEndingXp = 0;
  late IGameStatsRepository _gameStatsRepository;

  @override
  void initState() {
    super.initState();
    _gameStatsRepository = GameStatsRepository();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    final prefs = await SharedPreferences.getInstance();
    final karmaJson = prefs.getString('karmaPathGameState');

    if (karmaJson != null) {
      try {
        final data = jsonDecode(karmaJson) as Map<String, dynamic>;
        gameState = GameState.fromJson(data);
      } catch (_) {
        gameState = GameState(
          level: 1,
          score: 0,
          currentKarma: 0,
          currentNodeId: _getRandomStartNode(),
        );
      }
    } else {
      gameState = GameState(
        level: 1,
        score: 0,
        currentKarma: 0,
        currentNodeId: _getRandomStartNode(),
      );
    }

    _loadCurrentNode();

    setState(() {
      isReady = true;
    });
  }

  String _getRandomStartNode() {
    final startNodes = [
      'start1',
      'start2',
      'start3',
      'start4',
      'start5',
      'start',
    ];
    final random = Random();
    return startNodes[random.nextInt(startNodes.length)];
  }

  void _loadCurrentNode() {
    var node = storyTree[gameState.currentNodeId];
    if (node == null) {
      gameState.currentNodeId = 'start';
      node = storyTree['start'];
    }

    if (node != null) {
      setState(() {
        currentNode = node!;
        isEnding = node.isEnding;
      });

      if (isEnding) {
        _determineEnding();
      }
    }
  }

  void _determineEnding() {
    // Find matching ending based on karma score
    GameEnding? matchingEnding;

    for (final ending in gameEndings) {
      if (gameState.currentKarma >= ending.minKarma &&
          gameState.currentKarma <= ending.maxKarma) {
        matchingEnding = ending;
        break;
      }
    }

    if (matchingEnding != null) {
      setState(() {
        endingCard = matchingEnding;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        _showEndingDialog();
      });
    }
  }

  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('karmaPathGameState', jsonEncode(gameState.toJson()));

    // Also save to Supabase
    try {
      final stats = GameStats(
        gameName: 'Karma Path',
        level: 1, // Not leveled
        score: gameState.score,
        maxStreak: 0,
        totalGames: prefs.getInt('karmaPathTotal') ?? 0,
        lastPlayed: DateTime.now(),
      );
      await _gameStatsRepository.saveGameStats(stats);
    } catch (e) {
      // If Supabase fails, continue with local save
    }
  }

  void _makeChoice(StoryChoice choice) async {
    final nextNode = storyTree[choice.nextNodeId];
    final choiceXp = choice.karmaValue > 0 ? 8 + (choice.karmaValue * 2) : 0;
    final endingXp = nextNode?.isEnding == true
        ? (gameState.currentKarma + choice.karmaValue >= 8
              ? 25
              : gameState.currentKarma + choice.karmaValue >= 3
              ? 18
              : gameState.currentKarma + choice.karmaValue >= 0
              ? 10
              : 0)
        : 0;
    _lastEndingXp = endingXp;

    // Update game state
    setState(() {
      gameState.currentKarma += choice.karmaValue;
      gameState.currentNodeId = choice.nextNodeId;
      gameState.visitedNodeIds.add(gameState.currentNodeId);
      gameState.score += 1; // Increment games played on completion
    });

    await _saveGameState();
    unawaited(AppDependencies.xpService.awardXp(choiceXp + endingXp));
    _loadCurrentNode();
  }

  void _showEndingDialog() {
    if (endingCard == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(endingCard!.emoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                endingCard!.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                endingCard!.description,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gradientStart,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Journey:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      endingCard!.message,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gradientStart,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Karma Score',
                          style: TextStyle(fontSize: 10),
                        ),
                        Text(
                          '${gameState.currentKarma}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Choices Made',
                          style: TextStyle(fontSize: 10),
                        ),
                        Text(
                          '${gameState.visitedNodeIds.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_lastEndingXp > 0) ...[
                const SizedBox(height: 16),
                Text(
                  'Ending bonus: +$_lastEndingXp XP',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartStory();
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

  void _restartStory() async {
    gameState = GameState(
      level: 1,
      score: gameState.score + 1,
      currentKarma: 0,
      currentNodeId: _getRandomStartNode(),
    );

    await _saveGameState();
    _loadCurrentNode();
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Karma Path Builder'),
          backgroundColor: AppColors.saffron,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Karma Path Builder'),
        backgroundColor: AppColors.saffron,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Karma: ${gameState.currentKarma}',
                  style: TextStyle(
                    fontSize: 10,
                    color: gameState.currentKarma > 0
                        ? Colors.green.shade300
                        : gameState.currentKarma < 0
                        ? Colors.red.shade300
                        : Colors.white70,
                  ),
                ),
                Text(
                  'Stories: ${gameState.score}',
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
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
                        // Karma Meter
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Karma Meter',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: (gameState.currentKarma + 100)
                                        .toInt()
                                        .clamp(0, 100),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: gameState.currentKarma > 0
                                            ? Colors.green
                                            : gameState.currentKarma < 0
                                            ? Colors.red
                                            : Colors.grey,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex:
                                        (100 -
                                        (gameState.currentKarma + 100)
                                            .toInt()
                                            .clamp(0, 100)),
                                    child: Container(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Story Node Card
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [AppColors.deepBrown, AppColors.saffron],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentNode.emoji,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  currentNode.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  currentNode.description,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Choices
                        if (!isEnding)
                          ...List.generate(
                            currentNode.choices.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildChoiceButton(
                                currentNode.choices[index],
                                index,
                              ),
                            ),
                          )
                        else
                          Center(
                            child: Text(
                              '${currentNode.emoji} ${currentNode.title}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
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

  Widget _buildChoiceButton(StoryChoice choice, int index) {
    final karmaColor = Colors.grey.withValues(alpha: 0.05);
    final karmaBorderColor = Colors.grey.shade300;

    // Subtle karma indicator
    final karmaIndicatorColor = choice.karmaValue > 0
        ? Colors.green.shade400
        : choice.karmaValue < 0
        ? Colors.red.shade400
        : Colors.grey.shade400;

    return GestureDetector(
      onTap: () => _makeChoice(choice),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: karmaColor,
          border: Border.all(color: karmaBorderColor, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: karmaIndicatorColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        choice.text,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${choice.karmaValue > 0 ? '+' : ''}${choice.karmaValue} Karma',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: choice.karmaValue > 0
                              ? Colors.green.shade700
                              : choice.karmaValue < 0
                              ? Colors.red.shade700
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

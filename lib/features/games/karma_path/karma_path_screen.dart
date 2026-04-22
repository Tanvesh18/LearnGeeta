import 'dart:async';
import 'dart:convert';
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

class _KarmaPathScreenState extends State<KarmaPathScreen>
    with TickerProviderStateMixin {
  late GameState gameState;
  late StoryNode _currentNode;
  bool _isReady = false;
  bool _isEnding = false;
  int? _selectedChoiceIndex;
  bool _choiceLocked = false;

  // Journey: list of (nodeId, choiceIndex taken)
  final List<_JourneyStep> _journey = [];

  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;
  late IGameStatsRepository _gameStatsRepository;

  @override
  void initState() {
    super.initState();
    _gameStatsRepository = GameStatsRepository();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _initGame();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _initGame() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('karmaPathGameState');
    int totalGames = prefs.getInt('karmaPathTotal') ?? 0;

    gameState = GameState(
      level: 1,
      score: totalGames,
      currentKarma: 0,
      currentNodeId: _randomStart(),
    );

    // Don't restore mid-game state — always fresh on open
    _loadNode(gameState.currentNodeId, animate: false);
    setState(() => _isReady = true);
  }

  String _randomStart() {
    const starts = ['start1', 'start2', 'start3', 'start4', 'start5'];
    return starts[Random().nextInt(starts.length)];
  }

  void _loadNode(String nodeId, {bool animate = true}) {
    var node = storyTree[nodeId];
    if (node == null) {
      node = storyTree['start1']!;
    }
    setState(() {
      _currentNode = node!;
      _isEnding = node.isEnding;
      _selectedChoiceIndex = null;
      _choiceLocked = false;
    });
    if (animate) {
      _slideController.forward(from: 0);
    } else {
      // Ensure first render is on-screen when initial load skips animation.
      _slideController.value = 1.0;
    }
    if (_isEnding) {
      Future.delayed(const Duration(milliseconds: 600), _showEndingDialog);
    }
  }

  void _onChoiceTap(int index) async {
    if (_choiceLocked) return;
    final choice = _currentNode.choices[index];

    setState(() {
      _selectedChoiceIndex = index;
      _choiceLocked = true;
      gameState.currentKarma += choice.karmaValue;
      gameState.currentNodeId = choice.nextNodeId;
    });

    _journey.add(_JourneyStep(
      nodeId: _currentNode.nodeId,
      emoji: _nodeEmoji(_currentNode),
      label: _currentNode.title,
      karmaChange: choice.karmaValue,
    ));

    final xp = choice.karmaValue > 0 ? 8 + (choice.karmaValue * 2) : 2;
    unawaited(AppDependencies.xpService.awardXp(xp));
    await _saveState();

    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) _loadNode(choice.nextNodeId);
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('karmaPathGameState', jsonEncode(gameState.toJson()));
    try {
      final total = (prefs.getInt('karmaPathTotal') ?? 0);
      await _gameStatsRepository.saveGameStats(GameStats(
        gameName: 'Karma Path',
        level: 1,
        score: gameState.score,
        maxStreak: 0,
        totalGames: total,
        lastPlayed: DateTime.now(),
      ));
    } catch (_) {}
  }

  void _showEndingDialog() {
    if (!mounted) return;
    final karma = gameState.currentKarma;
    GameEnding ending = gameEndings.last;
    for (final e in gameEndings) {
      if (karma >= e.minKarma && karma <= e.maxKarma) {
        ending = e;
        break;
      }
    }

    // Bonus XP for ending
    int bonusXp = karma >= 8 ? 30 : karma >= 2 ? 20 : karma >= -7 ? 10 : 5;
    unawaited(AppDependencies.xpService.awardXp(bonusXp));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_endingEmoji(ending.endingId), style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 12),
              Text(
                ending.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepBrown),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(ending.description, style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.gradientStart, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  ending.message,
                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13, height: 1.5, color: AppColors.deepBrown),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statPill('Karma', '${karma > 0 ? '+' : ''}$karma', karma > 0 ? Colors.green : karma < 0 ? Colors.red : Colors.grey),
                  _statPill('Steps', '${_journey.length}', AppColors.saffron),
                  _statPill('XP', '+$bonusXp', AppColors.gold),
                ],
              ),
              const SizedBox(height: 20),
              // Journey recap
              if (_journey.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Your Path', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 13)),
                ),
                const SizedBox(height: 8),
                _JourneyRecap(steps: _journey),
                const SizedBox(height: 20),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.grey.shade600),
                      child: const Text('Exit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _journey.clear();
                          gameState = GameState(
                            level: 1,
                            score: gameState.score + 1,
                            currentKarma: 0,
                            currentNodeId: _randomStart(),
                          );
                        });
                        _loadNode(gameState.currentNodeId, animate: false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.saffron,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Play Again'),
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

  String _endingEmoji(String endingId) {
    switch (endingId) {
      case 'enlightened': return '🌟';
      case 'balanced': return '⚖️';
      case 'struggling': return '🌊';
      case 'lost': return '🌑';
      default: return '🔱';
    }
  }

  String _nodeEmoji(StoryNode node) {
    // Derive emoji from node title/context since model has empty emoji fields
    final title = node.nodeId;
    if (title.contains('meditat')) return '🧘';
    if (title.contains('wisdom') || title.contains('mentor')) return '📖';
    if (title.contains('heart')) return '💛';
    if (title.contains('duty') || title.contains('bound')) return '⚔️';
    if (title.contains('pleasure') || title.contains('desire')) return '🌹';
    if (title.contains('rush') || title.contains('avoidance')) return '💨';
    if (title.contains('courage') || title.contains('battle')) return '🦁';
    if (title.contains('balance') || title.contains('harmony')) return '☯️';
    if (title.contains('social') || title.contains('compassion')) return '🤝';
    if (title.contains('start')) return '🌅';
    if (title.contains('end') || node.isEnding) return '🏁';
    return '🔱';
  }

  Widget _statPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return Scaffold(
        appBar: AppBar(title: const Text('Karma Path'), backgroundColor: AppColors.saffron, foregroundColor: Colors.white),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final karma = gameState.currentKarma;
    final karmaColor = karma > 0 ? const Color(0xFF4CAF50) : karma < 0 ? const Color(0xFFE53935) : Colors.grey;

    return Scaffold(
      backgroundColor: AppColors.gradientStart,
      appBar: AppBar(
        title: const Text('Karma Path'),
        backgroundColor: AppColors.saffron,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: karmaColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: karmaColor.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(karma >= 0 ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: karmaColor),
                const SizedBox(width: 4),
                Text(
                  '${karma > 0 ? '+' : ''}$karma karma',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: karmaColor),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Journey graph header
          if (_journey.isNotEmpty)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: _JourneyGraph(steps: _journey, currentEmoji: _nodeEmoji(_currentNode)),
            ),

          // Karma progress bar
          _KarmaBar(karma: karma),

          // Main content
          Expanded(
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Step counter
                    if (_journey.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Step ${_journey.length + 1}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                      ),

                    // Situation card
                    _SituationCard(node: _currentNode, emoji: _nodeEmoji(_currentNode)),

                    const SizedBox(height: 20),

                    if (!_isEnding) ...[
                      Text(
                        'What do you choose?',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(_currentNode.choices.length, (i) {
                        return _ChoiceCard(
                          index: i,
                          choice: _currentNode.choices[i],
                          selectedIndex: _selectedChoiceIndex,
                          locked: _choiceLocked,
                          onTap: () => _onChoiceTap(i),
                        );
                      }),
                    ] else
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(color: AppColors.saffron),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _JourneyStep {
  final String nodeId;
  final String emoji;
  final String label;
  final int karmaChange;
  const _JourneyStep({required this.nodeId, required this.emoji, required this.label, required this.karmaChange});
}

class _JourneyGraph extends StatelessWidget {
  final List<_JourneyStep> steps;
  final String currentEmoji;
  const _JourneyGraph({required this.steps, required this.currentEmoji});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ...steps.asMap().entries.expand((e) {
            final step = e.value;
            final color = step.karmaChange > 0
                ? const Color(0xFF4CAF50)
                : step.karmaChange < 0
                    ? const Color(0xFFE53935)
                    : Colors.grey;
            return [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 1.5),
                    ),
                    child: Center(child: Text(step.emoji, style: const TextStyle(fontSize: 16))),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${step.karmaChange > 0 ? '+' : ''}${step.karmaChange}',
                    style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(width: 24, height: 2, color: Colors.grey.shade300, margin: const EdgeInsets.only(bottom: 12)),
            ];
          }),
          // Current node pulsing
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.saffron.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.saffron, width: 2),
                ),
                child: Center(child: Text(currentEmoji, style: const TextStyle(fontSize: 16))),
              ),
              const SizedBox(height: 2),
              const Text('now', style: TextStyle(fontSize: 10, color: AppColors.saffron, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _KarmaBar extends StatelessWidget {
  final int karma;
  const _KarmaBar({required this.karma});

  @override
  Widget build(BuildContext context) {
    // Map karma (-20..+20) to 0..1
    final clamped = karma.clamp(-20, 20);
    final fraction = (clamped + 20) / 40;
    final color = karma > 0 ? const Color(0xFF4CAF50) : karma < 0 ? const Color(0xFFE53935) : Colors.grey;
    return Container(
      height: 4,
      color: Colors.grey.shade200,
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: fraction.toDouble(),
        child: Container(color: color),
      ),
    );
  }
}

class _SituationCard extends StatelessWidget {
  final StoryNode node;
  final String emoji;
  const _SituationCard({required this.node, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.deepBrown, AppColors.saffron],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.saffron.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  node.title,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            node.description,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final int index;
  final StoryChoice choice;
  final int? selectedIndex;
  final bool locked;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.index,
    required this.choice,
    required this.selectedIndex,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;
    final otherSelected = locked && !isSelected;

    Color bg = Colors.white;
    Color border = Colors.grey.shade200;
    Color numBg = AppColors.saffron;

    if (isSelected) {
      final karma = choice.karmaValue;
      bg = karma > 0 ? const Color(0xFFE8F5E9) : karma < 0 ? const Color(0xFFFFEBEE) : const Color(0xFFF5F5F5);
      border = karma > 0 ? const Color(0xFF4CAF50) : karma < 0 ? const Color(0xFFE53935) : Colors.grey;
      numBg = border;
    } else if (otherSelected) {
      bg = Colors.grey.shade50;
      border = Colors.grey.shade200;
      numBg = Colors.grey.shade400;
    }

    return GestureDetector(
      onTap: locked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: isSelected ? 2 : 1),
          boxShadow: isSelected
              ? [BoxShadow(color: border.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: numBg, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: otherSelected ? Colors.grey.shade400 : Colors.black87,
                    ),
                  ),
                  // Only reveal karma impact after selection
                  if (isSelected) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          choice.karmaValue > 0 ? Icons.arrow_upward : choice.karmaValue < 0 ? Icons.arrow_downward : Icons.remove,
                          size: 13,
                          color: choice.karmaValue > 0 ? const Color(0xFF4CAF50) : choice.karmaValue < 0 ? const Color(0xFFE53935) : Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${choice.karmaValue > 0 ? '+' : ''}${choice.karmaValue} karma',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: choice.karmaValue > 0 ? const Color(0xFF4CAF50) : choice.karmaValue < 0 ? const Color(0xFFE53935) : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                choice.karmaValue >= 0 ? Icons.check_circle : Icons.cancel,
                color: choice.karmaValue >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _JourneyRecap extends StatelessWidget {
  final List<_JourneyStep> steps;
  const _JourneyRecap({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final step = e.value;
        final color = step.karmaChange > 0 ? const Color(0xFF4CAF50) : step.karmaChange < 0 ? const Color(0xFFE53935) : Colors.grey;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle, border: Border.all(color: color)),
                  child: Center(child: Text(step.emoji, style: const TextStyle(fontSize: 14))),
                ),
                if (i < steps.length - 1)
                  Container(width: 2, height: 20, color: Colors.grey.shade300),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(step.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    Text(
                      '${step.karmaChange > 0 ? '+' : ''}${step.karmaChange}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

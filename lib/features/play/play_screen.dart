import 'package:flutter/material.dart';

import '../../core/app_dependencies.dart';
import '../../core/constants/colors.dart';
import '../../core/models/game_definition.dart';
import '../../core/widgets/app_gradient_scaffold.dart';
import 'play_controller.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key, PlayController? controller})
    : _controller = controller;

  final PlayController? _controller;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late final PlayController _controller;

  @override
  void initState() {
    super.initState();
    if (widget._controller != null) {
      _controller = widget._controller!;
      _controller.load();
    } else {
      _controller = PlayController(
        progressRepository: AppDependencies.progressRepository,
        progressSyncNotifier: AppDependencies.progressSyncNotifier,
      )..load();
    }
  }

  @override
  void dispose() {
    if (widget._controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return AppGradientScaffold(
          appBar: AppBar(title: const Text('Play & Learn'), centerTitle: true),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _XPOverview(
                  level: _controller.progress.level,
                  xp: _controller.progress.xp,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Games',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _GamesGrid(
                          games: _controller.games,
                          level: _controller.progress.level,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _XPOverview extends StatelessWidget {
  const _XPOverview({required this.level, required this.xp});

  final int level;
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Progress',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('Level $level • $xp XP'),
            ],
          ),
          const Icon(Icons.auto_graph, size: 32, color: AppColors.saffron),
        ],
      ),
    );
  }
}

class _GamesGrid extends StatelessWidget {
  const _GamesGrid({required this.games, required this.level});

  final List<GameDefinition> games;
  final int level;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: games.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        return _GameCard(game: games[index], level: level);
      },
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game, required this.level});

  final GameDefinition game;
  final int level;

  @override
  Widget build(BuildContext context) {
    final unlocked = game.isUnlocked(level);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: unlocked
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: game.builder),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      game.icon,
                      size: 40,
                      color: unlocked ? AppColors.saffron : Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      game.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: unlocked ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (!unlocked)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Icon(Icons.lock, size: 32)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

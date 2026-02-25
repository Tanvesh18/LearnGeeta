import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../games/shloka_match/shloka_match_screen.dart';
import '../games/verse_order/verse_order_screen.dart';
import '../games/true_false/true_false_screen.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play & Learn'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _XPOverview(),
            SizedBox(height: 20),
            Text(
              'Games',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Expanded(child: _GamesGrid()),
          ],
        ),
      ),
    );
  }
}
class _XPOverview extends StatelessWidget {
  const _XPOverview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.saffron.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text('Level 1 • 0 XP'),
            ],
          ),
          Icon(
            Icons.auto_graph,
            size: 32,
            color: AppColors.saffron,
          ),
        ],
      ),
    );
  }
}
class _GamesGrid extends StatelessWidget {
  const _GamesGrid();

  @override
  Widget build(BuildContext context) {
    final games = [
      _GameData('Shloka Match', Icons.extension, true),
      _GameData('Verse Order', Icons.sort, true),
      _GameData('Listen & Guess', Icons.headphones, true),
      _GameData('True or False', Icons.check_circle, true),
      _GameData('Life Situations', Icons.psychology, false),
      _GameData('Boss Battle: Maya', Icons.whatshot, false),
    ];

    return GridView.builder(
      itemCount: games.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        return _GameCard(game: games[index]);
      },
    );
  }
}
class _GameCard extends StatelessWidget {
  final _GameData game;

  const _GameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: game.unlocked
    ? () {
        Widget screen;
        switch (game.title) {
          case 'Verse Order':
            screen = const VerseOrderScreen();
            break;
          case 'True or False':
            screen = const TrueFalseScreen();
            break;
          default:
            screen = const ShlokaMatchScreen();
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      }
    : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                    color: game.unlocked
                        ? AppColors.saffron
                        : Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    game.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: game.unlocked
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (!game.unlocked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.lock, size: 32),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
class _GameData {
  final String title;
  final IconData icon;
  final bool unlocked;

  _GameData(this.title, this.icon, this.unlocked);
}
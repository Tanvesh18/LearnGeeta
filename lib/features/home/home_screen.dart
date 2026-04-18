import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/app_dependencies.dart';
import '../../core/constants/colors.dart';
import '../../core/models/game_definition.dart';
import '../../core/widgets/app_gradient_scaffold.dart';
import '../learn/gita_reader_screen.dart';
import '../play/play_registry.dart';
import '../play/play_screen.dart';
import '../profile/profile_screen.dart';
import 'home_controller.dart';

const List<({String sanskrit, String meaning})> _shlokaPool = [
  (
    sanskrit: 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन ।',
    meaning:
        'You have the right to perform your duty, but not to the fruits of your actions.',
  ),
  (
    sanskrit: 'योगस्थः कुरु कर्माणि सङ्गं त्यक्त्वा धनञ्जय ।',
    meaning: 'Be steadfast in yoga, perform actions, abandoning attachment.',
  ),
  (
    sanskrit: 'न हि ज्ञानेन सदृशं पवित्रमिह विद्यते ।',
    meaning: 'In this world, nothing purifies like true knowledge.',
  ),
  (
    sanskrit: 'उद्धरेदात्मनाऽत्मानं नात्मानमवसादयेत् ।',
    meaning: 'Lift yourself by your own mind; do not degrade yourself.',
  ),
  (
    sanskrit: 'श्रद्धावान् लभते ज्ञानं तत्परः संयतेन्द्रियः ।',
    meaning: 'The faithful, devoted, and self-controlled attain true wisdom.',
  ),
  (
    sanskrit: 'समः शत्रौ च मित्रे च तथा मानापमानयोः ।',
    meaning: 'See friend and enemy, honor and dishonor, with equal vision.',
  ),
  (
    sanskrit: 'वासांसि जीर्णानि यथा विहाय नवानि गृह्णाति नरोऽपराणि ।',
    meaning:
        'As a person casts off worn-out garments and puts on new ones, so the soul casts off worn-out bodies.',
  ),
  (
    sanskrit: 'आत्मैव ह्यात्मनो बन्धुरात्मैव रिपुरात्मनः ।',
    meaning:
        'The self is the friend of the self; the self is also the enemy of the self.',
  ),
  (
    sanskrit: 'यदा यदा हि धर्मस्य ग्लानिर्भवति भारत ।',
    meaning:
        'Whenever righteousness declines and unrighteousness rises, I manifest myself.',
  ),
  (
    sanskrit: 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन मा कर्मफलहेतुर्भूः ।',
    meaning:
        'Focus on action alone, never on its fruits; do not let the fruits be your motive.',
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;
  late FlutterTts _flutterTts;
  ({String sanskrit, String meaning})? _shlokaOfDay;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(
      profileRepository: AppDependencies.profileRepository,
      progressRepository: AppDependencies.progressRepository,
      progressSyncNotifier: AppDependencies.progressSyncNotifier,
    )..load();
    _flutterTts = FlutterTts();

    final today = DateTime.now();
    final daySeed =
        DateTime(today.year, today.month, today.day).millisecondsSinceEpoch ~/
        const Duration(days: 1).inMilliseconds;
    _shlokaOfDay = _shlokaPool[daySeed % _shlokaPool.length];
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _speakCurrentShloka() async {
    final shloka = _shlokaOfDay;
    if (shloka == null) return;

    try {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Playing shloka...')));
      await _flutterTts.stop();
      await _flutterTts.setLanguage('en-IN');
      await _flutterTts.setSpeechRate(0.6);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(shloka.meaning);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio not available on this device yet.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading || _shlokaOfDay == null) {
          return AppGradientScaffold(
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final progress = _controller.progress;
        final profile = _controller.profile;
        final shloka = _shlokaOfDay!;

        return AppGradientScaffold(
          appBar: AppBar(
            title: const Text(
              "LearnGeeta",
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2), // border thickness
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.saffron.withValues(alpha: 0.2),
                      child: Text(
                        (profile?.fullName.trim().isNotEmpty ?? false)
                            ? profile!.fullName
                                  .trim()
                                  .characters
                                  .first
                                  .toUpperCase()
                            : 'ॐ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GreetingSection(
                  streak: progress?.streak ?? 0,
                  name: profile?.fullName,
                ),
                const SizedBox(height: 20),
                _JourneySection(
                  level: progress?.level ?? 1,
                  xp: progress?.xp ?? 0,
                  streak: progress?.streak ?? 0,
                ),
                const SizedBox(height: 20),
                _ShlokaCard(
                  sanskrit: shloka.sanskrit,
                  meaning: shloka.meaning,
                  onListen: _speakCurrentShloka,
                ),
                const SizedBox(height: 20),
                _ActionButtons(level: progress?.level ?? 1),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GreetingSection extends StatefulWidget {
  const _GreetingSection({required this.streak, this.name});

  final int streak;
  final String? name;

  @override
  State<_GreetingSection> createState() => _GreetingSectionState();
}

class _GreetingSectionState extends State<_GreetingSection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final baseGreeting = hour < 12
        ? 'Good Morning'
        : (hour < 17 ? 'Good Afternoon' : 'Good Evening');
    final displayName = (widget.name != null && widget.name!.trim().isNotEmpty)
        ? widget.name!.trim().split(' ').first
        : '';
    final greetingText = displayName.isEmpty
        ? baseGreeting
        : '$baseGreeting $displayName';
    final isHighStreak = widget.streak >= 7;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      greetingText,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Keep walking the path of Dharma',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.saffron.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.streak} Day Streak',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _JourneySection extends StatelessWidget {
  const _JourneySection({
    required this.level,
    required this.xp,
    required this.streak,
  });

  final int level;
  final int xp;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final xpForNextLevel = level * 100;
    final xpInCurrentLevel = xp.clamp(0, xpForNextLevel);
    final progress = xpForNextLevel == 0
        ? 0.0
        : xpInCurrentLevel / xpForNextLevel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Journey',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _journeyStat('Level', level.toString()),
              _journeyStat('XP', xp.toString()),
              _journeyStat('Streak', '$streak days'),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.softGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.saffron,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Level $level • $xpInCurrentLevel / $xpForNextLevel XP',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _journeyStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _ShlokaCard extends StatelessWidget {
  const _ShlokaCard({
    required this.sanskrit,
    required this.meaning,
    required this.onListen,
  });

  final String sanskrit;
  final String meaning;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Om Shloka of the Day',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            sanskrit,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(meaning, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onListen,
            child: Row(
              children: [
                const Icon(Icons.volume_up, color: AppColors.saffron),
                const SizedBox(width: 6),
                Text(
                  'Listen',
                  style: TextStyle(
                    color: AppColors.saffron,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final GameDefinition todaysGame;
    if (level <= 2) {
      todaysGame = GameRegistry.games.firstWhere(
        (game) => game.id == 'true_false',
      );
    } else if (level <= 4) {
      todaysGame = GameRegistry.games.firstWhere(
        (game) => game.id == 'shloka_match',
      );
    } else {
      todaysGame = GameRegistry.games.firstWhere(
        (game) => game.id == 'verse_order',
      );
    }

    return Column(
      children: [
        _ActionButton(
          icon: Icons.menu_book,
          title: 'Continue Learning',
          subtitle: 'Read the Bhagavad Gita',
          color: Colors.white,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GitaReaderScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _TodayGoalCard(level: level),
        const SizedBox(height: 12),
        _ActionButton(
          icon: Icons.videogame_asset,
          title: 'Play Today\'s Game',
          subtitle: todaysGame.title,
          color: AppColors.gold,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PlayScreen()),
            );
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: color == Colors.white ? AppColors.saffron : color,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayGoalCard extends StatelessWidget {
  const _TodayGoalCard({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final String goalText;
    if (level <= 2) {
      goalText = 'Play 1 True or False game';
    } else if (level <= 4) {
      goalText = 'Complete 1 Shloka Match game';
    } else {
      goalText = 'Finish 1 Verse Order challenge';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.flag, size: 32, color: AppColors.saffron),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s Goal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(goalText, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 4),
                const Text(
                  'Progress tracking coming soon',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

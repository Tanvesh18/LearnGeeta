import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/constants/colors.dart';
import '../profile/profile_service.dart';
import '../profile/profile_screen.dart';
import '../play/play_screen.dart';

/// Shloka pool for "Shloka of the Day" — changes each time home loads (e.g. on login)
const List<({String sanskrit, String meaning})> _shlokaPool = [
  (sanskrit: 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन ।', meaning: 'You have the right to perform your duty, but not to the fruits of your actions.'),
  (sanskrit: 'योगस्थः कुरु कर्माणि सङ्गं त्यक्त्वा धनञ्जय ।', meaning: 'Be steadfast in yoga, perform actions, abandoning attachment.'),
  (sanskrit: 'न हि ज्ञानेन सदृशं पवित्रमिह विद्यते ।', meaning: 'In this world, nothing purifies like true knowledge.'),
  (sanskrit: 'उद्धरेदात्मनाऽऽत्मानं नात्मानमवसादयेत् ।', meaning: 'Lift yourself by your own mind; do not degrade yourself.'),
  (sanskrit: 'श्रद्धावान् लभते ज्ञानं तत्परः संयतेन्द्रियः ।', meaning: 'The faithful, devoted and self-controlled attain true wisdom.'),
  (sanskrit: 'समः शत्रौ च मित्रे च तथा मानापमानयोः ।', meaning: 'See friend and enemy, honour and dishonour, with equal vision.'),
  (sanskrit: 'वासांसि जीर्णानि यथा विहाय नवानि गृह्णाति नरोऽपराणि ।', meaning: 'As a person casts off worn-out garments and puts on new ones, so the soul casts off worn-out bodies.'),
  (sanskrit: 'आत्मैव ह्यात्मनो बन्धुरात्मैव रिपुरात्मनः ।', meaning: 'The self is the friend of the self; the self is also the enemy of the self.'),
  (sanskrit: 'यदा यदा हि धर्मस्य ग्लानिर्भवति भारत ।', meaning: 'Whenever righteousness declines and unrighteousness rises, I manifest Myself.'),
  (sanskrit: 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन मा कर्मफलहेतुर्भूः ।', meaning: 'Focus on action alone, never on its fruits; do not let the fruits be your motive.'),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _streak = 0;
  bool _loading = true;
  String? _userName;
  int _level = 1;
  int _xp = 0;
  ({String sanskrit, String meaning})? _shlokaOfDay;
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    // Deterministic "shloka of the day" based on calendar date
    final today = DateTime.now();
    final daySeed = DateTime(today.year, today.month, today.day)
        .millisecondsSinceEpoch ~/
        const Duration(days: 1).inMilliseconds;
    final index = daySeed % _shlokaPool.length;
    _shlokaOfDay = _shlokaPool[index];
    _initStreak();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _speakCurrentShloka() async {
    final shloka = _shlokaOfDay;
    if (shloka == null) return;

    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Playing shloka...')),
      );

      // Basic settings; you can tweak pitch/speed later
      await _flutterTts.stop();
      await _flutterTts.setLanguage('en-IN'); // English voice for meaning
      await _flutterTts.setSpeechRate(0.6);
      await _flutterTts.setPitch(1.0);
      // Speak the English meaning so it works reliably on Windows
      await _flutterTts.speak(shloka.meaning);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio not available on this device yet.'),
        ),
      );
    }
  }

  Future<void> _initStreak() async {
    try {
      final service = ProfileService();
      // Fetch profile to get the user's name
      final data = await service.fetchProfile();
      final profile = data['profile'] as Map<String, dynamic>;
       final progress = data['progress'] as Map<String, dynamic>;
      final fullName = (profile['full_name'] as String?)?.trim();

      final streak = await service.updateDailyStreak();

      setState(() {
        _streak = streak;
        _userName = fullName;
        _level = (progress['level'] as int?) ?? 1;
        _xp = (progress['xp'] as int?) ?? 0;
      });
    } catch (e) {
      // silently fail for now
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final shloka = _shlokaOfDay;
    if (shloka == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('LearnGeeta'),
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
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.saffron.withOpacity(0.2),
                child: Text(
                  (_userName != null && _userName!.trim().isNotEmpty)
                      ? _userName!.trim().characters.first.toUpperCase()
                      : '🕉️',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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
            _GreetingSection(streak: _streak, name: _userName),
            const SizedBox(height: 20),
            _JourneySection(level: _level, xp: _xp, streak: _streak),
            const SizedBox(height: 20),
            _ShlokaCard(
              sanskrit: shloka.sanskrit,
              meaning: shloka.meaning,
              onListen: _speakCurrentShloka,
            ),
            const SizedBox(height: 20),
            _ActionButtons(level: _level),
          ],
        ),
      ),
    );
  }
}
class _GreetingSection extends StatefulWidget {
  final int streak;
  final String? name;

  const _GreetingSection({required this.streak, this.name});

  @override
  State<_GreetingSection> createState() => _GreetingSectionState();
}

class _GreetingSectionState extends State<_GreetingSection>
    with TickerProviderStateMixin {
  late AnimationController _fireController;
  late Animation<double> _fireScale;

  late AnimationController _flowerController;
  late Animation<double> _flowerFloat;
  late Animation<double> _flowerRotate;

  @override
  void initState() {
    super.initState();

    // 🔥 Fire animation
    _fireController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _fireScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _fireController, curve: Curves.easeInOut),
    );

    // 🌸 Flower animation
    _flowerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _flowerFloat = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _flowerController, curve: Curves.easeInOut),
    );

    _flowerRotate = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _flowerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fireController.dispose();
    _flowerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final baseGreeting = hour < 12
        ? 'Good Morning'
        : (hour < 17 ? 'Good Afternoon' : 'Good Evening');

    final displayName =
        (widget.name != null && widget.name!.trim().isNotEmpty)
            ? widget.name!.trim().split(' ').first
            : '';

    final greetingText = displayName.isEmpty
        ? baseGreeting
        : '$baseGreeting $displayName';

    final isHighStreak = widget.streak >= 7;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  greetingText,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedBuilder(
                  animation: _flowerController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _flowerFloat.value),
                      child: Transform.rotate(
                        angle: _flowerRotate.value,
                        child: const Text(
                          '🌸',
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    );
                  },
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
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.saffron.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              ScaleTransition(
                scale: _fireScale,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: isHighStreak
                        ? [
                            BoxShadow(
                              color: Colors.orangeAccent.withOpacity(0.6),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    Icons.local_fire_department,
                    color: isHighStreak
                        ? Colors.orangeAccent
                        : AppColors.saffron,
                  ),
                ),
              ),
              const SizedBox(width: 4),
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
  final int level;
  final int xp;
  final int streak;

  const _JourneySection({
    required this.level,
    required this.xp,
    required this.streak,
  });

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
            color: Colors.black.withOpacity(0.04),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.saffron),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _ShlokaCard extends StatelessWidget {
  final String sanskrit;
  final String meaning;
  final VoidCallback onListen;

  const _ShlokaCard({
    required this.sanskrit,
    required this.meaning,
    required this.onListen,
  });

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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🕉️ Shloka of the Day',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            sanskrit,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            meaning,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onListen,
            child: Row(
              children: [
                Icon(Icons.volume_up, color: AppColors.saffron),
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
  final int level;
  const _ActionButtons({required this.level});

  @override
  Widget build(BuildContext context) {
    final String todaysGameTitle;
    if (level <= 2) {
      todaysGameTitle = 'True or False';
    } else if (level <= 4) {
      todaysGameTitle = 'Shloka Match';
    } else {
      todaysGameTitle = 'Verse Order';
    }

    return Column(
      children: [
        _ActionButton(
          icon: Icons.menu_book,
          title: 'Continue Learning',
          subtitle: 'Chapter 12 • Bhakti Yoga',
          color: AppColors.saffron,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _TodayGoalCard(level: level),
        const SizedBox(height: 12),
        _ActionButton(
          icon: Icons.videogame_asset,
          title: 'Play Today’s Game',
          subtitle: todaysGameTitle,
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
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
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
  final int level;

  const _TodayGoalCard({required this.level});

  @override
  Widget build(BuildContext context) {
    // Simple, level-aware goal text for now
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
        color: AppColors.gold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today’s Goal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            goalText,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'Progress tracking coming soon ✨',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
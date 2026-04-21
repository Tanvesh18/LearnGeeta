import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import '../../../core/app_dependencies.dart';
import '../../../core/constants/colors.dart';
import 'models/wheel_model.dart';

class WheelOfGunasScreen extends StatefulWidget {
  const WheelOfGunasScreen({super.key});

  @override
  State<WheelOfGunasScreen> createState() => _WheelOfGunasScreenState();
}

class _WheelOfGunasScreenState extends State<WheelOfGunasScreen>
    with TickerProviderStateMixin {
  late GameState gameState;
  bool _isLoading = true;
  WheelSituation? currentSituation;
  GunaType? selectedGuna;
  GunaType? _landedGuna;
  bool hasAnswered = false;
  bool isCorrect = false;
  int _lastEarnedXp = 0;
  bool _isSpinning = false;

  late ConfettiController _confettiController;
  final Set<String> _seenSituations = {};
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
      upperBound: 12.0,
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _initializeGame();
  }

  @override
  void dispose() {
    _spinController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    final prefs = await SharedPreferences.getInstance();
    gameState = GameState(
      level: prefs.getInt('wheelGunasLevel') ?? 1,
      score: prefs.getInt('wheelGunasScore') ?? 0,
      streak: prefs.getInt('wheelGunasStreak') ?? 0,
      maxStreak: prefs.getInt('wheelGunasMaxStreak') ?? 0,
    );
    _seenSituations.clear();
    _loadNewSituation();
    setState(() => _isLoading = false);
  }

  void _loadNewSituation() {
    setState(() {
      selectedGuna = null;
      _landedGuna = null;
      hasAnswered = false;
      isCorrect = false;
    });
    _spinWheel();
  }

  String _getDifficultyForLevel(int level) {
    if (level <= 3) return 'easy';
    if (level <= 7) return 'medium';
    return 'hard';
  }

  GunaType _gunaFromAngle(double turns) {
    // The wheel has 3 equal segments starting at -pi/2 (top):
    //   Sattva: -pi/2 to pi/6   (top segment)
    //   Rajas:  pi/6 to 5*pi/6  (right segment)
    //   Tamas:  5*pi/6 to 3*pi/2 (left segment)
    // The pointer is fixed at top (12 o'clock). We find which segment
    // of the wheel is currently under the pointer.
    // As the wheel rotates by `angle`, the segment that was at angle 0
    // (top = Sattva start) moves. The pointer sees the segment whose
    // original start offset is (-angle) mod 2*pi.
    final angle = (turns * 2 * pi) % (2 * pi);
    // Effective position of pointer relative to wheel = -angle (mod 2pi)
    double pos = (-angle) % (2 * pi);
    if (pos < 0) pos += 2 * pi;
    // Segments: Sattva [0, 2pi/3), Rajas [2pi/3, 4pi/3), Tamas [4pi/3, 2pi)
    // But wheel starts with Sattva at top (-pi/2 offset), so we shift:
    pos = (pos + pi / 2) % (2 * pi);
    if (pos < 2 * pi / 3) return GunaType.sattva;
    if (pos < 4 * pi / 3) return GunaType.rajas;
    return GunaType.tamas;
  }

  void _spinWheel() {
    setState(() => _isSpinning = true);

    final random = Random();
    final spins = 5 + random.nextInt(5);
    // Pick a random landing fraction within one of the 3 segments
    final segmentIndex = random.nextInt(3);
    final segmentFraction = (segmentIndex / 3) + random.nextDouble() / 3;
    final finalTurns = spins.toDouble() + segmentFraction;

    _spinController.reset();
    _spinController
        .animateTo(finalTurns, curve: Curves.decelerate)
        .whenComplete(() {
          if (!mounted) return;
          final landed = _gunaFromAngle(finalTurns);
          _pickQuestionForGuna(landed);
          setState(() {
            _landedGuna = landed;
            _isSpinning = false;
          });
        });
  }

  void _pickQuestionForGuna(GunaType guna) {
    if (_seenSituations.length == wheelDatabase.length) {
      _seenSituations.clear();
    }

    final targetDifficulty = _getDifficultyForLevel(gameState.level);
    final byGuna = wheelDatabase
        .where((s) => s.correctGuna == guna && !_seenSituations.contains(s.situation))
        .toList();

    List<WheelSituation> pool = byGuna
        .where((s) => s.difficulty == targetDifficulty)
        .toList();
    if (pool.isEmpty) pool = byGuna;
    if (pool.isEmpty) {
      // Fallback: any unseen question
      final remaining = wheelDatabase
          .where((s) => !_seenSituations.contains(s.situation))
          .toList();
      pool = remaining.isEmpty ? wheelDatabase : remaining;
    }

    currentSituation = pool[Random().nextInt(pool.length)];
    _seenSituations.add(currentSituation!.situation);
  }

  void _selectGuna(GunaType guna) {
    if (hasAnswered || _isSpinning) return;

    if (currentSituation == null) return;
    final correct = guna == currentSituation!.correctGuna;

    setState(() {
      selectedGuna = guna;
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

    _saveGameState();
    Future.delayed(const Duration(milliseconds: 800), _showResultDialog);
  }

  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('wheelGunasLevel', gameState.level);
    await prefs.setInt('wheelGunasScore', gameState.score);
    await prefs.setInt('wheelGunasStreak', gameState.streak);
    await prefs.setInt('wheelGunasMaxStreak', gameState.maxStreak);
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
                  isCorrect ? 'Guna Guru! 🌀' : 'Keep Learning',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? AppColors.success : AppColors.saffron,
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
                  Text(
                    'Correct: ${_getGunaName(currentSituation!.correctGuna)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.saffron,
                    ),
                  ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentSituation!.explanation,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _loadNewSituation();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.saffron,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Spin Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGunaName(GunaType type) {
    return gunaOptions.firstWhere((option) => option.type == type).name;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wheel of Gunas'),
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
        decoration: BoxDecoration(
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
                  // Score
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      'Score: ${gameState.score}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Spinning Wheel with pointer
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowColor,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: AnimatedBuilder(
                          animation: _spinController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _spinController.value * 2 * pi,
                              child: CustomPaint(
                                painter: WheelPainter(),
                                child: const Center(
                                  child: Icon(
                                    Icons.refresh,
                                    size: 40,
                                    color: AppColors.saffron,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Pointer triangle at top
                      const Icon(Icons.arrow_drop_down, color: Colors.black87, size: 28),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Landed guna banner
                  if (_landedGuna != null && !_isSpinning)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: gunaOptions.firstWhere((g) => g.type == _landedGuna).color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: gunaOptions.firstWhere((g) => g.type == _landedGuna).color.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'The wheel landed on ${gunaOptions.firstWhere((g) => g.type == _landedGuna).name}! Which guna does this describe?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: gunaOptions.firstWhere((g) => g.type == _landedGuna).color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Situation
                  if (!_isSpinning)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowColor,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        currentSituation!.situation,
                        style: const TextStyle(fontSize: 16, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Spinning...',
                        style: TextStyle(fontSize: 16, color: AppColors.saffron, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Guna Options
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: gunaOptions.map((guna) {
                        final isSelected = selectedGuna == guna.type;
                        final isCorrectOption =
                            guna.type == currentSituation!.correctGuna;

                        Color backgroundColor = Colors.white;
                        if (hasAnswered) {
                          if (isCorrectOption) {
                            backgroundColor = Colors.green.shade100;
                          } else if (isSelected && !isCorrect) {
                            backgroundColor = Colors.red.shade100;
                          }
                        } else if (isSelected) {
                          backgroundColor = guna.color.withValues(alpha: 0.1);
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: (hasAnswered || _isSpinning)
                                  ? null
                                  : () => _selectGuna(guna.type),
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
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: guna.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            guna.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  hasAnswered && isCorrectOption
                                                  ? Colors.green.shade800
                                                  : Colors.black,
                                            ),
                                          ),
                                          Text(
                                            guna.description,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  hasAnswered && isCorrectOption
                                                  ? Colors.green.shade700
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
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
                      }).toList(),
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

class WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw wheel segments
    final paint = Paint()..style = PaintingStyle.fill;

    // Sattva (Green)
    paint.color = const Color(0xFF4CAF50);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi / 3,
      true,
      paint,
    );

    // Rajas (Orange)
    paint.color = const Color(0xFFFF9800);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi / 6,
      2 * pi / 3,
      true,
      paint,
    );

    // Tamas (Purple)
    paint.color = const Color(0xFF9C27B0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      5 * pi / 6,
      2 * pi / 3,
      true,
      paint,
    );

    // Draw segment labels
    final labels = ['Sattva', 'Rajas', 'Tamas'];
    final labelAngles = [-pi / 2 + pi / 3, pi / 6 + pi / 3, 5 * pi / 6 + pi / 3];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < 3; i++) {
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      final labelX = center.dx + cos(labelAngles[i]) * radius * 0.6 - textPainter.width / 2;
      final labelY = center.dy + sin(labelAngles[i]) * radius * 0.6 - textPainter.height / 2;
      textPainter.paint(canvas, Offset(labelX, labelY));
    }

    // Draw center circle
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.1, paint);

    // Draw segment lines
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 3; i++) {
      final angle = i * 2 * pi / 3 - pi / 2;
      canvas.drawLine(
        center,
        center + Offset(cos(angle) * radius, sin(angle) * radius),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

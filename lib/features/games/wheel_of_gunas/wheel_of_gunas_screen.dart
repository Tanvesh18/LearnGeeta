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
  WheelSituation? _currentSituation;
  GunaType? _selectedGuna;
  bool _hasAnswered = false;
  bool _isCorrect = false;
  int _lastEarnedXp = 0;
  bool _isSpinning = false;
  bool _showQuestion = false;

  late ConfettiController _confettiController;
  final Set<String> _seenSituations = {};
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
      upperBound: 20.0,
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
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
    setState(() => _isLoading = false);
  }

  void _spin() {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
      _showQuestion = false;
      _selectedGuna = null;
      _hasAnswered = false;
      _isCorrect = false;
    });

    final random = Random();
    final spins = 6 + random.nextInt(6);
    final extra = random.nextDouble();
    final finalTurns = spins.toDouble() + extra;

    _spinController.reset();
    _spinController.animateTo(finalTurns, curve: Curves.decelerate).whenComplete(() {
      if (!mounted) return;
      _pickRandomQuestion();
      setState(() {
        _isSpinning = false;
        _showQuestion = true;
      });
    });
  }

  String _getDifficultyForLevel(int level) {
    if (level <= 3) return 'easy';
    if (level <= 7) return 'medium';
    return 'hard';
  }

  void _pickRandomQuestion() {
    if (_seenSituations.length >= wheelDatabase.length) {
      _seenSituations.clear();
    }
    final targetDifficulty = _getDifficultyForLevel(gameState.level);
    final unseen = wheelDatabase.where((s) => !_seenSituations.contains(s.situation)).toList();
    List<WheelSituation> pool = unseen.where((s) => s.difficulty == targetDifficulty).toList();
    if (pool.isEmpty) pool = unseen;
    if (pool.isEmpty) pool = wheelDatabase;
    _currentSituation = pool[Random().nextInt(pool.length)];
    _seenSituations.add(_currentSituation!.situation);
  }

  void _selectGuna(GunaType guna) {
    if (_hasAnswered || _isSpinning || _currentSituation == null) return;
    final correct = guna == _currentSituation!.correctGuna;
    setState(() {
      _selectedGuna = guna;
      _hasAnswered = true;
      _isCorrect = correct;
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
    Future.delayed(const Duration(milliseconds: 700), _showResultDialog);
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isCorrect ? 'Correct! 🌀' : 'Not quite',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _isCorrect ? AppColors.success : AppColors.saffron,
                ),
              ),
              const SizedBox(height: 12),
              if (_isCorrect)
                Text('+$_lastEarnedXp XP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
              else
                Text(
                  'It was ${_getGunaName(_currentSituation!.correctGuna)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.saffron),
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.gradientStart,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _currentSituation!.explanation,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () { Navigator.of(context).pop(); _spin(); },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.saffron,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: const Text('Spin Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGunaName(GunaType type) =>
      gunaOptions.firstWhere((o) => o.type == type).name;

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
              'Score: ${gameState.score}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  // Wheel section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Spin the Wheel',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.deepBrown),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Then identify the guna from the situation',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 20),
                        // Wheel with fixed pointer
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: AnimatedBuilder(
                                animation: _spinController,
                                builder: (context, _) => Transform.rotate(
                                  angle: _spinController.value * 2 * pi,
                                  child: CustomPaint(
                                    size: const Size(220, 220),
                                    painter: WheelPainter(),
                                  ),
                                ),
                              ),
                            ),
                            // Fixed pointer
                            CustomPaint(
                              size: const Size(30, 24),
                              painter: _PointerPainter(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Color legend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: gunaOptions.map((g) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 12, height: 12, decoration: BoxDecoration(color: g.color, shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Text(g.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          )).toList(),
                        ),
                        const SizedBox(height: 20),
                        // Spin button
                        ElevatedButton.icon(
                          onPressed: _isSpinning ? null : _spin,
                          icon: _isSpinning
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.refresh),
                          label: Text(_isSpinning ? 'Spinning...' : (_showQuestion ? 'Spin Again' : 'Spin!')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.saffron,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Question section
                  if (_showQuestion && _currentSituation != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Which guna does this describe?',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _currentSituation!.situation,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Answer options
                    ...gunaOptions.map((guna) {
                      final isSelected = _selectedGuna == guna.type;
                      final isCorrectOption = guna.type == _currentSituation!.correctGuna;
                      Color bg = Colors.white;
                      Color borderColor = Colors.grey.shade200;
                      if (_hasAnswered) {
                        if (isCorrectOption) { bg = Colors.green.shade50; borderColor = Colors.green; }
                        else if (isSelected) { bg = Colors.red.shade50; borderColor = Colors.red.shade300; }
                      }
                      return GestureDetector(
                        onTap: (_hasAnswered || _isSpinning) ? null : () => _selectGuna(guna.type),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor, width: _hasAnswered && isCorrectOption ? 2 : 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(color: guna.color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      guna.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: _hasAnswered && isCorrectOption ? Colors.green.shade800 : Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      guna.description,
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              if (_hasAnswered && isCorrectOption)
                                const Icon(Icons.check_circle, color: Colors.green, size: 20)
                              else if (_hasAnswered && isSelected && !_isCorrect)
                                Icon(Icons.cancel, color: Colors.red.shade400, size: 20),
                            ],
                          ),
                        ),
                      );
                    }),
                  ] else if (!_isSpinning && !_showQuestion)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Text('🌀', style: TextStyle(fontSize: 40)),
                          SizedBox(height: 12),
                          Text(
                            'Press Spin to get a question!\nIdentify whether the situation is Sattva, Rajas, or Tamas.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
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
    final paint = Paint()..style = PaintingStyle.fill;

    final segments = [
      (color: const Color(0xFF4CAF50), start: -pi / 2, label: 'S'),         // Sattva
      (color: const Color(0xFFFF9800), start: -pi / 2 + 2 * pi / 3, label: 'R'), // Rajas
      (color: const Color(0xFF9C27B0), start: -pi / 2 + 4 * pi / 3, label: 'T'), // Tamas
    ];

    for (final seg in segments) {
      paint.color = seg.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        seg.start,
        2 * pi / 3,
        true,
        paint,
      );
    }

    // Dividers
    final line = Paint()..color = Colors.white..strokeWidth = 3..style = PaintingStyle.stroke;
    for (int i = 0; i < 3; i++) {
      final angle = -pi / 2 + i * 2 * pi / 3;
      canvas.drawLine(center, center + Offset(cos(angle) * radius, sin(angle) * radius), line);
    }

    // Center cap
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.12, paint);
    paint.color = AppColors.saffron;
    canvas.drawCircle(center, radius * 0.08, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 - 8, 0)
      ..lineTo(size.width / 2 + 8, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Model definitions for Shloka Speed Run game

class SpeedRunQuestion {
  final String type; // 'meaning' | 'missing_word' | 'chapter'
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String? verse; // for reference
  final String? shloka; // for reference
  final int difficulty; // 1-5 progressive difficulty

  const SpeedRunQuestion({
    required this.type,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.verse,
    this.shloka,
    required this.difficulty,
  });
}

class GameState {
  int level;
  int score;
  int streak;
  int maxStreak;
  int comboMultiplier;

  GameState({
    this.level = 1,
    this.score = 0,
    this.streak = 0,
    this.maxStreak = 0,
    this.comboMultiplier = 1,
  });

  GameState copyWith({
    int? level,
    int? score,
    int? streak,
    int? maxStreak,
    int? comboMultiplier,
  }) {
    return GameState(
      level: level ?? this.level,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      maxStreak: maxStreak ?? this.maxStreak,
      comboMultiplier: comboMultiplier ?? this.comboMultiplier,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'score': score,
      'streak': streak,
      'maxStreak': maxStreak,
      'comboMultiplier': comboMultiplier,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      level: json['level'] as int? ?? 1,
      score: json['score'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      maxStreak: json['maxStreak'] as int? ?? 0,
      comboMultiplier: json['comboMultiplier'] as int? ?? 1,
    );
  }
}

// Database of 20 speed run questions (mixed types, levels 1-5, 4 per level)
const List<SpeedRunQuestion> speedRunDatabase = [
  // Level 1 - Easy (mostly meaning)
  SpeedRunQuestion(
    type: 'meaning',
    question: 'What does "Atman" mean in Hindu philosophy?',
    options: ['Body', 'Soul / Self', 'Mind', 'Breath'],
    correctOptionIndex: 1,
    verse: '2.13',
    difficulty: 1,
  ),
  SpeedRunQuestion(
    type: 'meaning',
    question: '"Karma" refers to:',
    options: ['Prayer', 'Action and its consequences', 'Meditation', 'Destiny'],
    correctOptionIndex: 1,
    difficulty: 1,
  ),
  SpeedRunQuestion(
    type: 'chapter',
    question:
        'In which chapter is the most famous Gita dialogue between Arjuna and Krishna?',
    options: ['Chapter 5', 'Chapter 1', 'Chapter 2', 'Chapter 10'],
    correctOptionIndex: 2,
    verse: '2.1',
    difficulty: 1,
  ),
  SpeedRunQuestion(
    type: 'meaning',
    question: '"Dharma" is best described as:',
    options: ['Sin', 'Duty / Righteousness', 'War', 'Wealth'],
    correctOptionIndex: 1,
    difficulty: 1,
  ),
  // Level 2 - Medium (mix of types)
  SpeedRunQuestion(
    type: 'missing_word',
    question: 'Complete the verse: "Karmanyevadhikaraste Ma ___ Kadachana"',
    options: ['Dhyana', 'Phaleshu', 'Bhakti', 'Yoga'],
    correctOptionIndex: 1,
    difficulty: 2,
  ),
  SpeedRunQuestion(
    type: 'meaning',
    question: 'What is "Bhakti" in the context of Gita?',
    options: [
      'Knowledge',
      'Devotion / Love for the divine',
      'Action',
      'Wealth',
    ],
    correctOptionIndex: 1,
    difficulty: 2,
  ),
  SpeedRunQuestion(
    type: 'chapter',
    question: 'The Gita has how many chapters?',
    options: ['8', '10', '12', '18'],
    correctOptionIndex: 3,
    difficulty: 2,
  ),
  SpeedRunQuestion(
    type: 'meaning',
    question: '"Moksha" refers to:',
    options: ['Wealth', 'Enlightenment / Liberation', 'Battle', 'Punishment'],
    correctOptionIndex: 1,
    difficulty: 2,
  ),
  // Level 3 - Medium-Hard (more missing words)
  SpeedRunQuestion(
    type: 'missing_word',
    question: 'Fill in: "Yoga-Sthaḥ Kuru Karmāṇi Saṅgaṁ ___ Dhanañ-Jaya"',
    options: ['Samarpya', 'Tyaktvā', 'Bandha', 'Samupasri'],
    correctOptionIndex: 1,
    difficulty: 3,
  ),
  SpeedRunQuestion(
    type: 'meaning',
    question: 'What is "Prakriti"?',
    options: ['God', 'Nature / Material world', 'Soul', 'Action'],
    correctOptionIndex: 1,
    difficulty: 3,
  ),
  SpeedRunQuestion(
    type: 'chapter',
    question: 'Which chapter focuses on "Bhakti Yoga"?',
    options: ['Chapter 5', 'Chapter 8', 'Chapter 12', 'Chapter 6'],
    correctOptionIndex: 2,
    verse: '12',
    difficulty: 3,
  ),
  SpeedRunQuestion(
    type: 'missing_word',
    question: 'Complete: "Uddhared Ātmānā ___ Nāt-Mā-Nam Avasādayet"',
    options: ['Karmańa', 'Ātmānam', 'Bhakti', 'Jnana'],
    correctOptionIndex: 1,
    difficulty: 3,
  ),
  // Level 4 - Hard (advanced Sanskrit)
  SpeedRunQuestion(
    type: 'missing_word',
    question:
        'Fill in: "Brahma-Bhūtaḥ Prasannātmā Na Śocati Na Kāṅkṣati Sa ___"',
    options: ['Samah', 'Yasmin', 'Sarvadā', 'Samantataḥ'],
    correctOptionIndex: 0,
    difficulty: 4,
  ),
  SpeedRunQuestion(
    type: 'meaning',
    question: 'What is "Sattva" in the context of Gunas?',
    options: ['Darkness', 'Purity / Goodness', 'Passion', 'Ignorance'],
    correctOptionIndex: 1,
    difficulty: 4,
  ),
  SpeedRunQuestion(
    type: 'chapter',
    question:
        'The concept of "Jnana Yoga" (Yoga of Knowledge) is emphasized in which chapter?',
    options: ['Chapter 4', 'Chapter 13', 'Chapter 8', 'Chapter 15'],
    correctOptionIndex: 1,
    difficulty: 4,
  ),
  SpeedRunQuestion(
    type: 'meaning',
    question: 'What does "Kundalini" refer to?',
    options: ['A weapon', 'Coiled spiritual energy', 'A mantra', 'A place'],
    correctOptionIndex: 1,
    difficulty: 4,
  ),
  // Level 5 - Expert (complex meanings & Sanskrit)
  SpeedRunQuestion(
    type: 'missing_word',
    question: 'Complete: "Samam Sarveṣu Bhūteṣu Tiṣṭhantaṁ Paramēśvaram ___"',
    options: ['Vināśyantam', 'Avinasha', 'Asthitam', 'Akhilam'],
    correctOptionIndex: 1,
    difficulty: 5,
  ),
  SpeedRunQuestion(
    type: 'meaning',
    question: 'What is "Advaita" philosophy as referenced in Gita teachings?',
    options: ['Dualism', 'Non-duality / Oneness', 'Plurality', 'Separation'],
    correctOptionIndex: 1,
    difficulty: 5,
  ),
  SpeedRunQuestion(
    type: 'chapter',
    question: 'Which chapter describes the "Yoga of Meditation"?',
    options: ['Chapter 6', 'Chapter 10', 'Chapter 16', 'Chapter 18'],
    correctOptionIndex: 0,
    difficulty: 5,
  ),
  SpeedRunQuestion(
    type: 'meaning',
    question: 'What is "Vasudhaiva Kutumbakam" related to in Gita philosophy?',
    options: [
      'Personal gain',
      'Universal family / Unity of all beings',
      'War tactics',
      'Wealth accumulation',
    ],
    correctOptionIndex: 1,
    difficulty: 5,
  ),
];

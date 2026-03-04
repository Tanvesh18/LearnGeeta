// Model definitions for True/False game

class TrueFalseQuestion {
  final String statement;
  final bool isTrue;
  final String difficulty; // 'easy' | 'medium' | 'hard'

  const TrueFalseQuestion({
    required this.statement,
    required this.isTrue,
    required this.difficulty,
  });
}

class GameState {
  int level;
  int score;
  int streak;
  int maxStreak;

  GameState({
    this.level = 1,
    this.score = 0,
    this.streak = 0,
    this.maxStreak = 0,
  });

  GameState copyWith({int? level, int? score, int? streak, int? maxStreak}) {
    return GameState(
      level: level ?? this.level,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      maxStreak: maxStreak ?? this.maxStreak,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'score': score,
      'streak': streak,
      'maxStreak': maxStreak,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      level: json['level'] as int? ?? 1,
      score: json['score'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      maxStreak: json['maxStreak'] as int? ?? 0,
    );
  }
}

const List<TrueFalseQuestion> questionDatabase = [
  TrueFalseQuestion(
    statement: 'Bhagavad Gita teaches detachment from the results of actions.',
    isTrue: true,
    difficulty: 'easy',
  ),
  TrueFalseQuestion(
    statement: 'According to the Gita, avoiding all work is the best path.',
    isTrue: false,
    difficulty: 'easy',
  ),
  TrueFalseQuestion(
    statement:
        'Krishna spoke the Bhagavad Gita to Arjuna on the battlefield of Kurukshetra.',
    isTrue: true,
    difficulty: 'easy',
  ),
  TrueFalseQuestion(
    statement: 'The Gita says only monks can reach the Supreme.',
    isTrue: false,
    difficulty: 'medium',
  ),
  TrueFalseQuestion(
    statement: 'Bhagavad Gita is part of the Mahabharata.',
    isTrue: true,
    difficulty: 'medium',
  ),
  TrueFalseQuestion(
    statement:
        'The Gita encourages doing one’s swadharma (own duty) sincerely.',
    isTrue: true,
    difficulty: 'medium',
  ),
  TrueFalseQuestion(
    statement:
        'According to the Gita, controlling the mind is compared to controlling the wind.',
    isTrue: true,
    difficulty: 'hard',
  ),
  TrueFalseQuestion(
    statement:
        'Bhakti (devotion) is mentioned in the Gita as a path to the Divine.',
    isTrue: true,
    difficulty: 'hard',
  ),
];

// Model definitions for Missing Word Mantra game

class MissingWord {
  final String text;
  final bool isBlank;

  const MissingWord({required this.text, required this.isBlank});
}

class MantraData {
  final String title;
  final List<MissingWord> mantra;
  final List<String> correctWords;
  final String difficulty; // 'easy' | 'medium' | 'hard'
  final GitaReference gitaReference;

  const MantraData({
    required this.title,
    required this.mantra,
    required this.correctWords,
    required this.difficulty,
    required this.gitaReference,
  });
}

class GitaReference {
  final String chapter;
  final String verse;
  final String explanation;

  const GitaReference({
    required this.chapter,
    required this.verse,
    required this.explanation,
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

const List<MantraData> mantraDatabase = [
  // EASY LEVEL - Single missing word
  MantraData(
    title: 'Karma Yoga',
    mantra: [
      MissingWord(text: 'You have the right to perform your', isBlank: false),
      MissingWord(text: 'prescribed', isBlank: true),
      MissingWord(
        text: 'duties, but you are not entitled to the fruits of your actions.',
        isBlank: false,
      ),
    ],
    correctWords: ['prescribed'],
    difficulty: 'easy',
    gitaReference: GitaReference(
      chapter: '2',
      verse: '47',
      explanation:
          'This verse teaches detachment from results while performing duties.',
    ),
  ),
  MantraData(
    title: 'Divine Nature',
    mantra: [
      MissingWord(
        text: 'I am the Self, O Gudakesha, seated in the hearts of all',
        isBlank: false,
      ),
      MissingWord(text: 'beings', isBlank: true),
      MissingWord(
        text: '; I am the beginning, the middle and the end of all beings.',
        isBlank: false,
      ),
    ],
    correctWords: ['beings'],
    difficulty: 'easy',
    gitaReference: GitaReference(
      chapter: '10',
      verse: '20',
      explanation: 'Krishna describes His presence in all living beings.',
    ),
  ),
  // MEDIUM LEVEL - Two missing words
  MantraData(
    title: 'Three Gunas',
    mantra: [
      MissingWord(text: 'Sattva, Rajas and Tamas—these three', isBlank: false),
      MissingWord(text: 'gunas', isBlank: true),
      MissingWord(text: 'born of Prakriti bind the', isBlank: false),
      MissingWord(text: 'indestructible', isBlank: true),
      MissingWord(text: 'soul to the body, O Arjuna.', isBlank: false),
    ],
    correctWords: ['gunas', 'indestructible'],
    difficulty: 'medium',
    gitaReference: GitaReference(
      chapter: '14',
      verse: '5',
      explanation: 'The three qualities of nature that bind the soul.',
    ),
  ),
  MantraData(
    title: 'Supreme Brahman',
    mantra: [
      MissingWord(text: 'I am the', isBlank: false),
      MissingWord(text: 'way', isBlank: true),
      MissingWord(
        text: 'among those who know the way, and the',
        isBlank: false,
      ),
      MissingWord(text: 'supporter', isBlank: true),
      MissingWord(text: 'among supporters, O Arjuna.', isBlank: false),
    ],
    correctWords: ['way', 'supporter'],
    difficulty: 'medium',
    gitaReference: GitaReference(
      chapter: '10',
      verse: '32',
      explanation: 'Krishna declares Himself as the essence of all paths.',
    ),
  ),
  // HARD LEVEL - Three or more missing words
  MantraData(
    title: 'Path to Liberation',
    mantra: [
      MissingWord(text: 'Perform your', isBlank: false),
      MissingWord(text: 'prescribed', isBlank: true),
      MissingWord(text: 'duty, for action is better than', isBlank: false),
      MissingWord(text: 'inaction', isBlank: true),
      MissingWord(text: '. A man cannot even maintain his', isBlank: false),
      MissingWord(text: 'physical', isBlank: true),
      MissingWord(text: 'body without work.', isBlank: false),
    ],
    correctWords: ['prescribed', 'inaction', 'physical'],
    difficulty: 'hard',
    gitaReference: GitaReference(
      chapter: '3',
      verse: '8',
      explanation: 'The importance of performing duties without attachment.',
    ),
  ),
  MantraData(
    title: 'True Renunciation',
    mantra: [
      MissingWord(text: 'Those who renounce all', isBlank: false),
      MissingWord(text: 'actions', isBlank: true),
      MissingWord(
        text: 'in Me, and are devoted to Me, meditating on Me with exclusive',
        isBlank: false,
      ),
      MissingWord(text: 'devotion', isBlank: true),
      MissingWord(
        text: ', for them I become the savior from the ocean of',
        isBlank: false,
      ),
      MissingWord(text: 'worldly', isBlank: true),
      MissingWord(text: 'existence.', isBlank: false),
    ],
    correctWords: ['actions', 'devotion', 'worldly'],
    difficulty: 'hard',
    gitaReference: GitaReference(
      chapter: '12',
      verse: '6-7',
      explanation: 'True renunciation means offering all actions to God.',
    ),
  ),
];

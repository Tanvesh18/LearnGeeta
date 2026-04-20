// Model definitions for Krishna Memory Cards game

enum CardType { shloka, meaning, symbol, teaching }

class MemoryCard {
  final String id;
  final CardType type;
  final String content;
  final String matchId; // ID to match with corresponding card
  final String difficulty; // 'easy' | 'medium' | 'hard'

  const MemoryCard({
    required this.id,
    required this.type,
    required this.content,
    required this.matchId,
    required this.difficulty,
  });
}

class CardPair {
  final MemoryCard card1;
  final MemoryCard card2;

  const CardPair({required this.card1, required this.card2});
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

const List<CardPair> memoryDatabase = [
  // EASY LEVEL - Simple matches
  CardPair(
    card1: MemoryCard(
      id: 'karma1',
      type: CardType.shloka,
      content: 'You have the right to perform your prescribed duties...',
      matchId: 'karma_meaning',
      difficulty: 'easy',
    ),
    card2: MemoryCard(
      id: 'karma_meaning',
      type: CardType.meaning,
      content: 'Focus on effort, not results',
      matchId: 'karma1',
      difficulty: 'easy',
    ),
  ),
  CardPair(
    card1: MemoryCard(
      id: 'lotus1',
      type: CardType.symbol,
      content: '🪷',
      matchId: 'lotus_meaning',
      difficulty: 'easy',
    ),
    card2: MemoryCard(
      id: 'lotus_meaning',
      type: CardType.teaching,
      content: 'Spiritual awakening from material world',
      matchId: 'lotus1',
      difficulty: 'easy',
    ),
  ),

  // MEDIUM LEVEL - More complex
  CardPair(
    card1: MemoryCard(
      id: 'gunas1',
      type: CardType.shloka,
      content: 'Sattva, Rajas and Tamas—these three gunas...',
      matchId: 'gunas_meaning',
      difficulty: 'medium',
    ),
    card2: MemoryCard(
      id: 'gunas_meaning',
      type: CardType.meaning,
      content: 'Three qualities of nature binding the soul',
      matchId: 'gunas1',
      difficulty: 'medium',
    ),
  ),
  CardPair(
    card1: MemoryCard(
      id: 'conch1',
      type: CardType.symbol,
      content: '🐚',
      matchId: 'conch_meaning',
      difficulty: 'medium',
    ),
    card2: MemoryCard(
      id: 'conch_meaning',
      type: CardType.teaching,
      content: 'Call to righteous action and dharma',
      matchId: 'conch1',
      difficulty: 'medium',
    ),
  ),

  // HARD LEVEL - Advanced concepts
  CardPair(
    card1: MemoryCard(
      id: 'vishwa1',
      type: CardType.shloka,
      content:
          'I am the Self, O Gudakesha, seated in the hearts of all beings...',
      matchId: 'vishwa_meaning',
      difficulty: 'hard',
    ),
    card2: MemoryCard(
      id: 'vishwa_meaning',
      type: CardType.meaning,
      content: 'Krishna\'s presence in all living beings',
      matchId: 'vishwa1',
      difficulty: 'hard',
    ),
  ),
  CardPair(
    card1: MemoryCard(
      id: 'wheel1',
      type: CardType.symbol,
      content: '🛞',
      matchId: 'wheel_meaning',
      difficulty: 'hard',
    ),
    card2: MemoryCard(
      id: 'wheel_meaning',
      type: CardType.teaching,
      content: 'Cycle of karma and liberation through knowledge',
      matchId: 'wheel1',
      difficulty: 'hard',
    ),
  ),
];

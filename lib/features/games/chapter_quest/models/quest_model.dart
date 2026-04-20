// Model definitions for Chapter Quest game

class ChapterOption {
  final String chapter;
  final String title;

  const ChapterOption({required this.chapter, required this.title});
}

class QuestData {
  final String question;
  final String teaching;
  final String correctChapter;
  final List<ChapterOption> options; // 4 options
  final String difficulty; // 'easy' | 'medium' | 'hard'
  final String explanation;

  const QuestData({
    required this.question,
    required this.teaching,
    required this.correctChapter,
    required this.options,
    required this.difficulty,
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

const List<QuestData> questDatabase = [
  // EASY LEVEL - Basic concepts
  QuestData(
    question: 'Which chapter teaches about Karma Yoga?',
    teaching:
        'You have the right to perform your prescribed duties, but you are not entitled to the fruits of your actions.',
    correctChapter: '2',
    options: [
      ChapterOption(chapter: '2', title: 'Sankhya Yoga'),
      ChapterOption(chapter: '6', title: 'Dhyana Yoga'),
      ChapterOption(chapter: '12', title: 'Bhakti Yoga'),
      ChapterOption(chapter: '18', title: 'Moksha Yoga'),
    ],
    difficulty: 'easy',
    explanation:
        'Chapter 2 (Sankhya Yoga) introduces the concept of Karma Yoga - performing duties without attachment to results.',
  ),
  QuestData(
    question: 'Which chapter discusses the three gunas?',
    teaching:
        'Sattva, Rajas and Tamas—these three gunas born of Prakriti bind the indestructible soul to the body.',
    correctChapter: '14',
    options: [
      ChapterOption(chapter: '13', title: 'Kshetra-Kshetrajna Vibhaga Yoga'),
      ChapterOption(chapter: '14', title: 'Gunatraya Vibhaga Yoga'),
      ChapterOption(chapter: '15', title: 'Purusottama Yoga'),
      ChapterOption(chapter: '16', title: 'Daivasura Sampad Vibhaga Yoga'),
    ],
    difficulty: 'easy',
    explanation:
        'Chapter 14 (Gunatraya Vibhaga Yoga) explains the three qualities of nature: Sattva, Rajas, and Tamas.',
  ),

  // MEDIUM LEVEL - More specific teachings
  QuestData(
    question: 'Which chapter contains the Vishwarupa Darshana?',
    teaching:
        'Arjuna sees Krishna\'s universal form containing all beings and wonders of the universe.',
    correctChapter: '11',
    options: [
      ChapterOption(chapter: '9', title: 'Raja Vidya Raja Guhya Yoga'),
      ChapterOption(chapter: '10', title: 'Vibhuti Yoga'),
      ChapterOption(chapter: '11', title: 'Vishwarupa Darshana Yoga'),
      ChapterOption(chapter: '12', title: 'Bhakti Yoga'),
    ],
    difficulty: 'medium',
    explanation:
        'Chapter 11 (Vishwarupa Darshana Yoga) describes Arjuna\'s vision of Krishna\'s cosmic form.',
  ),
  QuestData(
    question: 'Which chapter teaches about true renunciation?',
    teaching:
        'Those who renounce all actions in Me, and are devoted to Me, meditating on Me with exclusive devotion.',
    correctChapter: '12',
    options: [
      ChapterOption(chapter: '6', title: 'Dhyana Yoga'),
      ChapterOption(chapter: '12', title: 'Bhakti Yoga'),
      ChapterOption(chapter: '13', title: 'Kshetra-Kshetrajna Vibhaga Yoga'),
      ChapterOption(chapter: '18', title: 'Moksha Yoga'),
    ],
    difficulty: 'medium',
    explanation:
        'Chapter 12 (Bhakti Yoga) distinguishes between different types of spiritual practices and emphasizes devotion.',
  ),

  // HARD LEVEL - Advanced concepts
  QuestData(
    question: 'Which chapter discusses the field and the knower of the field?',
    teaching:
        'The body is called the field, and one who knows the body is called the knower of the field.',
    correctChapter: '13',
    options: [
      ChapterOption(chapter: '13', title: 'Kshetra-Kshetrajna Vibhaga Yoga'),
      ChapterOption(chapter: '15', title: 'Purusottama Yoga'),
      ChapterOption(chapter: '17', title: 'Shraddhatraya Vibhaga Yoga'),
      ChapterOption(chapter: '18', title: 'Moksha Yoga'),
    ],
    difficulty: 'hard',
    explanation:
        'Chapter 13 (Kshetra-Kshetrajna Vibhaga Yoga) explains the distinction between matter (field) and spirit (knower of field).',
  ),
  QuestData(
    question: 'Which chapter describes the divine and demonic qualities?',
    teaching:
        'Fearlessness, purity of heart, steadfastness in knowledge and yoga, almsgiving, control of the senses, sacrifice, study of scriptures, austerity and straightforwardness.',
    correctChapter: '16',
    options: [
      ChapterOption(chapter: '14', title: 'Gunatraya Vibhaga Yoga'),
      ChapterOption(chapter: '15', title: 'Purusottama Yoga'),
      ChapterOption(chapter: '16', title: 'Daivasura Sampad Vibhaga Yoga'),
      ChapterOption(chapter: '17', title: 'Shraddhatraya Vibhaga Yoga'),
    ],
    difficulty: 'hard',
    explanation:
        'Chapter 16 (Daivasura Sampad Vibhaga Yoga) contrasts divine qualities (daivi sampad) with demonic qualities (asuri sampad).',
  ),
];

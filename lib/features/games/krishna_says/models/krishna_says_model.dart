// Model definitions for Krishna Says (Wisdom Challenge) game

class WisdomQuestion {
  final String question;
  final List<String> options; // 4 answer options
  final int correctOptionIndex;
  final String chapter;
  final String verse;
  final String shloka;
  final String explanation;
  final int difficulty; // 1-5 progressive difficulty

  const WisdomQuestion({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.chapter,
    required this.verse,
    required this.shloka,
    required this.explanation,
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

// Database of 20 wisdom questions (levels 1-5, 4 per level)
const List<WisdomQuestion> wisdomDatabase = [
  // Level 1
  WisdomQuestion(
    question: 'You feel anxious before an exam. What does the Gita suggest?',
    options: [
      'Skip the exam to avoid anxiety',
      'Focus on your duty without worrying about results',
      'Pray that you will pass',
      'Copy from others',
    ],
    correctOptionIndex: 1,
    chapter: '2',
    verse: '47',
    shloka: 'Karmanyevadhikaraste Ma Phaleshu Kadachana',
    explanation:
        'You have a right to perform your duty, but you are not entitled to the fruits. This teaches detachment from outcomes.',
    difficulty: 1,
  ),
  WisdomQuestion(
    question:
        'Your friend criticizes your work. How should you respond per Gita?',
    options: [
      'Get angry and fight back',
      'Accept criticism with an open mind if it helps you grow',
      'Ignore them completely',
      'Spread rumors about them',
    ],
    correctOptionIndex: 1,
    chapter: '12',
    verse: '13',
    shloka: 'Adveshtā Sarvabhūtānāṁ Maitrāḥ Karuṇa Ēva Ca',
    explanation:
        'Be non-hostile to all beings, compassionate. Accept feedback gracefully.',
    difficulty: 1,
  ),
  WisdomQuestion(
    question: 'You made a mistake at work. What should you do?',
    options: [
      'Blame someone else',
      'Own your mistake and work to improve',
      'Hide it and hope no one notices',
      'Quit your job',
    ],
    correctOptionIndex: 1,
    chapter: '18',
    verse: '47',
    shloka: 'Śreyān Sva-Dharmo Viguṇaḥ Para-Dharamāt Sv-Anuṣṭhitāt',
    explanation:
        'It is better to perform one\'s own duty even imperfectly than another\'s perfectly. Take responsibility.',
    difficulty: 1,
  ),
  WisdomQuestion(
    question: 'How should you handle failure according to Gita?',
    options: [
      'Give up completely',
      'View failure as a learning opportunity and persist',
      'Blame external circumstances',
      'Never try again',
    ],
    correctOptionIndex: 1,
    chapter: '2',
    verse: '14',
    shloka: 'Mātrā-Sparśās Tu Kaunteya Śītoṣṇa-Sukha-Duḥkha-Dāḥ',
    explanation:
        'Success and failure are temporary. Keep learning and moving forward.',
    difficulty: 1,
  ),
  // Level 2
  WisdomQuestion(
    question:
        'When facing a difficult relationship, what\'s the Gita\'s counsel?',
    options: [
      'Cut off all contact immediately',
      'Understand their perspective with detachment and compassion',
      'Engage in conflict to prove your point',
      'Seek revenge',
    ],
    correctOptionIndex: 1,
    chapter: '6',
    verse: '6',
    shloka: 'Bandhu Ātmātmanastu ke',
    explanation:
        'Approach relationships with wisdom, understanding, and compassion.',
    difficulty: 2,
  ),
  WisdomQuestion(
    question: 'You have excess wealth. What should you do?',
    options: [
      'Hoard it all for yourself',
      'Share it generously while fulfilling your duties',
      'Waste it carelessly',
      'Give it all away immediately',
    ],
    correctOptionIndex: 1,
    chapter: '3',
    verse: '12',
    shloka: 'Yajña-Śiṣṭāśinaḥ Santo Mucyante Sarva-Kilbiṣaiḥ',
    explanation:
        'Share with others through generosity (yajna). Wealth is meant to be used wisely.',
    difficulty: 2,
  ),
  WisdomQuestion(
    question: 'How should you act when someone wrongs you?',
    options: [
      'Seek immediate revenge',
      'Act with dharma, not anger; respond with wisdom',
      'Harm them back even worse',
      'Whine and complain to others',
    ],
    correctOptionIndex: 1,
    chapter: '2',
    verse: '33',
    shloka: 'Klaibyaṁ Mā Sma Gamaḥ Pārtha',
    explanation:
        'Don\'t be weak. Act with courage and dharma, not out of anger.',
    difficulty: 2,
  ),
  WisdomQuestion(
    question: 'When should you compromise your principles?',
    options: [
      'Whenever it benefits you financially',
      'Never—always uphold your dharma',
      'When everyone is doing it',
      'When no one is watching',
    ],
    correctOptionIndex: 1,
    chapter: '18',
    verse: '47',
    shloka: 'Śreyān Sva-Dharmo Viguṇaḥ Para-Dharamāt Sv-Anuṣṭhitāt',
    explanation:
        'Your duty (dharma) is supreme. Never compromise it, even in hardship.',
    difficulty: 2,
  ),
  // Level 3
  WisdomQuestion(
    question: 'What is the right attitude when pursuing success?',
    options: [
      'Obsess over winning at any cost',
      'Perform your best while remaining detached from the outcome',
      'Only work if you\'re guaranteed to win',
      'Success is unimportant, so don\'t try',
    ],
    correctOptionIndex: 1,
    chapter: '2',
    verse: '48',
    shloka: 'Yoga-Sthaḥ Kuru Karmāṇi Saṅgaṁ Tyaktvā Dhanañ-Jaya',
    explanation:
        'Perform your action with equanimity, free from attachment. This is yoga.',
    difficulty: 3,
  ),
  WisdomQuestion(
    question: 'How should you deal with conflicting desires?',
    options: [
      'Follow every impulse without question',
      'Discriminate between desires and follow those aligned with dharma',
      'Suppress all desires completely',
      'Let others decide what you should want',
    ],
    correctOptionIndex: 1,
    chapter: '3',
    verse: '37',
    shloka: 'Kāma Eṣa Krodha Eṣa Rajo-Guṇa-Samudbhavaḥ',
    explanation:
        'Desire and anger are natural, but discern which desires serve your higher purpose.',
    difficulty: 3,
  ),
  WisdomQuestion(
    question: 'What is true strength?',
    options: [
      'Overpowering others through force',
      'Mastering yourself and your mind',
      'Accumulating power and wealth',
      'Never showing vulnerability',
    ],
    correctOptionIndex: 1,
    chapter: '6',
    verse: '5',
    shloka: 'Uddhared Ātmānā Ātmānaṁ Nāt-Mā-Nam Avasādayet',
    explanation:
        'Elevate yourself through self-mastery. This is real strength.',
    difficulty: 3,
  ),
  WisdomQuestion(
    question: 'When facing uncertainty, what should guide your actions?',
    options: [
      'Fear and self-doubt',
      'Your dharma (duty) and inner wisdom',
      'What others expect of you',
      'Random chance',
    ],
    correctOptionIndex: 1,
    chapter: '18',
    verse: '30',
    shloka: 'Sattvikā Buddhir Eka Pārtha Sthā Rajas-Tamasat',
    explanation:
        'Follow your inner wisdom and duty guided by sattva (purity and clarity).',
    difficulty: 3,
  ),
  // Level 4
  WisdomQuestion(
    question: 'What is the essence of balanced living?',
    options: [
      'Pursue only pleasure',
      'Perform your duties while maintaining inner balance',
      'Renounce the world entirely',
      'Chase power and recognition',
    ],
    correctOptionIndex: 1,
    chapter: '6',
    verse: '7',
    shloka: 'Jitātmanaḥ Praśāntasya Paramātmā Samāhitaḥ',
    explanation:
        'Through self-mastery and peace, the divine is realized in action.',
    difficulty: 4,
  ),
  WisdomQuestion(
    question: 'How should you view suffering in life?',
    options: [
      'Avoid it at all costs',
      'View it as a catalyst for growth and wisdom',
      'Blame others for it',
      'Become bitter and resentful',
    ],
    correctOptionIndex: 1,
    chapter: '2',
    verse: '33-34',
    shloka: 'Atha Ced Tvam Imaṁ Dharmaṁ Na Kariṣyasi',
    explanation:
        'Suffering teaches us. Growth comes through facing challenges with courage.',
    difficulty: 4,
  ),
  WisdomQuestion(
    question: 'What does the Gita teach about knowledge?',
    options: [
      'Knowledge is power to dominate others',
      'True knowledge leads to self-realization and peace',
      'Knowledge is unnecessary',
      'Only practical skills matter',
    ],
    correctOptionIndex: 1,
    chapter: '13',
    verse: '8',
    shloka: 'Jñānam Jñeyaṁ Parijñātā Tri-Vidhā Karma-Codanā',
    explanation:
        'Knowledge that leads to unity with all beings is the highest knowledge.',
    difficulty: 4,
  ),
  WisdomQuestion(
    question: 'When facing a major life decision, what is the right approach?',
    options: [
      'Follow your impulses',
      'Analyze the situation, consider dharma, then act with conviction',
      'Ask everyone for advice and get confused',
      'Postpone decisions indefinitely',
    ],
    correctOptionIndex: 1,
    chapter: '17',
    verse: '7',
    shloka: 'Tri-Vidhā Bhavati Śraddhā Dehinā',
    explanation:
        'Use your intellect, align with dharma, trust your deeper wisdom.',
    difficulty: 4,
  ),
  // Level 5
  WisdomQuestion(
    question: 'What is the ultimate goal of living according to the Gita?',
    options: [
      'Accumulate wealth and fame',
      'Realize your divine nature while fulfilling your duties',
      'Escape from life indefinitely',
      'Satisfy all desires',
    ],
    correctOptionIndex: 1,
    chapter: '18',
    verse: '54-55',
    shloka: 'Brahma-Bhūtaḥ Prasannātmā',
    explanation:
        'The highest goal is to realize your oneness with the divine while living your dharma.',
    difficulty: 5,
  ),
  WisdomQuestion(
    question: 'How should a wise person view the cycles of life?',
    options: [
      'Life is meaningless and chaotic',
      'Life cycles reflect cosmic order; accept change with equanimity',
      'Resist all change desperately',
      'Only personal success matters',
    ],
    correctOptionIndex: 1,
    chapter: '2',
    verse: '14',
    shloka: 'Mātrā-Sparśās Tu Kaunteya',
    explanation:
        'Accept joy and sorrow as natural cycles. Stay balanced through change.',
    difficulty: 5,
  ),
  WisdomQuestion(
    question: 'What is liberation (moksha) as presented in the Gita?',
    options: [
      'Escaping all responsibilities',
      'Freedom from ego and attachment while living fully',
      'Accumulating infinite pleasure',
      'Gaining power over others',
    ],
    correctOptionIndex: 1,
    chapter: '9',
    verse: '28',
    shloka: 'Atha Cet Tvam Imaṁ Nityaṁ Satagüṇam Acakṣate',
    explanation:
        'True freedom is liberation from ego, attachment, and fear while fulfilling your dharma.',
    difficulty: 5,
  ),
  WisdomQuestion(
    question: 'What unites all beings according to the Gita?',
    options: [
      'Nothing; all beings are separate',
      'All beings share the same divine spark within',
      'Only powerful people are significant',
      'Only your family matters',
    ],
    correctOptionIndex: 1,
    chapter: '13',
    verse: '27',
    shloka: 'Samam Sarveṣu Bhūteṣu',
    explanation:
        'The divine dwells equally in all beings. See unity in diversity and act with compassion.',
    difficulty: 5,
  ),
];

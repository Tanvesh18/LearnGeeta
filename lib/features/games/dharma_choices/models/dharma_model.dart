// Model definitions for Dharma Choices game

class Choice {
  final String text;
  final bool isCorrect;

  const Choice({required this.text, required this.isCorrect});
}

class GitaTeaching {
  final String chapter;
  final String verse;
  final String teaching;
  final String explanation;

  const GitaTeaching({
    required this.chapter,
    required this.verse,
    required this.teaching,
    required this.explanation,
  });
}

class LifeSituation {
  final String title; // emoji + title
  final String scenario;
  final List<Choice> choices; // exactly 3 choices
  final GitaTeaching gitaTeaching;
  final String difficulty; // 'beginner' | 'intermediate' | 'advanced'

  const LifeSituation({
    required this.title,
    required this.scenario,
    required this.choices,
    required this.gitaTeaching,
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

const List<LifeSituation> situationDatabase = [
  // BEGINNER LEVEL
  LifeSituation(
    title: '😞 Stress About Results',
    scenario:
        'You studied hard for an exam but didn\'t get the result you wanted. You feel disappointed and demotivated. What do you do?',
    choices: [
      Choice(text: 'Stop trying since results are uncertain', isCorrect: false),
      Choice(text: 'Focus only on the result next time', isCorrect: false),
      Choice(text: 'Focus on effort and detach from results', isCorrect: true),
    ],
    gitaTeaching: GitaTeaching(
      chapter: '2',
      verse: '47',
      teaching:
          'You have the right to perform your duty, but not to the fruits of your actions.',
      explanation:
          'The Gita teaches that we should focus on doing our best effort without being attached to outcomes. This reduces stress and anxiety.',
    ),
    difficulty: 'beginner',
  ),
  LifeSituation(
    title: '😠 Feeling Angry',
    scenario:
        'A friend said something hurtful to you. You feel angry and want to retaliate. How should you respond?',
    choices: [
      Choice(text: 'Respond with anger and insult them back', isCorrect: false),
      Choice(text: 'Avoid the situation completely', isCorrect: false),
      Choice(
        text: 'Understand their perspective and respond with calm wisdom',
        isCorrect: true,
      ),
    ],
    gitaTeaching: GitaTeaching(
      chapter: '2',
      verse: '65',
      teaching:
          'The wise person masters their senses and remains peaceful even when challenged.',
      explanation:
          'Anger leads to poor decisions. The Gita advises controlling emotions and responding with wisdom and compassion.',
    ),
    difficulty: 'beginner',
  ),
  LifeSituation(
    title: '😴 Lack of Motivation',
    scenario:
        'You need to work on an important project, but you lack motivation. Everything feels pointless. What should you do?',
    choices: [
      Choice(text: 'Postpone the work indefinitely', isCorrect: false),
      Choice(text: 'Do it just for money or praise', isCorrect: false),
      Choice(
        text: 'Do it as your duty without expecting rewards',
        isCorrect: true,
      ),
    ],
    gitaTeaching: GitaTeaching(
      chapter: '3',
      verse: '35',
      teaching:
          'It is better to follow one\'s own duty imperfectly than to follow another\'s duty perfectly.',
      explanation:
          'Find meaning in doing your duty sincerely, not in external rewards. This brings true motivation.',
    ),
    difficulty: 'beginner',
  ),
  // INTERMEDIATE LEVEL
  LifeSituation(
    title: '🤝 Conflict with a Friend',
    scenario:
        'Your best friend made a mistake that hurt you. They don\'t realize what they did wrong. How should you approach this?',
    choices: [
      Choice(text: 'End the friendship immediately', isCorrect: false),
      Choice(text: 'Hold a grudge silently', isCorrect: false),
      Choice(
        text: 'Communicate with wisdom and compassion to help them grow',
        isCorrect: true,
      ),
    ],
    gitaTeaching: GitaTeaching(
      chapter: '3',
      verse: '26',
      teaching:
          'Guide others with wisdom, not with attachment to their actions.',
      explanation:
          'True friendship means helping others understand their mistakes with love and wisdom, not judgment.',
    ),
    difficulty: 'intermediate',
  ),
  LifeSituation(
    title: '🎯 Pressure to Succeed',
    scenario:
        'Everyone expects you to become very successful. You feel immense pressure. How do you handle this?',
    choices: [
      Choice(
        text: 'Abandon your goals because of the pressure',
        isCorrect: false,
      ),
      Choice(
        text: 'Pursue success obsessively to meet expectations',
        isCorrect: false,
      ),
      Choice(
        text:
            'Follow your own path with dedication, ignoring others\' expectations',
        isCorrect: true,
      ),
    ],
    gitaTeaching: GitaTeaching(
      chapter: '3',
      verse: '35',
      teaching: 'It is better to follow one\'s own duty than another\'s.',
      explanation:
          'Success means following your authentic path and doing your duty sincerely, not chasing others\' definitions of success.',
    ),
    difficulty: 'intermediate',
  ),
  LifeSituation(
    title: '💔 Jealousy of Others',
    scenario:
        'Your colleague got a promotion you wanted. You feel jealous and resentful. What should you do?',
    choices: [
      Choice(text: 'Complain and bad-mouth them', isCorrect: false),
      Choice(text: 'Give up and stop working hard', isCorrect: false),
      Choice(
        text: 'Congratulate them and work on improving yourself',
        isCorrect: true,
      ),
    ],
    gitaTeaching: GitaTeaching(
      chapter: '13',
      verse: '8',
      teaching:
          'Absence of envy and equanimity in both gain and loss are virtues of the wise.',
      explanation:
          'Jealousy weakens you. Instead, celebrate others\' success and focus on your own growth.',
    ),
    difficulty: 'intermediate',
  ),
  // ADVANCED LEVEL
  LifeSituation(
    title: '⚖️ Duty vs Desire',
    scenario:
        'You have a responsibility to your family, but your personal desire is completely different. You\'re torn between the two. What\'s the right choice?',
    choices: [
      Choice(text: 'Ignore your duty and follow your desire', isCorrect: false),
      Choice(
        text: 'Sacrifice your desire completely and feel resentful',
        isCorrect: false,
      ),
      Choice(
        text: 'Fulfill your duty with full commitment and find meaning in it',
        isCorrect: true,
      ),
    ],
    gitaTeaching: GitaTeaching(
      chapter: '2',
      verse: '31',
      teaching:
          'One\'s own duty, though imperfect, is better than another\'s duty perfectly executed.',
      explanation:
          'Dharma (duty) is supreme. Finding purpose in fulfilling your responsibilities brings true fulfillment.',
    ),
    difficulty: 'advanced',
  ),
  LifeSituation(
    title: '🌀 Loss and Detachment',
    scenario:
        'You lost something very important to you—a job, a relationship, or a dream. You\'re devastated. How should you accept this?',
    choices: [
      Choice(text: 'Fall into despair and give up on life', isCorrect: false),
      Choice(
        text: 'Pretend it doesn\'t matter and suppress your feelings',
        isCorrect: false,
      ),
      Choice(
        text: 'Accept it as part of life\'s cycle and learn from it',
        isCorrect: true,
      ),
    ],
    gitaTeaching: GitaTeaching(
      chapter: '2',
      verse: '14',
      teaching:
          'The pairs of opposites like pleasure and pain are not permanent. The wise are unmoved by them.',
      explanation:
          'Everything in life changes. True wisdom is accepting change without losing your inner peace.',
    ),
    difficulty: 'advanced',
  ),
  LifeSituation(
    title: '🧠 Ego and Humility',
    scenario:
        'You achieved something great and people are praising you. You feel proud and superior. How should you respond?',
    choices: [
      Choice(
        text: 'Believe you are better than everyone else',
        isCorrect: false,
      ),
      Choice(text: 'Take all credit and boast about it', isCorrect: false),
      Choice(
        text: 'Remain humble, grateful, and recognize your limitations',
        isCorrect: true,
      ),
    ],
    gitaTeaching: GitaTeaching(
      chapter: '13',
      verse: '8',
      teaching:
          'Humility, absence of pride, and modesty are among the highest virtues.',
      explanation:
          'True greatness comes with humility. No achievement is permanent; staying grounded protects your wisdom.',
    ),
    difficulty: 'advanced',
  ),
];

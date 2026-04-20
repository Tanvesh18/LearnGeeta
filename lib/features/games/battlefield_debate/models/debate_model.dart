// Model definitions for Battlefield Debate game

class DebateOption {
  final String text;
  final bool isCorrect;
  final String explanation;

  const DebateOption({
    required this.text,
    required this.isCorrect,
    required this.explanation,
  });
}

class DebateScenario {
  final String arjunaQuestion;
  final List<DebateOption> krishnaResponses; // 3 options, 1 correct
  final String difficulty; // 'easy' | 'medium' | 'hard'
  final String chapter;
  final String verse;
  final String context;

  const DebateScenario({
    required this.arjunaQuestion,
    required this.krishnaResponses,
    required this.difficulty,
    required this.chapter,
    required this.verse,
    required this.context,
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

const List<DebateScenario> debateDatabase = [
  // EASY LEVEL
  DebateScenario(
    arjunaQuestion:
        'O Krishna, how can I fight against my own relatives and teachers in this battle?',
    krishnaResponses: [
      DebateOption(
        text: 'You should abandon the battle and become a monk instead.',
        isCorrect: false,
        explanation: 'This would be renouncing duty, which Krishna rejects.',
      ),
      DebateOption(
        text: 'Perform your duty as a warrior without attachment to results.',
        isCorrect: true,
        explanation:
            'Krishna teaches Karma Yoga - doing duty without attachment.',
      ),
      DebateOption(
        text: 'The battle is just a dream, so ignore it completely.',
        isCorrect: false,
        explanation:
            'Krishna emphasizes the reality of duty in the material world.',
      ),
    ],
    difficulty: 'easy',
    chapter: '2',
    verse: '31-38',
    context: 'Arjuna\'s dilemma about fighting his relatives.',
  ),

  DebateScenario(
    arjunaQuestion: 'What is the difference between knowledge and action?',
    krishnaResponses: [
      DebateOption(
        text:
            'Knowledge is for scholars, action is for warriors - they are completely separate.',
        isCorrect: false,
        explanation:
            'Krishna teaches that true knowledge leads to right action.',
      ),
      DebateOption(
        text: 'Knowledge and action are one - wisdom leads to selfless action.',
        isCorrect: true,
        explanation:
            'Jnana (knowledge) and Karma (action) are united in spiritual practice.',
      ),
      DebateOption(
        text: 'Action is inferior to knowledge - only meditation matters.',
        isCorrect: false,
        explanation: 'Krishna values both knowledge and right action equally.',
      ),
    ],
    difficulty: 'easy',
    chapter: '3',
    verse: '1-8',
    context: 'Arjuna\'s confusion about the paths of knowledge and action.',
  ),

  // MEDIUM LEVEL
  DebateScenario(
    arjunaQuestion:
        'How can I recognize a person who has achieved self-realization?',
    krishnaResponses: [
      DebateOption(
        text: 'They will perform miracles and levitate in meditation.',
        isCorrect: false,
        explanation: 'External miracles are not the sign of true realization.',
      ),
      DebateOption(
        text:
            'They remain undisturbed in all situations, seeing the Self in all beings.',
        isCorrect: true,
        explanation:
            'A realized soul sees equality in all and remains equanimous.',
      ),
      DebateOption(
        text: 'They will become wealthy and powerful in the world.',
        isCorrect: false,
        explanation:
            'Material success is not the measure of spiritual realization.',
      ),
    ],
    difficulty: 'medium',
    chapter: '2',
    verse: '54-72',
    context: 'Arjuna asks about the characteristics of a self-realized person.',
  ),

  DebateScenario(
    arjunaQuestion:
        'What is the nature of the three gunas and how do they affect us?',
    krishnaResponses: [
      DebateOption(
        text: 'The gunas are permanent qualities that cannot be transcended.',
        isCorrect: false,
        explanation: 'The gunas can be transcended through spiritual practice.',
      ),
      DebateOption(
        text:
            'The gunas bind the soul, but one established in Me transcends them.',
        isCorrect: true,
        explanation: 'By devotion to Krishna, one rises above the three gunas.',
      ),
      DebateOption(
        text: 'Only Sattva guna leads to liberation, Rajas and Tamas are evil.',
        isCorrect: false,
        explanation: 'All gunas are part of nature, but Sattva is the highest.',
      ),
    ],
    difficulty: 'medium',
    chapter: '14',
    verse: '19-27',
    context:
        'Arjuna inquires about transcending the three qualities of nature.',
  ),

  // HARD LEVEL
  DebateScenario(
    arjunaQuestion:
        'You are the Supreme Brahman, the ultimate reality. How can I know You completely?',
    krishnaResponses: [
      DebateOption(
        text: 'Through rituals and ceremonies performed perfectly.',
        isCorrect: false,
        explanation:
            'Rituals are means, not the end. Direct knowledge is needed.',
      ),
      DebateOption(
        text: 'Through pure devotion and surrender to Me alone.',
        isCorrect: true,
        explanation:
            'Krishna reveals Himself to the devoted heart through grace.',
      ),
      DebateOption(
        text: 'By studying all scriptures and becoming a great scholar.',
        isCorrect: false,
        explanation:
            'Scholarship alone cannot reveal God - devotion is essential.',
      ),
    ],
    difficulty: 'hard',
    chapter: '18',
    verse: '64-66',
    context: 'Arjuna seeks the highest knowledge of Krishna\'s divine nature.',
  ),

  DebateScenario(
    arjunaQuestion:
        'What is the ultimate path to liberation from the cycle of birth and death?',
    krishnaResponses: [
      DebateOption(
        text: 'Accumulating good karma through righteous actions only.',
        isCorrect: false,
        explanation: 'Good karma leads to better births, but not liberation.',
      ),
      DebateOption(
        text: 'Complete surrender to Me with loving devotion.',
        isCorrect: true,
        explanation:
            'Bhakti Yoga, complete surrender to Krishna, is the ultimate path.',
      ),
      DebateOption(
        text: 'Renouncing all action and becoming a hermit in the forest.',
        isCorrect: false,
        explanation: 'True renunciation is internal, not external withdrawal.',
      ),
    ],
    difficulty: 'hard',
    chapter: '18',
    verse: '65-66',
    context: 'Arjuna asks for the secret of liberation.',
  ),
];

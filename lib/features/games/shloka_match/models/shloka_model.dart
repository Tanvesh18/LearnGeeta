class Shloka {
  final String sanskrit;
  final String englishMeaning;
  final String hindiMeaning;
  final String chapter;
  final String verseNumber;
  final List<String> meaningOptions; // Multiple choice options
  final String difficulty; // 'easy', 'medium', 'hard'

  const Shloka({
    required this.sanskrit,
    required this.englishMeaning,
    required this.hindiMeaning,
    required this.chapter,
    required this.verseNumber,
    required this.meaningOptions,
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

const List<Shloka> shlokaDatabase = [
  // EASY LEVEL
  Shloka(
    sanskrit: 'कर्मण्येवाधिकारस्ते',
    englishMeaning:
        'You have a right to perform your prescribed duty, but you are not entitled to the fruits of action.',
    hindiMeaning:
        'आपको अपने कर्म करने का अधिकार है, लेकिन आप उसके फलों के लिए हकदार नहीं हैं।',
    chapter: '2',
    verseNumber: '47',
    meaningOptions: [
      'You have a right to perform your prescribed duty, but you are not entitled to the fruits of action.',
      'Always focus on the results of your actions',
      'Never perform your duties without expecting rewards',
      'The fruits of action are more important than action itself',
    ],
    difficulty: 'easy',
  ),
  Shloka(
    sanskrit: 'योगस्थः कुरु कर्माणि',
    englishMeaning:
        'Perform your duty with a steady mind, performing actions while abandoning attachment.',
    hindiMeaning:
        'स्थिर मन से अपना कर्तव्य करें, आसक्ति को त्यागते हुए कार्य करें।',
    chapter: '2',
    verseNumber: '48',
    meaningOptions: [
      'Perform your duty with a steady mind, performing actions while abandoning attachment.',
      'Never perform any actions in life',
      'Act only when you expect great rewards',
      'Perform actions with anxiety and worry',
    ],
    difficulty: 'easy',
  ),
  Shloka(
    sanskrit: 'न हि ज्ञानेन सदृशम्',
    englishMeaning: 'There is no purifier in this world like knowledge.',
    hindiMeaning: 'इस दुनिया में ज्ञान जैसा कोई शुद्धिकारक नहीं है।',
    chapter: '4',
    verseNumber: '38',
    meaningOptions: [
      'There is no purifier in this world like knowledge.',
      'Money is the greatest purifier',
      'Physical exercise purifies the body',
      'Ignorance is the best teacher',
    ],
    difficulty: 'easy',
  ),
  // MEDIUM LEVEL
  Shloka(
    sanskrit: 'उद्धरेदात्मनाऽऽत्मानं',
    englishMeaning: 'Lift yourself by your own mind; do not degrade yourself.',
    hindiMeaning: 'अपने मन से खुद को ऊपर उठाएं; अपना अपमान न करें।',
    chapter: '6',
    verseNumber: '5',
    meaningOptions: [
      'Lift yourself by your own mind; do not degrade yourself.',
      'Always depend on others for your progress',
      'Self-effort is futile without external help',
      'Degradation is a sign of wisdom',
    ],
    difficulty: 'medium',
  ),
  Shloka(
    sanskrit: 'श्रद्धावान् लभते ज्ञानम्',
    englishMeaning:
        'The faithful one attains knowledge and reaches supreme peace.',
    hindiMeaning:
        'आस्थावान व्यक्ति ज्ञान प्राप्त करता है और सर्वोच्च शांति तक पहुंचता है।',
    chapter: '4',
    verseNumber: '39',
    meaningOptions: [
      'The faithful one attains knowledge and reaches supreme peace.',
      'Only the doubtful can achieve true wisdom',
      'Knowledge comes without any faith or belief',
      'Peace is impossible to attain through faith',
    ],
    difficulty: 'medium',
  ),
  Shloka(
    sanskrit: 'समः शत्रौ च मित्रे च',
    englishMeaning:
        'One who sees the Self in all beings and all beings in the Self achieves eternal peace.',
    hindiMeaning:
        'जो सभी प्राणियों में आत्मा देखता है और सभी प्राणियों को आत्मा में देखता है, शाश्वत शांति पाता है।',
    chapter: '6',
    verseNumber: '29',
    meaningOptions: [
      'One who sees the Self in all beings and all beings in the Self achieves eternal peace.',
      'Only enemies can lead to eternal peace',
      'Universal vision causes permanent conflict',
      'Friends and enemies are fundamentally different beings',
    ],
    difficulty: 'medium',
  ),
  // HARD LEVEL
  Shloka(
    sanskrit: 'भगवद्गीता परम्परा',
    englishMeaning:
        'The eternal tradition of the Bhagavad Gita flows from antiquity.',
    hindiMeaning: 'भगवद्गीता की सनातन परंपरा प्राचीन काल से प्रवाहित है।',
    chapter: '4',
    verseNumber: '1',
    meaningOptions: [
      'The eternal tradition of the Bhagavad Gita flows from antiquity.',
      'The Bhagavad Gita is a modern creation',
      'Ancient traditions are no longer relevant',
      'Spiritual teachings have no continuity',
    ],
    difficulty: 'hard',
  ),
  Shloka(
    sanskrit: 'अब्रह्मभुवनाल्लोकाः',
    englishMeaning:
        'All the worlds up to Brahma\'s abode are subject to repeated birth and death.',
    hindiMeaning:
        'ब्रह्मा के लोक तक सभी लोक बार-बार जन्म और मृत्यु के अधीन हैं।',
    chapter: '8',
    verseNumber: '16',
    meaningOptions: [
      'All the worlds up to Brahma\'s abode are subject to repeated birth and death.',
      'Only the material world experiences change',
      'Higher realms are immune to transformation',
      'Birth and death do not apply to any world',
    ],
    difficulty: 'hard',
  ),
  Shloka(
    sanskrit: 'मया तत्तं इदं सर्वम्',
    englishMeaning:
        'By me all this universe is pervaded; all things are in me.',
    hindiMeaning:
        'इस पूरे ब्रह्मांड को मैं व्याप्त किए हुए हूँ; सभी चीजें मुझ में हैं।',
    chapter: '10',
    verseNumber: '8',
    meaningOptions: [
      'By me all this universe is pervaded; all things are in me.',
      'The universe exists independent of any consciousness',
      'Creation is separate from the creator',
      'Nothing is connected to anything else',
    ],
    difficulty: 'hard',
  ),
];

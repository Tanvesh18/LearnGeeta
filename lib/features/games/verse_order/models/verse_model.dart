class Verse {
  final String sanskrit;
  final String englishMeaning;
  final String hindiMeaning;
  final String chapter;
  final String verseNumber;
  final List<String> lines;
  final String difficulty; // 'easy', 'medium', 'hard'

  const Verse({
    required this.sanskrit,
    required this.englishMeaning,
    required this.hindiMeaning,
    required this.chapter,
    required this.verseNumber,
    required this.lines,
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

const List<Verse> verseDatabase = [
  Verse(
    sanskrit: 'कर्मण्येवाधिकारस्ते',
    englishMeaning:
        'You have a right to perform your prescribed duty, but you are not entitled to the fruits of action.',
    hindiMeaning:
        'आपको अपने कर्म करने का अधिकार है, लेकिन आप उसके फलों के लिए हकदार नहीं हैं।',
    chapter: '2',
    verseNumber: '47',
    lines: [
      'कर्मण्येवाधिकारस्ते',
      'मा फलेषु कदाचन',
      'मा कर्मफलहेतुर्भूर्',
      'मा ते संगोऽस्त्वकर्मणि',
    ],
    difficulty: 'easy',
  ),
  Verse(
    sanskrit: 'योगस्थः कुरु कर्माणि',
    englishMeaning:
        'Perform your duty with a steady mind, performing actions while abandoning attachment.',
    hindiMeaning:
        'स्थिर मन से अपना कर्तव्य करें, आसक्ति को त्यागते हुए कार्य करें।',
    chapter: '2',
    verseNumber: '48',
    lines: [
      'योगस्थः कुरु कर्माणि',
      'सङ्गं त्यक्त्वा धनञ्जय',
      'सिद्ध्यसिद्ध्योः समो भूत्वा',
      'समत्वं योग उच्यते',
    ],
    difficulty: 'easy',
  ),
  Verse(
    sanskrit: 'न हि ज्ञानेन सदृशम्',
    englishMeaning: 'There is no purifier in this world like knowledge.',
    hindiMeaning: 'इस दुनिया में ज्ञान जैसा कोई शुद्धिकारक नहीं है।',
    chapter: '4',
    verseNumber: '38',
    lines: [
      'न हि ज्ञानेन सदृशं',
      'पवित्रमिह विद्यते',
      'तत्स्वयं योगसंसिद्धः',
      'कालेनात्मनि विन्दति',
    ],
    difficulty: 'medium',
  ),
  Verse(
    sanskrit: 'उद्धरेदात्मनाऽऽत्मानं',
    englishMeaning: 'Lift yourself by your own mind; do not degrade yourself.',
    hindiMeaning: 'अपने मन से खुद को ऊपर उठाएं; अपना अपमान न करें।',
    chapter: '6',
    verseNumber: '5',
    lines: [
      'उद्धरेदात्मनाऽऽत्मानं',
      'नात्मानमवसादयेत्',
      'आत्मैव ह्यात्मनो बन्धुर्',
      'आत्मैव रिपुरात्मनः',
    ],
    difficulty: 'medium',
  ),
  Verse(
    sanskrit: 'श्रद्धावान् लभते ज्ञानम्',
    englishMeaning:
        'The faithful one attains knowledge and reaches supreme peace.',
    hindiMeaning:
        'आस्थावान व्यक्ति ज्ञान प्राप्त करता है और सर्वोच्च शांति तक पहुंचता है।',
    chapter: '4',
    verseNumber: '39',
    lines: [
      'श्रद्धावान्ँल्लभते ज्ञानं',
      'तत्परः संयतेन्द्रियः',
      'ज्ञानं लब्ध्वा परां शान्तिं',
      'अचिरेणाधिगच्छति',
    ],
    difficulty: 'medium',
  ),
  Verse(
    sanskrit: 'समः शत्रौ च मित्रे च',
    englishMeaning:
        'One who sees the Self in all beings and all beings in the Self achieves eternal peace.',
    hindiMeaning:
        'जो सभी प्राणियों में आत्मा देखता है और सभी प्राणियों को आत्मा में देखता है, शाश्वत शांति पाता है।',
    chapter: '6',
    verseNumber: '29',
    lines: [
      'सर्वभूतस्थमात्मानं',
      'सर्वभूतानि चात्मनि',
      'ईक्षते योगयुक्तात्मा',
      'सर्वत्र समदर्शनः',
    ],
    difficulty: 'hard',
  ),
  Verse(
    sanskrit: 'भगवद्गीता परम्परा',
    englishMeaning:
        'The eternal tradition of the Bhagavad Gita flows from antiquity.',
    hindiMeaning: 'भगवद्गीता की सनातन परंपरा प्राचीन काल से प्रवाहित है।',
    chapter: '4',
    verseNumber: '1',
    lines: [
      'भगवान् उवाच',
      'इमं विवस्वते योगं',
      'प्रोक्तवानहमव्ययम्',
      'विवस्वान्मनवे प्राह',
    ],
    difficulty: 'hard',
  ),
  Verse(
    sanskrit: 'अब्रह्मभुवनाल्लोकाः',
    englishMeaning:
        'All the worlds up to Brahma\'s abode are subject to repeated birth and death.',
    hindiMeaning:
        'ब्रह्मा के लोक तक सभी लोक बार-बार जन्म और मृत्यु के अधीन हैं।',
    chapter: '8',
    verseNumber: '16',
    lines: [
      'अब्रह्मभुवनाल्लोकाः',
      'पुनरावर्तिनोऽर्जुन',
      'मामुपेत्य तु कौन्तेय',
      'पुनर्जन्म न विद्यते',
    ],
    difficulty: 'hard',
  ),
];

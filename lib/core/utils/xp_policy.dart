class XpPolicy {
  const XpPolicy._();

  static const int xpPerLevel = 100;

  static int levelForXp(int xp) {
    if (xp < 0) return 1;
    return (xp ~/ xpPerLevel) + 1;
  }

  static String titleForLevel(int level) {
    if (level >= 100) return 'Gita Guardian';
    if (level >= 60) return 'Karma Master';
    if (level >= 40) return 'Sage';
    if (level >= 25) return 'Yogi';
    if (level >= 15) return 'Disciple';
    if (level >= 7) return 'Seeker';
    return 'Beginner';
  }

  static int trueFalse({
    required String difficulty,
    required int currentStreak,
  }) {
    var xp = 10;
    if (difficulty == 'hard') xp += 5;
    if (currentStreak >= 3) xp += 5;
    return xp;
  }

  static int shlokaMatch({
    required String difficulty,
    required int currentStreak,
  }) {
    var xp = 12;
    if (difficulty == 'hard') xp += 4;
    if (currentStreak >= 3) xp += 4;
    if (currentStreak >= 5) xp += 6;
    return xp;
  }

  static int verseOrder({
    required String difficulty,
    required int currentStreak,
  }) {
    var xp = 15;
    if (difficulty == 'hard') xp += 5;
    if (currentStreak >= 3) xp += 5;
    if (currentStreak >= 5) xp += 10;
    return xp;
  }

  static int dharmaChoices({required int currentStreak}) {
    var xp = 18;
    if (currentStreak >= 3) xp += 10;
    return xp;
  }

  static int krishnaSays({required int currentStreak}) {
    var xp = 10;
    if (currentStreak >= 3) xp += 5;
    return xp;
  }

  static int shlokaSpeedRun({required int comboMultiplier}) {
    return 8 * comboMultiplier.clamp(1, 3);
  }

  static int karmaPathChoice({required int karmaValue}) {
    if (karmaValue >= 3) return 12;
    if (karmaValue == 2) return 10;
    if (karmaValue == 1) return 8;
    if (karmaValue == 0) return 5;
    return 0;
  }

  static int karmaPathEnding({required int totalKarma}) {
    if (totalKarma >= 8) return 25;
    if (totalKarma >= 3) return 18;
    if (totalKarma >= 0) return 10;
    return 0;
  }
}

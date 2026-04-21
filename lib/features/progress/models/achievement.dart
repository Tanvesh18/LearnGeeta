class Achievement {
  const Achievement({
    required this.title,
    required this.description,
    required this.unlocked,
    required this.emoji,
  });

  final String title;
  final String description;
  final bool unlocked;
  final String emoji;
}

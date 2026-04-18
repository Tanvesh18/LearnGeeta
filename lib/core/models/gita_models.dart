class GitaChapter {
  final int chapterNumber;
  final String name;
  final String transliteration;
  final String meaningEnglish;
  final int versesCount;
  final String? description;

  GitaChapter({
    required this.chapterNumber,
    required this.name,
    required this.transliteration,
    required this.meaningEnglish,
    required this.versesCount,
    this.description,
  });

  factory GitaChapter.fromJson(Map<String, dynamic> json) {
    // Handle both API formats
    final meaning = json['meaning'] is Map ? json['meaning']['en'] : null;
    final summary = json['summary'] ?? json['description'] ?? '';

    return GitaChapter(
      chapterNumber: json['chapter_number'] ?? json['chapterNumber'] ?? 0,
      name: json['name'] ?? json['title'] ?? '',
      transliteration:
          json['transliteration'] ?? json['transliteratedTitle'] ?? '',
      meaningEnglish:
          meaning ?? json['meaningEnglish'] ?? json['englishName'] ?? '',
      versesCount: json['verses_count'] ?? json['versesCount'] ?? 0,
      description: summary.toString().isNotEmpty ? summary : null,
    );
  }
}

class GitaVerse {
  final int chapterNumber;
  final int verseNumber;
  final String text;
  final String transliteration;
  final String meaningEnglish;
  final String? commentary;

  GitaVerse({
    required this.chapterNumber,
    required this.verseNumber,
    required this.text,
    required this.transliteration,
    required this.meaningEnglish,
    this.commentary,
  });

  factory GitaVerse.fromJson(Map<String, dynamic> json) {
    // Handle both API formats
    final meaning = json['meaning'] is Map ? json['meaning']['en'] : null;
    final commentary = json['commentary'] is Map
        ? json['commentary']['en'] ?? json['commentary']['hindi']
        : json['commentary'];

    return GitaVerse(
      chapterNumber: json['chapter'] ?? json['chapterNumber'] ?? 0,
      verseNumber: json['verse'] ?? json['verseNumber'] ?? 0,
      text: json['text'] ?? json['slok'] ?? '',
      transliteration: json['transliteration'] ?? json['translatedText'] ?? '',
      meaningEnglish: meaning ?? json['meaningEnglish'] ?? '',
      commentary: commentary,
    );
  }
}

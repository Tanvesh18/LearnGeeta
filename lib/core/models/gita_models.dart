class GitaChapter {
  final int chapterNumber;
  final String name;
  final String nameTranslation;
  final String nameTransliterated;
  final String nameMeaning;
  final String transliteration;
  final String meaningEnglish;
  final String? chapterSummary;
  final String? chapterSummaryHindi;
  final int versesCount;
  final String? description;

  GitaChapter({
    required this.chapterNumber,
    required this.name,
    required this.nameTranslation,
    required this.nameTransliterated,
    required this.nameMeaning,
    required this.transliteration,
    required this.meaningEnglish,
    this.chapterSummary,
    this.chapterSummaryHindi,
    required this.versesCount,
    this.description,
  });

  factory GitaChapter.fromJson(Map<String, dynamic> json) {
    // Handle both API formats
    final meaning = json['meaning'] is Map ? json['meaning']['en'] : null;
    final summary =
        json['chapter_summary'] ?? json['summary'] ?? json['description'] ?? '';

    return GitaChapter(
      chapterNumber: json['chapter_number'] ?? json['chapterNumber'] ?? 0,
      name: json['name'] ?? json['title'] ?? '',
      nameTranslation: json['name_translation'] ?? '',
      nameTransliterated: json['name_transliterated'] ?? '',
      nameMeaning: json['name_meaning'] ?? '',
      transliteration:
          json['transliteration'] ?? json['transliteratedTitle'] ?? '',
      meaningEnglish:
          meaning ?? json['meaningEnglish'] ?? json['englishName'] ?? '',
      chapterSummary: json['chapter_summary'],
      chapterSummaryHindi: json['chapter_summary_hindi'],
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
  final String? wordMeanings;
  final String? commentary;
  final List<GitaTranslation>? translations;

  GitaVerse({
    required this.chapterNumber,
    required this.verseNumber,
    required this.text,
    required this.transliteration,
    required this.meaningEnglish,
    this.wordMeanings,
    this.commentary,
    this.translations,
  });

  factory GitaVerse.fromJson(Map<String, dynamic> json) {
    // Handle both API formats
    final meaning = json['meaning'] is Map ? json['meaning']['en'] : null;
    final commentary = json['commentary'] is Map
        ? json['commentary']['en'] ?? json['commentary']['hindi']
        : json['commentary'];

    // Parse translations
    List<GitaTranslation>? translations;
    if (json['translations'] != null && json['translations'] is List) {
      translations = (json['translations'] as List)
          .map((t) => GitaTranslation.fromJson(t as Map<String, dynamic>))
          .toList();
    }

    return GitaVerse(
      chapterNumber:
          json['chapter_number'] ??
          json['chapter'] ??
          json['chapterNumber'] ??
          0,
      verseNumber:
          json['verse_number'] ?? json['verse'] ?? json['verseNumber'] ?? 0,
      text: json['text'] ?? json['slok'] ?? '',
      transliteration: json['transliteration'] ?? json['translatedText'] ?? '',
      meaningEnglish: meaning ?? json['meaningEnglish'] ?? '',
      wordMeanings: json['word_meanings'],
      commentary: commentary,
      translations: translations,
    );
  }
}

class GitaTranslation {
  final String author;
  final String language;
  final String text;

  GitaTranslation({
    required this.author,
    required this.language,
    required this.text,
  });

  factory GitaTranslation.fromJson(Map<String, dynamic> json) {
    return GitaTranslation(
      author: json['author'] ?? json['authorName'] ?? 'Unknown',
      language: json['language'] ?? json['lang'] ?? 'english',
      text: json['text'] ?? json['description'] ?? '',
    );
  }
}

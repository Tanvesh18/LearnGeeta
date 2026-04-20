import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/gita_models.dart';

class GitaRepository {
  static const Duration timeout = Duration(seconds: 15);

  // Cache for loaded data
  List<GitaChapter>? _chapters;
  Map<int, List<GitaVerse>>? _versesCache;

  /// Fetch all Bhagavad Gita chapters
  Future<List<GitaChapter>> fetchAllChapters() async {
    if (_chapters != null) return _chapters!;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/bhagavad_gita.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final chaptersData = jsonData['chapters'] as List<dynamic>;

      _chapters = chaptersData.map((chapterJson) {
        return GitaChapter.fromJson(chapterJson as Map<String, dynamic>);
      }).toList();

      return _chapters!;
    } catch (e) {
      // Fallback to hardcoded data if JSON loading fails
      return _getHardcodedChapters();
    }
  }

  /// Fetch a specific chapter by number
  Future<GitaChapter> fetchChapter(int chapterNumber) async {
    final chapters = await fetchAllChapters();
    return chapters.firstWhere(
      (chapter) => chapter.chapterNumber == chapterNumber,
      orElse: () => throw Exception('Chapter $chapterNumber not found'),
    );
  }

  /// Fetch all verses for a specific chapter
  Future<List<GitaVerse>> fetchChapterVerses(int chapterNumber) async {
    if (_versesCache != null && _versesCache!.containsKey(chapterNumber)) {
      return _versesCache![chapterNumber]!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/bhagavad_gita.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final chaptersData = jsonData['chapters'] as List<dynamic>;

      final chapterData =
          chaptersData.firstWhere(
                (chapter) => chapter['chapter_number'] == chapterNumber,
                orElse: () =>
                    throw Exception('Chapter $chapterNumber not found'),
              )
              as Map<String, dynamic>;

      final versesData = chapterData['verses'] as List<dynamic>;
      final verses = versesData.map((verseJson) {
        return GitaVerse.fromJson(verseJson as Map<String, dynamic>);
      }).toList();

      // Cache the verses
      _versesCache ??= {};
      _versesCache![chapterNumber] = verses;

      return verses;
    } catch (e) {
      // Fallback to sample data if JSON loading fails
      return _generateSampleVerses(chapterNumber);
    }
  }

  /// Fetch a specific verse
  Future<GitaVerse> fetchVerse(int chapterNumber, int verseNumber) async {
    final verses = await fetchChapterVerses(chapterNumber);
    return verses.firstWhere(
      (verse) => verse.verseNumber == verseNumber,
      orElse: () => throw Exception(
        'Verse $verseNumber not found in chapter $chapterNumber',
      ),
    );
  }

  // Fallback hardcoded chapters (keeping for emergency fallback)
  List<GitaChapter> _getHardcodedChapters() {
    final hardcodedChapters = [
      {
        'chapter_number': 1,
        'name': 'Arjuna Visada Yoga',
        'transliteration': 'अर्जुन विषाद योग',
        'meaning_en':
            'The Yoga of Arjuna\'s Despair - Arjuna becomes overwhelmed by doubt and despair on the battlefield.',
        'verses_count': 47,
      },
      {
        'chapter_number': 2,
        'name': 'Sankhya Yoga',
        'transliteration': 'सांख्य योग',
        'meaning_en':
            'The Yoga of Knowledge - Krishna begins his teachings to Arjuna about wisdom and knowledge.',
        'verses_count': 72,
      },
      {
        'chapter_number': 3,
        'name': 'Karma Yoga',
        'transliteration': 'कर्म योग',
        'meaning_en':
            'The Yoga of Action - Krishna teaches about performing duties without attachment to results.',
        'verses_count': 43,
      },
      {
        'chapter_number': 4,
        'name': 'Jnana Yoga',
        'transliteration': 'ज्ञान योग',
        'meaning_en':
            'The Yoga of Knowledge - About spiritual knowledge and wisdom.',
        'verses_count': 42,
      },
      {
        'chapter_number': 5,
        'name': 'Sannyasa Yoga',
        'transliteration': 'संन्यास योग',
        'meaning_en':
            'The Yoga of Renunciation - About renouncing actions and desires.',
        'verses_count': 29,
      },
      {
        'chapter_number': 6,
        'name': 'Atma Samyama Yoga',
        'transliteration': 'आत्म संयम योग',
        'meaning_en':
            'The Yoga of Self-Control - About meditation and discipline.',
        'verses_count': 47,
      },
      {
        'chapter_number': 7,
        'name': 'Jnana Vijnana Yoga',
        'transliteration': 'ज्ञान विज्ञान योग',
        'meaning_en':
            'The Yoga of Knowledge and Wisdom - About knowing the Supreme Reality.',
        'verses_count': 30,
      },
      {
        'chapter_number': 8,
        'name': 'Aksara Brahma Yoga',
        'transliteration': 'अक्षर ब्रह्म योग',
        'meaning_en':
            'The Yoga of the Imperishable Brahman - About the nature of ultimate reality.',
        'verses_count': 28,
      },
      {
        'chapter_number': 9,
        'name': 'Raja Vidya Raja Guhya Yoga',
        'transliteration': 'राज विद्या राज गुह्य योग',
        'meaning_en':
            'The Yoga of Royal Knowledge and Royal Secret - About the ultimate knowledge.',
        'verses_count': 34,
      },
      {
        'chapter_number': 10,
        'name': 'Vibhuti Yoga',
        'transliteration': 'विभूति योग',
        'meaning_en':
            'The Yoga of Cosmic Manifestations - Krishna reveals his divine manifestations.',
        'verses_count': 42,
      },
      {
        'chapter_number': 11,
        'name': 'Visvarupa Darsana Yoga',
        'transliteration': 'विश्वरूप दर्शन योग',
        'meaning_en':
            'The Yoga of the Vision of the Cosmic Form - Arjuna sees Krishna\'s universal form.',
        'verses_count': 55,
      },
      {
        'chapter_number': 12,
        'name': 'Bhakti Yoga',
        'transliteration': 'भक्ति योग',
        'meaning_en':
            'The Yoga of Devotion - On the path of devotion to the Divine.',
        'verses_count': 20,
      },
      {
        'chapter_number': 13,
        'name': 'Kshetra Kshetrajna Vibhaga Yoga',
        'transliteration': 'क्षेत्र क्षेत्रज्ञ विभाग योग',
        'meaning_en':
            'The Yoga of the Field and the Knower of the Field - About matter and consciousness.',
        'verses_count': 35,
      },
      {
        'chapter_number': 14,
        'name': 'Gunatraya Vibhaga Yoga',
        'transliteration': 'गुणत्रय विभाग योग',
        'meaning_en':
            'The Yoga of the Division of the Three Gunas - About the three qualities of nature.',
        'verses_count': 27,
      },
      {
        'chapter_number': 15,
        'name': 'Purushottama Yoga',
        'transliteration': 'पुरुषोत्तम योग',
        'meaning_en':
            'The Yoga of the Supreme Reality - About the supreme person and ultimate truth.',
        'verses_count': 20,
      },
      {
        'chapter_number': 16,
        'name': 'Deva Asura Sampad Vibhaga Yoga',
        'transliteration': 'देव असुर संपद् विभाग योग',
        'meaning_en':
            'The Yoga of the Division of Divine and Demonic Qualities - About divine and demonic traits.',
        'verses_count': 24,
      },
      {
        'chapter_number': 17,
        'name': 'Shraddhatraya Vibhaga Yoga',
        'transliteration': 'श्रद्धात्रय विभाग योग',
        'meaning_en':
            'The Yoga of the Division of Faith - About the three types of faith and worship.',
        'verses_count': 28,
      },
      {
        'chapter_number': 18,
        'name': 'Moksha Sannyasa Yoga',
        'transliteration': 'मोक्ष संन्यास योग',
        'meaning_en':
            'The Yoga of Liberation and Renunciation - Conclusion: the path to liberation.',
        'verses_count': 78,
      },
    ];

    return hardcodedChapters.map((ch) {
      return GitaChapter(
        chapterNumber: ch['chapter_number'] as int,
        name: ch['name'] as String,
        nameTranslation: ch['name'] as String,
        nameTransliterated: ch['transliteration'] as String,
        nameMeaning: ch['meaning_en'] as String,
        transliteration: ch['transliteration'] as String,
        meaningEnglish: ch['meaning_en'] as String,
        versesCount: ch['verses_count'] as int,
        description: ch['meaning_en'] as String,
      );
    }).toList();
  }

  /// Generate sample verses for a chapter (fallback)
  List<GitaVerse> _generateSampleVerses(int chapterNumber) {
    final verses = <GitaVerse>[];
    final chapter = _getHardcodedChapters().firstWhere(
      (ch) => ch.chapterNumber == chapterNumber,
    );
    final verseCount = chapter.versesCount;

    for (int i = 1; i <= verseCount && i <= 10; i++) {
      verses.add(
        GitaVerse(
          chapterNumber: chapterNumber,
          verseNumber: i,
          text: 'धर्मक्षेत्रे कुरुक्षेत्रे समवेता युयुत्सवः',
          transliteration: 'dharma-kṣetre kuru-kṣetre, samaveta yuyutsavah',
          meaningEnglish:
              'This is a verse from Chapter $chapterNumber, Verse $i. The complete text and meaning would be displayed here with full Sanskrit translation.',
          commentary:
              'This verse teaches about the nature of dharma (righteousness) and the importance of fulfilling one\'s duty without attachment to results.',
        ),
      );
    }

    return verses;
  }
}

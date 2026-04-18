import '../models/gita_models.dart';

class GitaRepository {
  static const Duration timeout = Duration(seconds: 15);

  // Hardcoded Gita chapters data as fallback
  static final List<Map<String, dynamic>> _hardcodedChapters = [
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

  /// Fetch all Bhagavad Gita chapters
  Future<List<GitaChapter>> fetchAllChapters() async {
    try {
      // Return hardcoded data
      return _hardcodedChapters.map((ch) {
        return GitaChapter(
          chapterNumber: ch['chapter_number'],
          name: ch['name'],
          transliteration: ch['transliteration'],
          meaningEnglish: ch['meaning_en'],
          versesCount: ch['verses_count'],
          description: ch['meaning_en'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Error loading chapters: $e');
    }
  }

  /// Fetch a specific chapter by number
  Future<GitaChapter> fetchChapter(int chapterNumber) async {
    try {
      final chapterData = _hardcodedChapters.firstWhere(
        (ch) => ch['chapter_number'] == chapterNumber,
      );

      return GitaChapter(
        chapterNumber: chapterData['chapter_number'],
        name: chapterData['name'],
        transliteration: chapterData['transliteration'],
        meaningEnglish: chapterData['meaning_en'],
        versesCount: chapterData['verses_count'],
        description: chapterData['meaning_en'],
      );
    } catch (e) {
      throw Exception('Chapter not found: $e');
    }
  }

  /// Fetch all verses for a specific chapter - with sample data
  Future<List<GitaVerse>> fetchChapterVerses(int chapterNumber) async {
    try {
      // Return sample verses for demonstration
      // In production, this would call an API
      return _generateSampleVerses(chapterNumber);
    } catch (e) {
      throw Exception('Error loading verses: $e');
    }
  }

  /// Fetch a specific verse
  Future<GitaVerse> fetchVerse(int chapterNumber, int verseNumber) async {
    try {
      final verses = await fetchChapterVerses(chapterNumber);
      return verses.firstWhere((v) => v.verseNumber == verseNumber);
    } catch (e) {
      throw Exception('Verse not found: $e');
    }
  }

  /// Generate sample verses for a chapter
  List<GitaVerse> _generateSampleVerses(int chapterNumber) {
    final verses = <GitaVerse>[];
    final chapter = _hardcodedChapters.firstWhere(
      (ch) => ch['chapter_number'] == chapterNumber,
    );
    final verseCount = chapter['verses_count'] as int;

    for (int i = 1; i <= verseCount && i <= 10; i++) {
      // Show first 10 verses as samples
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

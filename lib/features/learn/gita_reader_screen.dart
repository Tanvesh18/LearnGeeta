import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/constants/colors.dart';
import '../../core/widgets/app_gradient_scaffold.dart';
import 'gita_reader_controller.dart';

class GitaReaderScreen extends StatefulWidget {
  const GitaReaderScreen({super.key});

  @override
  State<GitaReaderScreen> createState() => _GitaReaderScreenState();
}

class _GitaReaderScreenState extends State<GitaReaderScreen> {
  late final GitaReaderController _controller;
  late final FlutterTts _tts;
  bool _isSpeaking = false;
  int? _speakingVerseNumber;

  @override
  void initState() {
    super.initState();
    _controller = GitaReaderController();
    _controller.addListener(_onControllerChanged);
    _controller.loadChapters();

    _tts = FlutterTts();
    _tts.setLanguage('en-IN');
    _tts.setSpeechRate(0.55);
    _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() { _isSpeaking = false; _speakingVerseNumber = null; });
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() { _isSpeaking = false; _speakingVerseNumber = null; });
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  Future<void> _speakVerse(dynamic verse) async {
    final verseNum = verse.verseNumber as int;
    if (_isSpeaking && _speakingVerseNumber == verseNum) {
      await _tts.stop();
      setState(() { _isSpeaking = false; _speakingVerseNumber = null; });
      return;
    }
    await _tts.stop();
    final text = '${verse.transliteration}. ${verse.meaningEnglish}';
    setState(() { _isSpeaking = true; _speakingVerseNumber = verseNum; });
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      appBar: AppBar(
        title: const Text('Bhagavad Gita'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.saffron,
        foregroundColor: Colors.white,
        leading: _controller.selectedChapter != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _tts.stop();
                  _controller.clearSelection();
                },
              )
            : null,
      ),
      body: SafeArea(
        child: _controller.selectedChapter == null
            ? _buildChaptersList()
            : _buildChapterDetail(),
      ),
    );
  }

  Widget _buildChaptersList() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.saffron));
    }

    if (_controller.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${_controller.errorMessage}', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _controller.loadChapters,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.saffron, foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resume reading banner
          if (_controller.lastChapter != null && _controller.lastVerse != null)
            _buildResumeBanner(),
          const Text(
            'Select a Chapter',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _controller.chapters.length,
            itemBuilder: (context, index) {
              final chapter = _controller.chapters[index];
              final isLastRead = _controller.lastChapter == chapter.chapterNumber;
              return _buildChapterCard(chapter, isLastRead);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResumeBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.saffron.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.saffron.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bookmark, color: AppColors.saffron),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Continue Reading',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Chapter ${_controller.lastChapter}, Verse ${_controller.lastVerse}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _controller.selectChapter(_controller.lastChapter!),
            child: const Text('Resume', style: TextStyle(color: AppColors.saffron)),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterCard(dynamic chapter, bool isLastRead) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isLastRead
            ? const BorderSide(color: AppColors.saffron, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _controller.selectChapter(chapter.chapterNumber),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.saffron.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${chapter.chapterNumber}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.saffron,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                chapter.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (isLastRead)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.saffron,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Reading',
                                  style: TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chapter.nameTranslation.isNotEmpty
                              ? chapter.nameTranslation
                              : chapter.transliteration,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${chapter.versesCount} verses',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: AppColors.saffron, size: 20),
                ],
              ),
              if (chapter.nameMeaning.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  chapter.nameMeaning,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChapterDetail() {
    final chapter = _controller.selectedChapter!;
    final verses = _controller.currentChapterVerses;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Chapter header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapter.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  chapter.nameTranslation,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  '${verses.length} verses',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Chapter Summary
          if (chapter.chapterSummary != null && chapter.chapterSummary!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: AppColors.saffron.withValues(alpha: 0.08),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chapter Summary',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        chapter.chapterSummary!,
                        style: const TextStyle(fontSize: 12, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Verses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.saffron,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildVersesList(verses),
        ],
      ),
    );
  }

  Widget _buildVersesList(List<dynamic> verses) {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.saffron));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: verses.length,
      itemBuilder: (context, index) {
        final verse = verses[index];
        final isSelected = _controller.selectedVerse?.verseNumber == verse.verseNumber;
        final isLastReadVerse = _controller.lastChapter == _controller.selectedChapter?.chapterNumber
            && _controller.lastVerse == verse.verseNumber;

        return Card(
          elevation: isSelected ? 8 : 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? const BorderSide(color: AppColors.saffron, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _controller.selectVerse(verse),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.saffron.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Verse ${verse.verseNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.saffron,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (isLastReadVerse)
                        const Icon(Icons.bookmark, size: 18, color: AppColors.saffron),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    verse.text,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    verse.transliteration,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 16),
                    // TTS button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _speakVerse(verse),
                        icon: Icon(
                          _isSpeaking && _speakingVerseNumber == verse.verseNumber
                              ? Icons.stop_circle
                              : Icons.volume_up,
                          color: AppColors.saffron,
                        ),
                        label: Text(
                          _isSpeaking && _speakingVerseNumber == verse.verseNumber
                              ? 'Stop'
                              : 'Listen',
                          style: const TextStyle(color: AppColors.saffron),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.saffron),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Meaning
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.saffron.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Meaning',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(verse.meaningEnglish, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    // Word Meanings
                    if (verse.wordMeanings != null && verse.wordMeanings!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Word Meanings',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(verse.wordMeanings!, style: const TextStyle(fontSize: 12, height: 1.5)),
                          ],
                        ),
                      ),
                    ],
                    // Translations
                    if (verse.translations != null && verse.translations!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gradientStart,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Translations',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...verse.translations!.map((trans) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      trans.author,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(trans.text, style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

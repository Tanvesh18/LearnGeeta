import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/gita_models.dart';
import '../../core/repositories/gita_repository.dart';

class GitaReaderController extends ChangeNotifier {
  final GitaRepository _repository = GitaRepository();

  List<GitaChapter> _chapters = [];
  List<GitaVerse> _currentChapterVerses = [];
  GitaChapter? _selectedChapter;
  GitaVerse? _selectedVerse;
  bool _isLoading = false;
  String? _errorMessage;
  int? _lastChapter;
  int? _lastVerse;

  List<GitaChapter> get chapters => _chapters;
  List<GitaVerse> get currentChapterVerses => _currentChapterVerses;
  GitaChapter? get selectedChapter => _selectedChapter;
  GitaVerse? get selectedVerse => _selectedVerse;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get lastChapter => _lastChapter;
  int? get lastVerse => _lastVerse;

  Future<void> loadChapters() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _chapters = await _repository.fetchAllChapters();
      _errorMessage = null;
      await _loadBookmark();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    _lastChapter = prefs.getInt('gitaLastChapter');
    _lastVerse = prefs.getInt('gitaLastVerse');
    notifyListeners();
  }

  Future<void> _saveBookmark(int chapter, int verse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gitaLastChapter', chapter);
    await prefs.setInt('gitaLastVerse', verse);
    _lastChapter = chapter;
    _lastVerse = verse;
  }

  Future<void> selectChapter(int chapterNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedChapter = await _repository.fetchChapter(chapterNumber);
      _currentChapterVerses = await _repository.fetchChapterVerses(chapterNumber);
      _selectedVerse = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectVerse(GitaVerse verse) async {
    _selectedVerse = verse;
    if (_selectedChapter != null) {
      await _saveBookmark(_selectedChapter!.chapterNumber, verse.verseNumber);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedChapter = null;
    _selectedVerse = null;
    _currentChapterVerses = [];
    notifyListeners();
  }
}

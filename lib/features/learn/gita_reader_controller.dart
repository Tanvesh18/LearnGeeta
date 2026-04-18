import 'package:flutter/material.dart';

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

  // Getters
  List<GitaChapter> get chapters => _chapters;
  List<GitaVerse> get currentChapterVerses => _currentChapterVerses;
  GitaChapter? get selectedChapter => _selectedChapter;
  GitaVerse? get selectedVerse => _selectedVerse;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all chapters
  Future<void> loadChapters() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _chapters = await _repository.fetchAllChapters();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select a chapter and load its verses
  Future<void> selectChapter(int chapterNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedChapter = await _repository.fetchChapter(chapterNumber);
      _currentChapterVerses = await _repository.fetchChapterVerses(
        chapterNumber,
      );
      _selectedVerse = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select a specific verse
  void selectVerse(GitaVerse verse) {
    _selectedVerse = verse;
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    _selectedChapter = null;
    _selectedVerse = null;
    _currentChapterVerses = [];
    notifyListeners();
  }
}

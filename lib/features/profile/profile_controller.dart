import 'package:flutter/foundation.dart';

import '../../auth/auth_repository.dart';
import '../../core/models/user_profile.dart';
import '../../core/models/user_progress.dart';
import '../../core/utils/app_logger.dart';
import '../progress/progress_repository.dart';
import 'profile_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({
    required IProfileRepository profileRepository,
    required IProgressRepository progressRepository,
    required IAuthRepository authRepository,
  }) : _profileRepository = profileRepository,
       _progressRepository = progressRepository,
       _authRepository = authRepository;

  final IProfileRepository _profileRepository;
  final IProgressRepository _progressRepository;
  final IAuthRepository _authRepository;

  bool _isLoading = true;
  bool _isSaving = false;
  UserProfile? _profile;
  UserProgress? _progress;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  UserProfile? get profile => _profile;
  UserProgress? get progress => _progress;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _profileRepository.fetchProfile();
      _progress = await _progressRepository.fetchProgress();
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load profile', error, stackTrace);
      _errorMessage = 'Unable to load profile details.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> save({
    required String fullName,
    required String language,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _profileRepository.updateProfile(
        fullName: fullName,
        language: language,
      );
      return true;
    } catch (error, stackTrace) {
      AppLogger.error('Failed to save profile', error, stackTrace);
      _errorMessage = 'Unable to save profile changes.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}

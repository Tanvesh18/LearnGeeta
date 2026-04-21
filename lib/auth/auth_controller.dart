import 'package:flutter/foundation.dart';

import '../core/models/user_profile.dart';
import '../core/utils/app_logger.dart';
import '../core/utils/password_utils.dart';
import '../features/profile/profile_repository.dart';
import '../features/progress/progress_repository.dart';
import 'auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required IAuthRepository authRepository,
    required IProfileRepository profileRepository,
    required IProgressRepository progressRepository,
  }) : _authRepository = authRepository,
       _profileRepository = profileRepository,
       _progressRepository = progressRepository;

  final IAuthRepository _authRepository;
  final IProfileRepository _profileRepository;
  final IProgressRepository _progressRepository;

  bool _isLoading = false;
  String? _errorMessage;
  bool _signUpNeedsConfirmation = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get signUpNeedsConfirmation => _signUpNeedsConfirmation;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    return _run(
      action: () async {
        await _authRepository.signIn(email: email, password: password);
        return true;
      },
      fallbackMessage: 'Invalid email or password',
    );
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final validation = PasswordUtils.validate(password, email: email);
    if (!validation.isValid) {
      _errorMessage = validation.errorMessage;
      notifyListeners();
      return false;
    }

    return _run(
      action: () async {
        final response = await _authRepository.signUp(
          email: email,
          password: password,
          data: {'full_name': name},
        );
        final user = response.user;
        if (user == null) {
          throw Exception('User is null after signup');
        }

        _signUpNeedsConfirmation = response.session == null;

        try {
          final profile = UserProfile(
            id: user.id,
            email: email,
            fullName: name,
            language: 'English',
          );
          await _profileRepository.upsertProfile(profile);
          await _progressRepository.createInitialProgressForUser(user.id);
        } catch (_) {
          // Profile/progress creation may fail when no session exists yet
          // (email confirmation required). fetchProfile/fetchProgress have fallbacks.
        }
        return true;
      },
      fallbackMessage: 'Unable to create account',
    );
  }

  Future<bool> sendPasswordReset({required String email}) async {
    return _run(
      action: () async {
        await _authRepository.resetPassword(email: email);
        return true;
      },
      fallbackMessage: 'Failed to send reset email. Please try again.',
    );
  }

  Future<bool> updatePassword({
    required String password,
    required String confirmPassword,
  }) async {
    if (password.isEmpty || confirmPassword.isEmpty) {
      _errorMessage = 'Please fill in all fields';
      notifyListeners();
      return false;
    }

    if (password != confirmPassword) {
      _errorMessage = 'Passwords do not match';
      notifyListeners();
      return false;
    }

    final email = _authRepository.getCurrentUser()?.email;
    final validation = PasswordUtils.validate(
      password,
      email: email,
      requireStrong: true,
    );
    if (!validation.isValid) {
      _errorMessage = validation.errorMessage;
      notifyListeners();
      return false;
    }

    return _run(
      action: () async {
        await _authRepository.updatePassword(password);
        return true;
      },
      fallbackMessage: 'Failed to update password. Please try again.',
    );
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  Future<bool> _run<T>({
    required Future<T> Function() action,
    required String fallbackMessage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } catch (error, stackTrace) {
      AppLogger.error('Auth action failed', error, stackTrace);
      _errorMessage = fallbackMessage;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';

class AuthSessionController extends ChangeNotifier {
  AuthSessionController({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  final IAuthRepository _authRepository;

  StreamSubscription<AuthState>? _subscription;
  Session? _session;
  bool _isLoading = true;
  bool _isPasswordRecovery = false;

  Session? get session => _session;
  bool get isLoading => _isLoading;
  bool get isPasswordRecovery => _isPasswordRecovery;

  void initialize() {
    _session = _authRepository.getCurrentSession();
    _subscription ??= _authRepository.authStateChanges().listen((authState) {
      _session = authState.session;
      _isPasswordRecovery = authState.event == AuthChangeEvent.passwordRecovery;
      _isLoading = false;
      notifyListeners();
    });
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

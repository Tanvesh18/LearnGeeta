import 'package:flutter/material.dart';

import '../core/app_dependencies.dart';
import '../core/widgets/app_gradient_scaffold.dart';
import '../navigation/bottom_nav.dart';
import 'auth_session_controller.dart';
import 'login_screen.dart';
import 'reset_password_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthSessionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthSessionController(
      authRepository: AppDependencies.authRepository,
    )..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const AppGradientScaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_controller.isPasswordRecovery) {
          return const ResetPasswordScreen();
        }

        if (_controller.session == null) {
          return const LoginScreen();
        }

        return const BottomNav();
      },
    );
  }
}

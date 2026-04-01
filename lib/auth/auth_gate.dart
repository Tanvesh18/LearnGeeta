import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../navigation/bottom_nav.dart';
import 'login_screen.dart';
import 'reset_password_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        final event = snapshot.data?.event;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Handle password recovery event
        if (event == AuthChangeEvent.passwordRecovery) {
          return const ResetPasswordScreen();
        }

        if (session == null) {
          return const LoginScreen();
        }

        return const BottomNav();
      },
    );
  }
}

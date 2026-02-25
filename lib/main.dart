import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wjwkjabnipuzwyxtwegj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indqd2tqYWJuaXB1end5eHR3ZWdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIwMzgwNjEsImV4cCI6MjA4NzYxNDA2MX0.lCOY3i2H25mO5rOKf3BTgkeA4lKxNATVHOgbgFxotuw',
  );

  runApp(const LearnGeetaApp());
}

class LearnGeetaApp extends StatelessWidget {
  const LearnGeetaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnGeeta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}
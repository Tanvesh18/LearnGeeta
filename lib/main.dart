import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'navigation/bottom_nav.dart';

void main() {
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
      home: const BottomNav(),
    );
  }
}
import 'package:flutter/material.dart';

import '../features/home/home_screen.dart';
import '../features/learn/learn_screen.dart';
import '../features/play/play_screen.dart';
import '../features/progress/progress_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key, List<Widget>? screens})
    : screens =
          screens ??
          const [HomeScreen(), LearnScreen(), PlayScreen(), ProgressScreen()];

  final List<Widget> screens;

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: widget.screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Learn'),
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset),
            label: 'Play',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}

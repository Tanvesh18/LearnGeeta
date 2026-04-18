import 'package:flutter/material.dart';

class GameDefinition {
  const GameDefinition({
    required this.id,
    required this.title,
    required this.icon,
    required this.isUnlocked,
    required this.builder,
  });

  final String id;
  final String title;
  final IconData icon;
  final bool Function(int level) isUnlocked;
  final WidgetBuilder builder;
}

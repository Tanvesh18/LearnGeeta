import 'dart:ui';

import 'package:flutter/material.dart';

// Model definitions for Wheel of Gunas game

enum GunaType { sattva, rajas, tamas }

class GunaOption {
  final GunaType type;
  final String name;
  final String description;
  final Color color;

  const GunaOption({
    required this.type,
    required this.name,
    required this.description,
    required this.color,
  });
}

class WheelSituation {
  final String situation;
  final GunaType correctGuna;
  final String explanation;
  final String difficulty; // 'easy' | 'medium' | 'hard'

  const WheelSituation({
    required this.situation,
    required this.correctGuna,
    required this.explanation,
    required this.difficulty,
  });
}

class GameState {
  int level;
  int score;
  int streak;
  int maxStreak;

  GameState({
    this.level = 1,
    this.score = 0,
    this.streak = 0,
    this.maxStreak = 0,
  });

  GameState copyWith({int? level, int? score, int? streak, int? maxStreak}) {
    return GameState(
      level: level ?? this.level,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      maxStreak: maxStreak ?? this.maxStreak,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'score': score,
      'streak': streak,
      'maxStreak': maxStreak,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      level: json['level'] as int? ?? 1,
      score: json['score'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      maxStreak: json['maxStreak'] as int? ?? 0,
    );
  }
}

const List<GunaOption> gunaOptions = [
  GunaOption(
    type: GunaType.sattva,
    name: 'Sattva',
    description: 'Pure, harmonious, balanced',
    color: Color(0xFF4CAF50), // Green
  ),
  GunaOption(
    type: GunaType.rajas,
    name: 'Rajas',
    description: 'Active, passionate, restless',
    color: Color(0xFFFF9800), // Orange
  ),
  GunaOption(
    type: GunaType.tamas,
    name: 'Tamas',
    description: 'Dark, dull, destructive',
    color: Color(0xFF9C27B0), // Purple
  ),
];

const List<WheelSituation> wheelDatabase = [
  // EASY LEVEL
  WheelSituation(
    situation:
        'Meditating peacefully in a quiet garden, feeling inner calm and clarity.',
    correctGuna: GunaType.sattva,
    explanation:
        'This represents Sattva - pure, peaceful, and harmonious qualities.',
    difficulty: 'easy',
  ),
  WheelSituation(
    situation:
        'Working late into the night to finish a project, feeling stressed and impatient.',
    correctGuna: GunaType.rajas,
    explanation:
        'This shows Rajas - restless activity and passion that can lead to stress.',
    difficulty: 'easy',
  ),
  WheelSituation(
    situation:
        'Lying in bed all day, feeling lazy and unmotivated to do anything.',
    correctGuna: GunaType.tamas,
    explanation:
        'This demonstrates Tamas - inertia, darkness, and lack of motivation.',
    difficulty: 'easy',
  ),

  // MEDIUM LEVEL
  WheelSituation(
    situation:
        'Volunteering at a local shelter, feeling fulfilled by helping others.',
    correctGuna: GunaType.sattva,
    explanation:
        'Selfless service with pure intention reflects Sattva qualities.',
    difficulty: 'medium',
  ),
  WheelSituation(
    situation:
        'Starting multiple projects at once, excited but overwhelmed by too many commitments.',
    correctGuna: GunaType.rajas,
    explanation:
        'Excessive activity and passion without balance shows Rajas influence.',
    difficulty: 'medium',
  ),
  WheelSituation(
    situation:
        'Eating junk food while watching TV, feeling sluggish and disinterested in healthy activities.',
    correctGuna: GunaType.tamas,
    explanation:
        'Indulging in unhealthy habits with no self-control indicates Tamas.',
    difficulty: 'medium',
  ),

  // HARD LEVEL
  WheelSituation(
    situation:
        'Practicing yoga with focused attention, maintaining perfect posture and breath control.',
    correctGuna: GunaType.sattva,
    explanation:
        'Disciplined practice with clarity and balance is the essence of Sattva.',
    difficulty: 'hard',
  ),
  WheelSituation(
    situation: 'Competing fiercely in a game, pushing hard to win at any cost.',
    correctGuna: GunaType.rajas,
    explanation:
        'Intense competition and desire for victory reflects Rajas energy.',
    difficulty: 'hard',
  ),
  WheelSituation(
    situation:
        'Ignoring responsibilities, spending time in destructive behaviors that harm oneself and others.',
    correctGuna: GunaType.tamas,
    explanation:
        'Deliberately harmful actions and neglect of duties show Tamas qualities.',
    difficulty: 'hard',
  ),
];

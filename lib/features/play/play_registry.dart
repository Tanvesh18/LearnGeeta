import 'package:flutter/material.dart';

import '../../core/models/game_definition.dart';
import '../games/battlefield_debate/battlefield_debate_screen.dart';
import '../games/chapter_quest/chapter_quest_screen.dart';
import '../games/dharma_choices/dharma_choices_screen.dart';
import '../games/karma_path/karma_path_screen.dart';
import '../games/krishna_memory_cards/krishna_memory_cards_screen.dart';
import '../games/missing_word_mantra/missing_word_mantra_screen.dart';
import '../games/wheel_of_gunas/wheel_of_gunas_screen.dart';
import '../games/krishna_says/krishna_says_screen.dart';
import '../games/shloka_match/shloka_match_screen.dart';
import '../games/shloka_speedrun/shloka_speedrun_screen.dart';
import '../games/true_false/true_false_screen.dart';
import '../games/verse_order/verse_order_screen.dart';

class GameRegistry {
  const GameRegistry._();

  static final List<GameDefinition> games = [
    GameDefinition(
      id: 'shloka_match',
      title: 'Shloka Match',
      icon: Icons.extension,
      isUnlocked: (_) => true,
      builder: (_) => const ShlokaMatchScreen(),
    ),
    GameDefinition(
      id: 'verse_order',
      title: 'Verse Order',
      icon: Icons.sort,
      isUnlocked: (_) => true,
      builder: (_) => const VerseOrderScreen(),
    ),
    GameDefinition(
      id: 'true_false',
      title: 'True or False',
      icon: Icons.check_circle,
      isUnlocked: (_) => true,
      builder: (_) => const TrueFalseScreen(),
    ),
    GameDefinition(
      id: 'dharma_choices',
      title: 'Dharma Choices',
      icon: Icons.psychology,
      isUnlocked: (_) => true,
      builder: (_) => const DharmaChoicesScreen(),
    ),
    GameDefinition(
      id: 'missing_word_mantra',
      title: 'Missing Word Mantra',
      icon: Icons.edit,
      isUnlocked: (_) => true,
      builder: (_) => const MissingWordMantraScreen(),
    ),
    GameDefinition(
      id: 'chapter_quest',
      title: 'Chapter Quest',
      icon: Icons.menu_book,
      isUnlocked: (_) => true,
      builder: (_) => const ChapterQuestScreen(),
    ),
    GameDefinition(
      id: 'wheel_of_gunas',
      title: 'Wheel of Gunas',
      icon: Icons.rotate_right,
      isUnlocked: (_) => true,
      builder: (_) => const WheelOfGunasScreen(),
    ),
    GameDefinition(
      id: 'krishna_memory_cards',
      title: 'Krishna Memory Cards',
      icon: Icons.memory,
      isUnlocked: (_) => true,
      builder: (_) => const KrishnaMemoryCardsScreen(),
    ),
    GameDefinition(
      id: 'battlefield_debate',
      title: 'Battlefield Debate',
      icon: Icons.forum,
      isUnlocked: (_) => true,
      builder: (_) => const BattlefieldDebateScreen(),
    ),
    GameDefinition(
      id: 'krishna_says',
      title: 'Krishna Says',
      icon: Icons.lightbulb,
      isUnlocked: (_) => true,
      builder: (_) => const KrishnaSaysScreen(),
    ),
    GameDefinition(
      id: 'shloka_speed_run',
      title: 'Shloka Speed Run',
      icon: Icons.flash_on,
      isUnlocked: (_) => true,
      builder: (_) => const ShlokaSpeedRunScreen(),
    ),
    GameDefinition(
      id: 'karma_path',
      title: 'Karma Path',
      icon: Icons.fork_left,
      isUnlocked: (_) => true,
      builder: (_) => const KarmaPathScreen(),
    ),
  ];
}

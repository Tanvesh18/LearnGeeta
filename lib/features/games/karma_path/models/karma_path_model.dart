// Model definitions for Karma Path Builder (Story Mode) game

class StoryChoice {
  final String text;
  final String nextNodeId;
  final int karmaValue; // positive or negative karma impact

  const StoryChoice({
    required this.text,
    required this.nextNodeId,
    required this.karmaValue,
  });
}

class StoryNode {
  final String nodeId;
  final String title;
  final String description;
  final String emoji;
  final List<StoryChoice> choices;
  final bool isEnding; // true if this is a final node

  const StoryNode({
    required this.nodeId,
    required this.title,
    required this.description,
    required this.emoji,
    required this.choices,
    this.isEnding = false,
  });
}

class GameEnding {
  final String endingId;
  final String title;
  final String description;
  final String emoji;
  final String message;
  final int minKarma;
  final int maxKarma;

  const GameEnding({
    required this.endingId,
    required this.title,
    required this.description,
    required this.emoji,
    required this.message,
    required this.minKarma,
    required this.maxKarma,
  });
}

class GameState {
  int level; // not used for karma path, kept for consistency
  int score; // total games played
  int currentKarma;
  String currentNodeId;
  List<String> visitedNodeIds;

  GameState({
    this.level = 1,
    this.score = 0,
    this.currentKarma = 0,
    this.currentNodeId = 'start',
    List<String>? visitedNodeIds,
  }) : visitedNodeIds = visitedNodeIds ?? [];

  GameState copyWith({
    int? level,
    int? score,
    int? currentKarma,
    String? currentNodeId,
    List<String>? visitedNodeIds,
  }) {
    return GameState(
      level: level ?? this.level,
      score: score ?? this.score,
      currentKarma: currentKarma ?? this.currentKarma,
      currentNodeId: currentNodeId ?? this.currentNodeId,
      visitedNodeIds: visitedNodeIds ?? List<String>.from(this.visitedNodeIds),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'score': score,
      'currentKarma': currentKarma,
      'currentNodeId': currentNodeId,
      'visitedNodeIds': visitedNodeIds,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      level: json['level'] as int? ?? 1,
      score: json['score'] as int? ?? 0,
      currentKarma: json['currentKarma'] as int? ?? 0,
      currentNodeId: json['currentNodeId'] as String? ?? 'start',
      visitedNodeIds: List<String>.from(json['visitedNodeIds'] as List? ?? []),
    );
  }
}

// 4 Possible Endings
const List<GameEnding> gameEndings = [
  GameEnding(
    endingId: 'enlightened',
    title: '🌟 Enlightened Path',
    description: 'You discovered peace within',
    emoji: '🌟',
    message:
        '"You have realized that true happiness comes from within, from aligning your actions with your dharma and seeing the divinity in all beings. You are at peace." - Bhagavad Gita 12.13',
    minKarma: 8,
    maxKarma: 100,
  ),
  GameEnding(
    endingId: 'balanced',
    title: '⚖️ Balanced Life',
    description: 'You found harmony in duty and detachment',
    emoji: '⚖️',
    message:
        '"You have learned to fulfill your duties while maintaining inner balance. You perform your work without attachment to the fruits. This is true wisdom." - Bhagavad Gita 2.47-48',
    minKarma: 2,
    maxKarma: 7,
  ),
  GameEnding(
    endingId: 'struggling',
    title: '🌪️ Still Struggling',
    description: 'You face life\'s challenges with confusion',
    emoji: '🌪️',
    message:
        '"You are still caught in the cycle of desire and attachment. Seek wisdom, practice detachment, and remember your higher purpose. The path is never lost." - Bhagavad Gita 6.26',
    minKarma: -7,
    maxKarma: 1,
  ),
  GameEnding(
    endingId: 'lost',
    title: '🔴 Lost in Delusion',
    description: 'You surrendered to ego and attachment',
    emoji: '🔴',
    message:
        '"You have been consumed by ego, fear, and attachment. But know—it is never too late. Return to your dharma, release your ego, and reconnect with truth." - Bhagavad Gita 18.66',
    minKarma: -100,
    maxKarma: -8,
  ),
];

// Story Tree: 20+ nodes leading to 4 endings
const Map<String, StoryNode> storyTree = {
  'start': StoryNode(
    nodeId: 'start',
    title: 'A New Day',
    description:
        'You wake up feeling overwhelmed with life\'s challenges. Your mind is restless, and you\'re not sure how to move forward.',
    emoji: '🌅',
    choices: [
      StoryChoice(
        text: 'Seek quiet meditation before facing the day',
        nextNodeId: 'meditation',
        karmaValue: 2,
      ),
      StoryChoice(
        text: 'Rush into the day without thinking',
        nextNodeId: 'rush',
        karmaValue: -1,
      ),
      StoryChoice(
        text: 'Ask for help from a wise mentor',
        nextNodeId: 'mentor',
        karmaValue: 1,
      ),
    ],
  ),
  'meditation': StoryNode(
    nodeId: 'meditation',
    title: 'Moment of Clarity',
    description:
        'You sit quietly. In the silence, you feel connected to something deeper. A sense of purpose emerges.',
    emoji: '🧘',
    choices: [
      StoryChoice(
        text: 'Act with clear intention today',
        nextNodeId: 'clear_day',
        karmaValue: 2,
      ),
      StoryChoice(
        text: 'Feel peaceful but lose focus by afternoon',
        nextNodeId: 'distracted',
        karmaValue: 0,
      ),
    ],
  ),
  'rush': StoryNode(
    nodeId: 'rush',
    title: 'Chaos Unfolds',
    description:
        'Without intention, you stumble through the day. Conflicts arise. You react impulsively.',
    emoji: '⚡',
    choices: [
      StoryChoice(
        text: 'Apologize sincerely and learn from it',
        nextNodeId: 'learn_from_mistake',
        karmaValue: 2,
      ),
      StoryChoice(
        text: 'Blame others and move on',
        nextNodeId: 'blame_others',
        karmaValue: -2,
      ),
    ],
  ),
  'mentor': StoryNode(
    nodeId: 'mentor',
    title: 'Wise Counsel',
    description:
        'Your mentor reminds you: "Your only control is your effort and intention. Release the outcome."',
    emoji: '🧙',
    choices: [
      StoryChoice(
        text: 'Follow this wisdom deeply',
        nextNodeId: 'detachment_path',
        karmaValue: 2,
      ),
      StoryChoice(
        text: 'Agree but doubt later',
        nextNodeId: 'doubt_path',
        karmaValue: 0,
      ),
    ],
  ),
  'clear_day': StoryNode(
    nodeId: 'clear_day',
    title: 'Purposeful Action',
    description:
        'With clarity, everything feels easier. Your work flows. You help someone in need without expecting reward.',
    emoji: '✨',
    choices: [
      StoryChoice(
        text: 'Continue on this path of service',
        nextNodeId: 'service_continues',
        karmaValue: 2,
      ),
      StoryChoice(
        text: 'Expect recognition for your kindness',
        nextNodeId: 'ego_trap',
        karmaValue: -1,
      ),
    ],
  ),
  'distracted': StoryNode(
    nodeId: 'distracted',
    title: 'Lost Focus',
    description:
        'The peace fades. By evening, you\'re back to old patterns—scrolling, worrying, avoiding.',
    emoji: '📱',
    choices: [
      StoryChoice(
        text: 'Reconnect with your purpose',
        nextNodeId: 'recommit',
        karmaValue: 1,
      ),
      StoryChoice(
        text: 'Give in to distraction completely',
        nextNodeId: 'lost_in_distractions',
        karmaValue: -2,
      ),
    ],
  ),
  'learn_from_mistake': StoryNode(
    nodeId: 'learn_from_mistake',
    title: 'Growth Through Failure',
    description:
        'By owning your mistake, you learn humility. Others respect your honesty.',
    emoji: '🌱',
    choices: [
      StoryChoice(
        text: 'Use this lesson to guide future choices',
        nextNodeId: 'wisdom_gained',
        karmaValue: 2,
      ),
      StoryChoice(
        text: 'Quickly forget and repeat the pattern',
        nextNodeId: 'cycle_repeats',
        karmaValue: -1,
      ),
    ],
  ),
  'blame_others': StoryNode(
    nodeId: 'blame_others',
    title: 'Trapped in Ego',
    description:
        'By blaming others, you rob yourself of learning. Resentment grows.',
    emoji: '😠',
    choices: [
      StoryChoice(
        text: 'Recognize your responsibility',
        nextNodeId: 'ego_falls_away',
        karmaValue: 2,
      ),
      StoryChoice(
        text: 'Spiral deeper into blame',
        nextNodeId: 'ego_consumes',
        karmaValue: -2,
      ),
    ],
  ),
  'detachment_path': StoryNode(
    nodeId: 'detachment_path',
    title: 'Freedom in Non-Attachment',
    description:
        'You begin to release outcomes. You work hard but don\'t cling to success or failure.',
    emoji: '🦅',
    choices: [
      StoryChoice(
        text: 'Help others with this wisdom',
        nextNodeId: 'spread_wisdom',
        karmaValue: 2,
      ),
      StoryChoice(
        text: 'Keep this insight private',
        nextNodeId: 'isolated_wisdom',
        karmaValue: 0,
      ),
    ],
  ),
  'doubt_path': StoryNode(
    nodeId: 'doubt_path',
    title: 'Internal Conflict',
    description:
        'You agree with the wisdom but doubt creeps in. Can you really let go of control?',
    emoji: '❓',
    choices: [
      StoryChoice(
        text: 'Test the wisdom through practice',
        nextNodeId: 'experiential_learning',
        karmaValue: 1,
      ),
      StoryChoice(
        text: 'Reject it as impractical',
        nextNodeId: 'cynicism_takes_over',
        karmaValue: -2,
      ),
    ],
  ),
  'service_continues': StoryNode(
    nodeId: 'service_continues',
    title: 'Selfless Service',
    description:
        'You dedicate yourself to service. Each act strengthens your connection to something greater.',
    emoji: '🤝',
    choices: [
      StoryChoice(
        text: 'Move toward enlightenment',
        nextNodeId: 'enlightened',
        karmaValue: 3,
      ),
    ],
    isEnding: true,
  ),
  'ego_trap': StoryNode(
    nodeId: 'ego_trap',
    title: 'Ego Returns',
    description:
        'You helped, but expected reward. When recognition doesn\'t come, disappointment follows.',
    emoji: '😔',
    choices: [
      StoryChoice(
        text: 'Release expectations',
        nextNodeId: 'balanced',
        karmaValue: 2,
      ),
      StoryChoice(text: 'Become bitter', nextNodeId: 'lost', karmaValue: -3),
    ],
    isEnding: true,
  ),
  'recommit': StoryNode(
    nodeId: 'recommit',
    title: 'Renewed Intention',
    description:
        'You catch yourself and refocus. Small acts of awareness strengthen your path.',
    emoji: '🔄',
    choices: [
      StoryChoice(
        text: 'Continue practicing',
        nextNodeId: 'balanced',
        karmaValue: 2,
      ),
    ],
    isEnding: true,
  ),
  'lost_in_distractions': StoryNode(
    nodeId: 'lost_in_distractions',
    title: 'Deeper into Delusion',
    description: 'The more you escape, the more empty you feel. Anxiety grows.',
    emoji: '🌫️',
    choices: [
      StoryChoice(
        text: 'Reach out for help',
        nextNodeId: 'reaching_back',
        karmaValue: 2,
      ),
      StoryChoice(text: 'Sink deeper', nextNodeId: 'lost', karmaValue: -2),
    ],
    isEnding: true,
  ),
  'wisdom_gained': StoryNode(
    nodeId: 'wisdom_gained',
    title: 'True Learning',
    description:
        'Through failure, you discover resilience and wisdom. Your character deepens.',
    emoji: '📚',
    choices: [
      StoryChoice(
        text: 'Share wisdom to help others',
        nextNodeId: 'balanced',
        karmaValue: 2,
      ),
    ],
    isEnding: true,
  ),
  'cycle_repeats': StoryNode(
    nodeId: 'cycle_repeats',
    title: 'Patterns of Behavior',
    description:
        'Without reflection, you repeat the same mistakes. The cycle continues.',
    emoji: '🔁',
    choices: [
      StoryChoice(
        text: 'Break free from patterns',
        nextNodeId: 'struggling',
        karmaValue: 1,
      ),
      StoryChoice(text: 'Accept the cycle', nextNodeId: 'lost', karmaValue: -1),
    ],
    isEnding: true,
  ),
  'ego_falls_away': StoryNode(
    nodeId: 'ego_falls_away',
    title: 'Humility Emerges',
    description:
        'By taking responsibility, you feel lighter. Relationships heal.',
    emoji: '💫',
    choices: [
      StoryChoice(
        text: 'Move forward with wisdom',
        nextNodeId: 'balanced',
        karmaValue: 2,
      ),
    ],
    isEnding: true,
  ),
  'ego_consumes': StoryNode(
    nodeId: 'ego_consumes',
    title: 'Drowning in Pride',
    description: 'Your denial isolates you further. Others avoid you.',
    emoji: '💔',
    choices: [
      StoryChoice(
        text: 'Wake up and change',
        nextNodeId: 'reaching_back',
        karmaValue: 3,
      ),
      StoryChoice(text: 'Give up', nextNodeId: 'lost', karmaValue: -3),
    ],
    isEnding: true,
  ),
  'spread_wisdom': StoryNode(
    nodeId: 'spread_wisdom',
    title: 'Teaching Others',
    description:
        'You guide others toward freedom. Your compassion and wisdom ripple outward.',
    emoji: '🌊',
    choices: [
      StoryChoice(
        text: 'Reach enlightenment',
        nextNodeId: 'enlightened',
        karmaValue: 3,
      ),
    ],
    isEnding: true,
  ),
  'isolated_wisdom': StoryNode(
    nodeId: 'isolated_wisdom',
    title: 'Incomplete Journey',
    description:
        'Wisdom without sharing feels hollow. You\'re at peace but alone.',
    emoji: '🏔️',
    choices: [
      StoryChoice(
        text: 'Find peace in stillness',
        nextNodeId: 'balanced',
        karmaValue: 1,
      ),
    ],
    isEnding: true,
  ),
  'experiential_learning': StoryNode(
    nodeId: 'experiential_learning',
    title: 'Wisdom Through Experience',
    description: 'Over time, the wisdom proves true. Your faith in it deepens.',
    emoji: '⏳',
    choices: [
      StoryChoice(
        text: 'Achieve balanced understanding',
        nextNodeId: 'balanced',
        karmaValue: 2,
      ),
    ],
    isEnding: true,
  ),
  'cynicism_takes_over': StoryNode(
    nodeId: 'cynicism_takes_over',
    title: 'Rejection of Truth',
    description:
        'You dismiss wisdom as naive. You harden, becoming cynical and isolated.',
    emoji: '❌',
    choices: [
      StoryChoice(
        text: 'Soften and reconsider',
        nextNodeId: 'struggling',
        karmaValue: 1,
      ),
      StoryChoice(
        text: 'Remain trapped in cynicism',
        nextNodeId: 'lost',
        karmaValue: -2,
      ),
    ],
    isEnding: true,
  ),
  'reaching_back': StoryNode(
    nodeId: 'reaching_back',
    title: 'Second Chance',
    description:
        'You reach out. Help comes. You realize you\'re never too lost.',
    emoji: '🙏',
    choices: [
      StoryChoice(
        text: 'Rebuild with humility',
        nextNodeId: 'balanced',
        karmaValue: 2,
      ),
    ],
    isEnding: true,
  ),
  'enlightened': StoryNode(
    nodeId: 'enlightened',
    title: '✨ Ultimate Realization ✨',
    description:
        'You have fully integrated dharma, detachment, and compassion. You live in harmony with the divine.',
    emoji: '✨',
    choices: [],
    isEnding: true,
  ),
  'balanced': StoryNode(
    nodeId: 'balanced',
    title: '⚖️ Equilibrium Achieved ⚖️',
    description:
        'You have found balance between duty and peace, action and acceptance.',
    emoji: '⚖️',
    choices: [],
    isEnding: true,
  ),
  'struggling': StoryNode(
    nodeId: 'struggling',
    title: '🌪️ The Journey Continues 🌪️',
    description:
        'You still face challenges, but you now understand that the path itself is the destination.',
    emoji: '🌪️',
    choices: [],
    isEnding: true,
  ),
  'lost': StoryNode(
    nodeId: 'lost',
    title: '🔴 Lost in Illusion 🔴',
    description:
        'You are trapped in delusion, ego, and attachment. But even now, the door to change remains open.',
    emoji: '🔴',
    choices: [],
    isEnding: true,
  ),
};

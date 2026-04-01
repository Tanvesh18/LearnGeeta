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
  'start1': StoryNode(
    nodeId: 'start1',
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
  'start2': StoryNode(
    nodeId: 'start2',
    title: 'Morning Reflection',
    description:
        'As you prepare for your day, you notice a growing sense of dissatisfaction with your current path. What should guide your choices?',
    emoji: '🤔',
    choices: [
      StoryChoice(
        text: 'Follow your heart and intuition',
        nextNodeId: 'heart_guidance',
        karmaValue: 1,
      ),
      StoryChoice(
        text: 'Stick to practical and logical decisions',
        nextNodeId: 'logical_path',
        karmaValue: 0,
      ),
      StoryChoice(
        text: 'Seek guidance from ancient wisdom',
        nextNodeId: 'wisdom_seeking',
        karmaValue: 2,
      ),
    ],
  ),
  'start3': StoryNode(
    nodeId: 'start3',
    title: 'Unexpected Challenge',
    description:
        'A sudden obstacle appears in your path today. How do you respond to this test of your character?',
    emoji: '⚠️',
    choices: [
      StoryChoice(
        text: 'Face it with courage and determination',
        nextNodeId: 'courageous_response',
        karmaValue: 2,
      ),
      StoryChoice(
        text: 'Try to avoid or work around it',
        nextNodeId: 'avoidance_tactic',
        karmaValue: -1,
      ),
      StoryChoice(
        text: 'Accept it as part of your journey',
        nextNodeId: 'acceptance_path',
        karmaValue: 1,
      ),
    ],
  ),
  'start4': StoryNode(
    nodeId: 'start4',
    title: 'Inner Conflict',
    description:
        'You feel torn between what you want and what you know is right. Which voice will you listen to?',
    emoji: '⚖️',
    choices: [
      StoryChoice(
        text: 'Choose what brings immediate pleasure',
        nextNodeId: 'pleasure_seeking',
        karmaValue: -2,
      ),
      StoryChoice(
        text: 'Follow your duty and responsibility',
        nextNodeId: 'duty_bound',
        karmaValue: 2,
      ),
      StoryChoice(
        text: 'Find a middle path between both',
        nextNodeId: 'balanced_approach',
        karmaValue: 1,
      ),
    ],
  ),
  'start5': StoryNode(
    nodeId: 'start5',
    title: 'Social Encounter',
    description:
        'You encounter someone who needs help, but helping them would inconvenience you. What do you do?',
    emoji: '🤝',
    choices: [
      StoryChoice(
        text: 'Help without hesitation or expectation',
        nextNodeId: 'selfless_help',
        karmaValue: 3,
      ),
      StoryChoice(
        text: 'Help but expect something in return',
        nextNodeId: 'conditional_help',
        karmaValue: 0,
      ),
      StoryChoice(
        text: 'Politely decline and continue your way',
        nextNodeId: 'self_focused',
        karmaValue: -1,
      ),
    ],
  ),
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
  'heart_guidance': StoryNode(
    nodeId: 'heart_guidance',
    title: 'Following Your Heart',
    description:
        'You listen to your inner voice. It leads you to make choices that feel authentic and true to yourself.',
    emoji: '❤️',
    choices: [
      StoryChoice(
        text: 'Trust the guidance completely',
        nextNodeId: 'intuitive_flow',
        karmaValue: 2,
      ),
      StoryChoice(
        text: 'Balance heart with practical considerations',
        nextNodeId: 'balanced_approach',
        karmaValue: 1,
      ),
    ],
  ),
  'logical_path': StoryNode(
    nodeId: 'logical_path',
    title: 'Rational Decision Making',
    description:
        'You analyze situations logically, weighing pros and cons before making decisions.',
    emoji: '🧠',
    choices: [
      StoryChoice(
        text: 'Stick strictly to logic and data',
        nextNodeId: 'analytical_rigor',
        karmaValue: 0,
      ),
      StoryChoice(
        text: 'Allow some intuition into your logic',
        nextNodeId: 'balanced_approach',
        karmaValue: 1,
      ),
    ],
  ),
  'wisdom_seeking': StoryNode(
    nodeId: 'wisdom_seeking',
    title: 'Seeking Ancient Wisdom',
    description:
        'You turn to timeless teachings and spiritual guidance to navigate your path.',
    emoji: '📜',
    choices: [
      StoryChoice(
        text: 'Study and apply the teachings deeply',
        nextNodeId: 'deep_study',
        karmaValue: 2,
      ),
      StoryChoice(
        text: 'Use wisdom as occasional guidance',
        nextNodeId: 'occasional_wisdom',
        karmaValue: 1,
      ),
    ],
  ),
  'courageous_response': StoryNode(
    nodeId: 'courageous_response',
    title: 'Facing Challenges',
    description:
        'You confront the obstacle directly, using it as an opportunity to grow stronger.',
    emoji: '🛡️',
    choices: [
      StoryChoice(
        text: 'Overcome it through persistent effort',
        nextNodeId: 'victory_through_effort',
        karmaValue: 2,
      ),
      StoryChoice(
        text: 'Learn valuable lessons from the struggle',
        nextNodeId: 'growth_through_challenge',
        karmaValue: 1,
      ),
    ],
  ),
  'avoidance_tactic': StoryNode(
    nodeId: 'avoidance_tactic',
    title: 'Avoiding Conflict',
    description:
        'You find ways to circumvent the challenge, preserving your comfort and convenience.',
    emoji: '🌀',
    choices: [
      StoryChoice(
        text: 'Reflect on why you avoided it',
        nextNodeId: 'self_reflection',
        karmaValue: 1,
      ),
      StoryChoice(
        text: 'Continue avoiding difficult situations',
        nextNodeId: 'comfort_zone',
        karmaValue: -1,
      ),
    ],
  ),
  'acceptance_path': StoryNode(
    nodeId: 'acceptance_path',
    title: 'Embracing What Is',
    description:
        'You accept the challenge as part of life\'s flow, surrendering to what you cannot control.',
    emoji: '🌊',
    choices: [
      StoryChoice(
        text: 'Respond with grace and wisdom',
        nextNodeId: 'graceful_response',
        karmaValue: 2,
      ),
      StoryChoice(
        text: 'Accept but still try to influence outcomes',
        nextNodeId: 'partial_surrender',
        karmaValue: 0,
      ),
    ],
  ),
  'pleasure_seeking': StoryNode(
    nodeId: 'pleasure_seeking',
    title: 'Pursuit of Pleasure',
    description:
        'You prioritize immediate gratification and personal desires above other considerations.',
    emoji: '🎉',
    choices: [
      StoryChoice(
        text: 'Enjoy but recognize the emptiness',
        nextNodeId: 'fleeting_joy',
        karmaValue: 0,
      ),
      StoryChoice(
        text: 'Indulge without restraint',
        nextNodeId: 'excessive_indulgence',
        karmaValue: -2,
      ),
    ],
  ),
  'duty_bound': StoryNode(
    nodeId: 'duty_bound',
    title: 'Path of Duty',
    description:
        'You honor your responsibilities and commitments, placing duty above personal desires.',
    emoji: '⚖️',
    choices: [
      StoryChoice(
        text: 'Perform duty with love and devotion',
        nextNodeId: 'devotional_service',
        karmaValue: 3,
      ),
      StoryChoice(
        text: 'Do your duty but resent it',
        nextNodeId: 'resentful_duty',
        karmaValue: 0,
      ),
    ],
  ),
  'selfless_help': StoryNode(
    nodeId: 'selfless_help',
    title: 'Pure Compassion',
    description:
        'Your help comes from genuine care for others, without any thought of personal gain.',
    emoji: '🤲',
    choices: [
      StoryChoice(
        text: 'Continue helping others selflessly',
        nextNodeId: 'ongoing_service',
        karmaValue: 3,
      ),
    ],
    isEnding: true,
  ),
  'conditional_help': StoryNode(
    nodeId: 'conditional_help',
    title: 'Transactional Help',
    description:
        'You help others but always keep track of what you give and what you might receive in return.',
    emoji: '🤝',
    choices: [
      StoryChoice(
        text: 'Learn to give without expectation',
        nextNodeId: 'learning_generosity',
        karmaValue: 1,
      ),
      StoryChoice(
        text: 'Keep relationships transactional',
        nextNodeId: 'calculated_interactions',
        karmaValue: -1,
      ),
    ],
  ),
  'self_focused': StoryNode(
    nodeId: 'self_focused',
    title: 'Self-Preservation',
    description:
        'You prioritize your own needs and comfort, choosing not to inconvenience yourself for others.',
    emoji: '🛡️',
    choices: [
      StoryChoice(
        text: 'Reflect on the impact of your choice',
        nextNodeId: 'self_reflection',
        karmaValue: 1,
      ),
      StoryChoice(
        text: 'Continue prioritizing yourself',
        nextNodeId: 'isolated_path',
        karmaValue: -1,
      ),
    ],
  ),
  'intuitive_flow': StoryNode(
    nodeId: 'intuitive_flow',
    title: 'Flow of Intuition',
    description:
        'Following your heart leads you to experiences that feel deeply meaningful and authentic.',
    emoji: '🌈',
    choices: [
      StoryChoice(
        text: 'Trust intuition in all decisions',
        nextNodeId: 'balanced',
        karmaValue: 2,
      ),
    ],
    isEnding: true,
  ),
  'analytical_rigor': StoryNode(
    nodeId: 'analytical_rigor',
    title: 'Pure Logic',
    description:
        'Your logical approach serves you well in practical matters, but sometimes misses the human element.',
    emoji: '📊',
    choices: [
      StoryChoice(
        text: 'Incorporate emotional intelligence',
        nextNodeId: 'balanced',
        karmaValue: 1,
      ),
    ],
    isEnding: true,
  ),
  'deep_study': StoryNode(
    nodeId: 'deep_study',
    title: 'Deep Wisdom',
    description:
        'You immerse yourself in spiritual teachings, finding profound guidance for your life.',
    emoji: '📚',
    choices: [
      StoryChoice(
        text: 'Apply wisdom in daily life',
        nextNodeId: 'enlightened',
        karmaValue: 3,
      ),
    ],
    isEnding: true,
  ),
  'occasional_wisdom': StoryNode(
    nodeId: 'occasional_wisdom',
    title: 'Occasional Guidance',
    description:
        'You consult wisdom teachings when needed, finding them helpful but not transformative.',
    emoji: '💭',
    choices: [
      StoryChoice(
        text: 'Deepen your practice',
        nextNodeId: 'balanced',
        karmaValue: 1,
      ),
    ],
    isEnding: true,
  ),
  'victory_through_effort': StoryNode(
    nodeId: 'victory_through_effort',
    title: 'Triumph Through Persistence',
    description:
        'Your determination overcomes the obstacle, building your confidence and strength.',
    emoji: '🏆',
    choices: [
      StoryChoice(
        text: 'Use this strength to help others',
        nextNodeId: 'balanced',
        karmaValue: 2,
      ),
    ],
    isEnding: true,
  ),
  'growth_through_challenge': StoryNode(
    nodeId: 'growth_through_challenge',
    title: 'Learning from Adversity',
    description:
        'The challenge teaches you valuable lessons about resilience and wisdom.',
    emoji: '🌱',
    choices: [
      StoryChoice(
        text: 'Apply these lessons broadly',
        nextNodeId: 'balanced',
        karmaValue: 2,
      ),
    ],
    isEnding: true,
  ),
  'comfort_zone': StoryNode(
    nodeId: 'comfort_zone',
    title: 'Staying Comfortable',
    description:
        'You avoid challenges, maintaining your comfort but missing opportunities for growth.',
    emoji: '🛋️',
    choices: [
      StoryChoice(
        text: 'Eventually face challenges',
        nextNodeId: 'struggling',
        karmaValue: 0,
      ),
    ],
    isEnding: true,
  ),
  'graceful_response': StoryNode(
    nodeId: 'graceful_response',
    title: 'Grace Under Pressure',
    description:
        'You handle the challenge with wisdom and composure, turning difficulty into opportunity.',
    emoji: '🕊️',
    choices: [
      StoryChoice(
        text: 'Continue responding with grace',
        nextNodeId: 'balanced',
        karmaValue: 2,
      ),
    ],
    isEnding: true,
  ),
  'partial_surrender': StoryNode(
    nodeId: 'partial_surrender',
    title: 'Mixed Acceptance',
    description:
        'You accept what you cannot change but still try to control what you can.',
    emoji: '⚖️',
    choices: [
      StoryChoice(
        text: 'Learn to surrender more fully',
        nextNodeId: 'balanced',
        karmaValue: 1,
      ),
    ],
    isEnding: true,
  ),
  'fleeting_joy': StoryNode(
    nodeId: 'fleeting_joy',
    title: 'Temporary Satisfaction',
    description:
        'Pleasure brings momentary happiness, but you recognize its impermanence.',
    emoji: '🎈',
    choices: [
      StoryChoice(
        text: 'Seek deeper, lasting fulfillment',
        nextNodeId: 'struggling',
        karmaValue: 1,
      ),
    ],
    isEnding: true,
  ),
  'excessive_indulgence': StoryNode(
    nodeId: 'excessive_indulgence',
    title: 'Lost in Desire',
    description:
        'Pursuing pleasure without restraint leads to dissatisfaction and regret.',
    emoji: '🌪️',
    choices: [
      StoryChoice(
        text: 'Recognize the harm and change',
        nextNodeId: 'lost',
        karmaValue: -2,
      ),
    ],
    isEnding: true,
  ),
  'devotional_service': StoryNode(
    nodeId: 'devotional_service',
    title: 'Sacred Duty',
    description:
        'You perform your duties with love, seeing them as offerings to something greater.',
    emoji: '🙏',
    choices: [
      StoryChoice(
        text: 'Reach enlightenment through service',
        nextNodeId: 'enlightened',
        karmaValue: 3,
      ),
    ],
    isEnding: true,
  ),
  'resentful_duty': StoryNode(
    nodeId: 'resentful_duty',
    title: 'Burdened Obligation',
    description:
        'You fulfill your responsibilities but carry resentment, diminishing the joy in your actions.',
    emoji: '😞',
    choices: [
      StoryChoice(
        text: 'Transform duty into devotion',
        nextNodeId: 'balanced',
        karmaValue: 1,
      ),
    ],
    isEnding: true,
  ),
  'ongoing_service': StoryNode(
    nodeId: 'ongoing_service',
    title: 'Lifelong Service',
    description:
        'Your selfless service becomes a way of life, bringing deep fulfillment and connection.',
    emoji: '🌟',
    choices: [
      StoryChoice(
        text: 'Achieve ultimate realization',
        nextNodeId: 'enlightened',
        karmaValue: 3,
      ),
    ],
    isEnding: true,
  ),
  'learning_generosity': StoryNode(
    nodeId: 'learning_generosity',
    title: 'Growing in Generosity',
    description:
        'You learn to give more freely, discovering the joy that comes from unconditional giving.',
    emoji: '🎁',
    choices: [
      StoryChoice(
        text: 'Embrace pure generosity',
        nextNodeId: 'balanced',
        karmaValue: 2,
      ),
    ],
    isEnding: true,
  ),
  'calculated_interactions': StoryNode(
    nodeId: 'calculated_interactions',
    title: 'Strategic Relationships',
    description:
        'You maintain relationships based on mutual benefit, keeping emotional distance.',
    emoji: '🤝',
    choices: [
      StoryChoice(
        text: 'Open up to deeper connections',
        nextNodeId: 'struggling',
        karmaValue: 0,
      ),
    ],
    isEnding: true,
  ),
  'isolated_path': StoryNode(
    nodeId: 'isolated_path',
    title: 'Solitary Journey',
    description:
        'Focusing only on yourself leads to isolation, though you maintain your independence.',
    emoji: '🏔️',
    choices: [
      StoryChoice(
        text: 'Seek connection with others',
        nextNodeId: 'struggling',
        karmaValue: 1,
      ),
    ],
    isEnding: true,
  ),
  'self_reflection': StoryNode(
    nodeId: 'self_reflection',
    title: 'Inner Reflection',
    description:
        'You take time to examine your choices and their impact on yourself and others.',
    emoji: '🪞',
    choices: [
      StoryChoice(
        text: 'Grow from self-awareness',
        nextNodeId: 'balanced',
        karmaValue: 2,
      ),
    ],
    isEnding: true,
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

import 'dart:ui';

import '../utils/format.dart';

class DaySpend {
  const DaySpend({required this.day, required this.amount});

  final String day;
  final double amount;
}

class InsightHighlight {
  const InsightHighlight({
    required this.icon,
    required this.positive,
    required this.title,
    required this.body,
  });

  final String icon;

  /// Green tile for good news, warm tile otherwise.
  final bool positive;
  final String title;
  final String body;
}

class InsightsData {
  const InsightsData({
    required this.updatedLabel,
    required this.healthScore,
    required this.healthDelta,
    required this.weekSpend,
    required this.missedLabel,
    required this.missedAgent,
    required this.missedAmount,
    required this.missedBody,
    required this.highlights,
    required this.suggestionIcon,
    required this.suggestionTitle,
    required this.suggestionBody,
    required this.suggestionAppliedBody,
  });

  factory InsightsData.fromJson(Map<String, dynamic> json) {
    final missed = json['missedRewards'] as Map<String, dynamic>;
    final suggestion = json['suggestion'] as Map<String, dynamic>;
    return InsightsData(
      updatedLabel: json['updatedLabel'] as String,
      healthScore: json['healthScore'] as int,
      healthDelta: json['healthDelta'] as String,
      weekSpend: [
        for (final d in json['weekSpend'] as List)
          DaySpend(
            day: (d as Map<String, dynamic>)['day'] as String,
            amount: (d['amount'] as num).toDouble(),
          ),
      ],
      missedLabel: missed['label'] as String,
      missedAgent: missed['agent'] as String,
      missedAmount: (missed['amount'] as num).toDouble(),
      missedBody: missed['body'] as String,
      highlights: [
        for (final h in json['highlights'] as List)
          InsightHighlight(
            icon: (h as Map<String, dynamic>)['icon'] as String,
            positive: h['tone'] == 'green',
            title: h['title'] as String,
            body: h['body'] as String,
          ),
      ],
      suggestionIcon: suggestion['icon'] as String,
      suggestionTitle: suggestion['title'] as String,
      suggestionBody: suggestion['body'] as String,
      suggestionAppliedBody: suggestion['appliedBody'] as String,
    );
  }

  final String updatedLabel;
  final int healthScore;
  final String healthDelta;
  final List<DaySpend> weekSpend;
  final String missedLabel;
  final String missedAgent;
  final double missedAmount;
  final String missedBody;
  final List<InsightHighlight> highlights;
  final String suggestionIcon;
  final String suggestionTitle;
  final String suggestionBody;
  final String suggestionAppliedBody;
}

class Agent {
  const Agent({
    required this.id,
    required this.name,
    required this.status,
    required this.pausedStatus,
    required this.icon,
    required this.tile,
    required this.ink,
    required this.enabled,
    this.route,
  });

  factory Agent.fromJson(Map<String, dynamic> json) => Agent(
    id: json['id'] as String,
    name: json['name'] as String,
    status: json['status'] as String,
    pausedStatus: json['pausedStatus'] as String,
    icon: json['icon'] as String,
    tile: hexColor(json['tile'] as String),
    ink: hexColor(json['ink'] as String),
    enabled: json['enabled'] as bool,
    route: json['route'] as String?,
  );

  final String id;
  final String name;

  /// What the agent last did, shown while it runs.
  final String status;
  final String pausedStatus;
  final String icon;
  final Color tile;
  final Color ink;
  final bool enabled;

  /// Screen the agent works on; tapping its card opens it.
  final String? route;

  Agent copyWith({bool? enabled}) => Agent(
    id: id,
    name: name,
    status: status,
    pausedStatus: pausedStatus,
    icon: icon,
    tile: tile,
    ink: ink,
    enabled: enabled ?? this.enabled,
    route: route,
  );
}

/// Pre-filled values for the "Create Agent" form.
class AgentBuilderDefaults {
  const AgentBuilderDefaults({
    required this.step,
    required this.name,
    required this.description,
    required this.instructions,
    required this.watchOptions,
    required this.defaultWatch,
    required this.frequencies,
    required this.defaultFrequency,
  });

  factory AgentBuilderDefaults.fromJson(
    Map<String, dynamic> json,
  ) => AgentBuilderDefaults(
    step: json['step'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    instructions: json['instructions'] as String,
    watchOptions: [for (final o in json['watchOptions'] as List) o as String],
    defaultWatch: [for (final o in json['defaultWatch'] as List) o as String],
    frequencies: [for (final o in json['frequencies'] as List) o as String],
    defaultFrequency: json['defaultFrequency'] as String,
  );

  final String step;
  final String name;
  final String description;
  final String instructions;
  final List<String> watchOptions;
  final List<String> defaultWatch;
  final List<String> frequencies;
  final String defaultFrequency;
}

class ChatAction {
  const ChatAction({
    required this.id,
    required this.label,
    required this.primary,
    required this.reply,
  });

  final String id;
  final String label;
  final bool primary;
  final String reply;
}

/// One bubble in the assistant chat. AI text may use `**bold**` and
/// `[[accent]]` markup; a [cardId] turns the bubble into a card attachment
/// with [text] as its caption; [actions] renders quick-reply buttons.
class ChatMessage {
  const ChatMessage({
    required this.fromUser,
    this.text = '',
    this.cardId,
    this.actions = const [],
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    fromUser: json['from'] == 'user',
    text: json['text'] as String? ?? '',
    cardId: json['cardId'] as String?,
    actions: [
      for (final a in json['actions'] as List? ?? const [])
        ChatAction(
          id: (a as Map<String, dynamic>)['id'] as String,
          label: a['label'] as String,
          primary: a['primary'] as bool,
          reply: a['reply'] as String,
        ),
    ],
  );

  final bool fromUser;
  final String text;
  final String? cardId;
  final List<ChatAction> actions;
}

class AssistantScript {
  const AssistantScript({
    required this.connectedAgents,
    required this.conversation,
    required this.suggestions,
    required this.replies,
    required this.fallback,
  });

  factory AssistantScript.fromJson(Map<String, dynamic> json) =>
      AssistantScript(
        connectedAgents: json['connectedAgents'] as int,
        conversation: [
          for (final m in json['conversation'] as List)
            ChatMessage.fromJson(m as Map<String, dynamic>),
        ],
        suggestions: [for (final s in json['suggestions'] as List) s as String],
        replies: [
          for (final r in json['replies'] as List)
            (
              keywords: [
                for (final k in (r as Map<String, dynamic>)['keywords'] as List)
                  k as String,
              ],
              text: r['text'] as String,
            ),
        ],
        fallback: json['fallback'] as String,
      );

  final int connectedAgents;
  final List<ChatMessage> conversation;
  final List<String> suggestions;
  final List<({List<String> keywords, String text})> replies;
  final String fallback;

  /// Picks the canned answer whose keywords appear in [question].
  String replyTo(String question) {
    final q = question.toLowerCase();
    for (final reply in replies) {
      if (reply.keywords.any(q.contains)) return reply.text;
    }
    return fallback;
  }
}

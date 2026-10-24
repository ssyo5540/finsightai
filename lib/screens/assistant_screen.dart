import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../models/ai.dart';
import '../router.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/fs_icon.dart';
import '../widgets/gradients.dart';

/// 12 FinSight AI chat. Answers come from the canned script in
/// `assistant.json`; there is no model behind it in the MVP.
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  var _typing = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  /// Shows the typing bubble briefly, then posts [reply].
  Future<void> _respond(String reply) async {
    setState(() => _typing = true);
    _scrollToEnd();
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    AppScope.read(context)
        .addChatMessage(ChatMessage(fromUser: false, text: reply));
    setState(() => _typing = false);
    _scrollToEnd();
  }

  void _ask(String question) {
    final text = question.trim();
    if (text.isEmpty || _typing) return;
    final state = AppScope.read(context);
    state.addChatMessage(ChatMessage(fromUser: true, text: text));
    _input.clear();
    _respond(state.data.assistant.replyTo(text));
  }

  void _answer(ChatMessage source, ChatAction action) {
    if (_typing) return;
    _respond(AppScope.read(context).answerAction(source, action));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final messages = state.chat;
    final shift = context.topShift;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              _Header(
                height: 214 + shift,
                top: 54 + shift,
                agents: state.activeAgents,
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                  itemCount: messages.length + (_typing ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: _AiBubble(text: '**…**', typing: true),
                      );
                    }
                    final message = messages[index];
                    final previous = index == 0 ? null : messages[index - 1];
                    final gap = previous == null
                        ? 0.0
                        : (!message.fromUser &&
                              !previous.fromUser &&
                              message.actions.isEmpty)
                        ? 8.0
                        : 12.0;
                    return Padding(
                      padding: EdgeInsets.only(top: gap),
                      child: _MessageView(
                        message: message,
                        onAction: (action) => _answer(message, action),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 33,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.data.assistant.suggestions.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final suggestion = state.data.assistant.suggestions[index];
                    return Tappable(
                      onTap: () => _ask(suggestion),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Brand.chipBorder),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          suggestion,
                          style: inter(12, color: Brand.navInk),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, keyboardOpen ? 10 : 30),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.only(left: 18, right: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Brand.border),
                    boxShadow: [cssShadow(0, 8, 24, const Color(0x143C1400))],
                  ),
                  child: Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: Semantics(
                          label: 'Ask FinSight AI',
                          textField: true,
                          child: TextField(
                            controller: _input,
                            textInputAction: TextInputAction.send,
                            onSubmitted: _ask,
                            style: inter(15, color: Brand.ink),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Ask about your money…',
                              hintStyle: inter(
                                15,
                                color: const Color(0xFF8A8A8A),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Tappable(
                        label: 'Voice input',
                        onTap: () => showToast(
                          context,
                          'Voice questions are coming after the MVP.',
                        ),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Center(
                            child: FsIcon(
                              FsIcons.mic,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ),
                      ),
                      Tappable(
                        label: 'Send',
                        onTap: () => _ask(_input.text),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: CssLinearGradient(
                              135,
                              colors: [Brand.ember, Brand.brick],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const FsIcon(
                            FsIcons.arrowUp,
                            size: 18,
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.height,
    required this.top,
    required this.agents,
  });

  final double height;
  final double top;
  final int agents;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
      child: GradientLayers(
        layers: [
          cssGlow(const Color(0x80FFAA64), cx: 0.5, cy: 0.7, rx: 0.6, ry: 0.7),
          const CssLinearGradient(
            180,
            colors: [Color(0xFF3A0D04), Color(0xFF8E2A0C), Color(0xFFD2591D)],
            stops: [0, 0.55, 1],
          ),
        ],
        child: SizedBox(
          height: height,
          child: Stack(
            children: [
              Positioned(
                top: top,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    GlassIconButton(
                      icon: FsIcons.chevronLeft,
                      label: 'Back',
                      onTap: () => AppRouter.back(context),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'FinSight AI',
                            style: inter(
                              17,
                              weight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 5,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Brand.mint,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                '$agents agents connected',
                                style: inter(12, color: glass(0.8)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GlassIconButton(
                      icon: FsIcons.more,
                      label: 'More options',
                      filled: true,
                      onTap: () =>
                          Navigator.of(context).pushNamed(Routes.agents),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 22,
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: cssRadial(
                        colors: const [
                          Color(0xFFFFE3CC),
                          Color(0xFFF4955A),
                          Color(0xFFA8340F),
                        ],
                        stops: const [0, 0.45, 1],
                        cx: 0.35,
                        cy: 0.3,
                        rx: 0.955,
                        ry: 0.955,
                      ),
                      boxShadow: [
                        cssShadow(0, 10, 30, const Color(0x663C0A00)),
                        BoxShadow(color: glass(0.05), spreadRadius: 22),
                        BoxShadow(color: glass(0.1), spreadRadius: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.message, required this.onAction});

  final ChatMessage message;
  final ValueChanged<ChatAction> onAction;

  @override
  Widget build(BuildContext context) {
    if (message.actions.isNotEmpty) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final action in message.actions)
            Tappable(
              onTap: () => onAction(action),
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: action.primary ? Brand.ink : Colors.white,
                  borderRadius: BorderRadius.circular(19),
                  border: action.primary
                      ? null
                      : Border.all(color: Brand.border),
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    action.label,
                    style: inter(
                      13,
                      weight: FontWeight.w500,
                      color: action.primary ? Colors.white : Brand.ink,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }
    if (message.fromUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: FractionallySizedBox(
          widthFactor: 0.78,
          alignment: Alignment.centerRight,
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: const BoxDecoration(
                color: Brand.ink,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: Text(
                message.text,
                style: inter(14, height: 1.45, color: Colors.white),
              ),
            ),
          ),
        ),
      );
    }
    if (message.cardId != null) {
      final card = AppScope.of(context).cardById(message.cardId!);
      return FractionallySizedBox(
        widthFactor: 0.88,
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 54,
                height: 36,
                child: CardFace(
                  card: card,
                  radius: 7,
                  accentRight: -8,
                  accentTop: -6,
                  accentWidth: 30,
                  accentHeight: 50,
                  accentOpacity: 1,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${card.name} · ${card.last4}',
                      style: inter(13, weight: FontWeight.w600),
                    ),
                    Text(message.text, style: inter(12, color: Brand.muted)),
                  ],
                ),
              ),
              Tappable(
                onTap: () => Navigator.of(context).pushNamed(Routes.cardPicker),
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Brand.peach,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Details',
                    style: inter(
                      12,
                      weight: FontWeight.w600,
                      color: Brand.rust,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return _AiBubble(text: message.text);
  }
}

class _AiBubble extends StatelessWidget {
  const _AiBubble({required this.text, this.typing = false});

  final String text;
  final bool typing;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.88,
      alignment: Alignment.centerLeft,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
              bottomLeft: Radius.circular(6),
              bottomRight: Radius.circular(22),
            ),
          ),
          child: Semantics(
            liveRegion: !typing,
            label: typing ? 'FinSight AI is typing' : null,
            child: Text.rich(
              TextSpan(children: richSpans(text)),
              style: inter(
                14,
                height: 1.45,
                color: typing ? Brand.muted : Brand.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Turns `**bold**` and `[[accent]]` markup into styled spans.
List<TextSpan> richSpans(String text) {
  final spans = <TextSpan>[];
  final pattern = RegExp(r'\*\*(.+?)\*\*|\[\[(.+?)\]\]');
  var index = 0;
  for (final match in pattern.allMatches(text)) {
    if (match.start > index) {
      spans.add(TextSpan(text: text.substring(index, match.start)));
    }
    final bold = match.group(1);
    spans.add(
      bold != null
          ? TextSpan(
              text: bold,
              style: const TextStyle(fontWeight: FontWeight.w600),
            )
          : TextSpan(
              text: match.group(2),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Brand.rust,
              ),
            ),
    );
    index = match.end;
  }
  if (index < text.length) spans.add(TextSpan(text: text.substring(index)));
  return spans;
}

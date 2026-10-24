import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../router.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/fs_icon.dart';
import '../widgets/gradients.dart';
import '../widgets/sheets.dart';

/// 11 Create Agent: name it, choose what it watches, describe the job.
class CreateAgentScreen extends StatefulWidget {
  const CreateAgentScreen({super.key});

  @override
  State<CreateAgentScreen> createState() => _CreateAgentScreenState();
}

class _CreateAgentScreenState extends State<CreateAgentScreen> {
  late final TextEditingController _name;
  late final TextEditingController _instructions;
  late final Set<String> _watch;
  late String _frequency;

  @override
  void initState() {
    super.initState();
    final defaults = AppScope.read(context).data.agentBuilder;
    _name = TextEditingController(text: defaults.name);
    _instructions = TextEditingController(text: defaults.instructions);
    _watch = {...defaults.defaultWatch};
    _frequency = defaults.defaultFrequency;
  }

  @override
  void dispose() {
    _name.dispose();
    _instructions.dispose();
    super.dispose();
  }

  void _launch() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      showToast(context, 'Give your agent a name first.');
      return;
    }
    if (_watch.isEmpty) {
      showToast(context, 'Pick at least one thing to watch.');
      return;
    }
    AppScope.read(context).addAgent(name: name, frequency: _frequency);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('$name is live'),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaults = AppScope.of(context).data.agentBuilder;
    final shift = context.topShift;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16, 54 + shift, 16, 20),
                  children: [
                    _inset(
                      Row(
                        children: [
                          Tappable(
                            label: 'Back',
                            onTap: () => AppRouter.back(context),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Brand.border),
                              ),
                              alignment: Alignment.center,
                              child: const FsIcon(FsIcons.chevronLeft),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Create Agent',
                              textAlign: TextAlign.center,
                              style: inter(17, weight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(
                            width: 44,
                            child: Text(
                              defaults.step,
                              textAlign: TextAlign.right,
                              style: inter(13, color: Brand.muted),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _AgentHero(name: _name, description: defaults.description),
                    const SizedBox(height: 18),
                    _inset(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'What should it watch?',
                            style: inter(14, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final option in defaults.watchOptions)
                                ChoiceChipPill(
                                  label: option,
                                  selected: _watch.contains(option),
                                  onTap: () => setState(() {
                                    if (!_watch.remove(option)) {
                                      _watch.add(option);
                                    }
                                  }),
                                ),
                            ],
                          ),
                          const SizedBox(height: 17),
                          Text(
                            'Instructions',
                            style: inter(14, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 104,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Brand.border),
                            ),
                            child: Semantics(
                              label: 'Instructions',
                              textField: true,
                              child: TextField(
                                controller: _instructions,
                                maxLines: null,
                                expands: true,
                                style: inter(14, height: 1.5, color: Brand.ink),
                                decoration: const InputDecoration(
                                  isCollapsed: true,
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            spacing: 6,
                            children: [
                              const FsIcon(
                                FsIcons.sparkle,
                                size: 13,
                                color: Brand.rust,
                                strokeWidth: 2,
                              ),
                              Expanded(
                                child: Text(
                                  "Write it like you'd tell a friend. FinSight AI does the rest.",
                                  style: inter(12, color: Brand.muted),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Notify me',
                            style: inter(14, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          Semantics(
                            label: 'Notification frequency',
                            container: true,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Brand.segment,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Row(
                                spacing: 4,
                                children: [
                                  for (final f in defaults.frequencies)
                                    Expanded(
                                      child: Tappable(
                                        selected: f == _frequency,
                                        onTap: () =>
                                            setState(() => _frequency = f),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: f == _frequency
                                                ? Colors.white
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            boxShadow: f == _frequency
                                                ? [
                                                    cssShadow(
                                                      0,
                                                      2,
                                                      8,
                                                      const Color(0x14000000),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            f,
                                            style: inter(
                                              13,
                                              weight: FontWeight.w500,
                                              color: f == _frequency
                                                  ? Brand.ink
                                                  : const Color(0xFF555555),
                                            ),
                                          ),
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
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, keyboardOpen ? 10 : 34),
                child: PillButton(
                  label: 'Launch Agent',
                  icon: FsIcons.sparkle,
                  height: 56,
                  fontSize: 16,
                  onTap: _launch,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The form sits 4 pt further in than the hero card, as in the design.
Widget _inset(Widget child) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: child);

/// Orange card with the agent's orb and editable name.
class _AgentHero extends StatelessWidget {
  const _AgentHero({required this.name, required this.description});

  final TextEditingController name;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: GradientLayers(
        layers: [
          cssGlow(const Color(0x73FFAA64), cx: 0.2, cy: 0.5, rx: 0.6, ry: 0.8),
          const CssLinearGradient(
            150,
            colors: [Color(0xFF3A0D04), Color(0xFF8E2A0C), Color(0xFFD2591D)],
            stops: [0, 0.55, 1],
          ),
        ],
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: cssRadial(
                    colors: const [
                      Color(0xFFFFD9BC),
                      Color(0xFFF08A4B),
                      Color(0xFF9A2C0C),
                    ],
                    stops: const [0, 0.45, 1],
                    cx: 0.35,
                    cy: 0.3,
                    rx: 0.955,
                    ry: 0.955,
                  ),
                  boxShadow: [
                    BoxShadow(color: glass(0.06), spreadRadius: 16),
                    BoxShadow(color: glass(0.1), spreadRadius: 8),
                  ],
                ),
                alignment: Alignment.center,
                child: const FsIcon(
                  FsIcons.plane,
                  size: 34,
                  color: Colors.white,
                  strokeWidth: 1.6,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Agent name', style: inter(12, color: glass(0.8))),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: glass(0.4))),
                      ),
                      padding: const EdgeInsets.only(top: 4, bottom: 6),
                      child: Semantics(
                        label: 'Agent name',
                        textField: true,
                        child: TextField(
                          controller: name,
                          cursorColor: Colors.white,
                          style: inter(
                            20,
                            weight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(description, style: inter(12, color: glass(0.85))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

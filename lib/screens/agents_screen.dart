import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../models/ai.dart';
import '../router.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/floating_nav.dart';
import '../widgets/fs_icon.dart';
import '../widgets/gradients.dart';

/// 10 AI Agents: every agent with an on/off switch. Tapping a card opens
/// the screen that agent works on.
class AgentsScreen extends StatelessWidget {
  const AgentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final shift = context.topShift;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: TabChrome(
          active: NavTab.agents,
          fadeHeight: 100,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(34),
                ),
                child: GradientLayers(
                  layers: [
                    cssGlow(
                      const Color(0x73FFAA64),
                      cx: 0.85,
                      cy: 0.3,
                      rx: 0.7,
                      ry: 0.6,
                    ),
                    const CssLinearGradient(
                      180,
                      colors: [
                        Color(0xFF3A0D04),
                        Color(0xFF8E2A0C),
                        Color(0xFFD2591D),
                      ],
                      stops: [0, 0.5, 1],
                    ),
                  ],
                  child: SizedBox(
                    height: 292 + shift,
                    child: Stack(
                      children: [
                        Positioned(
                          top: -40 + shift,
                          right: -60,
                          child: Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: glass(0.16)),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10 + shift,
                          right: -10,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: glass(0.22)),
                              gradient: cssGlow(
                                const Color(0x40FFC896),
                                cx: 0.5,
                                cy: 0.5,
                                rx: 0.707,
                                ry: 0.707,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 54 + shift,
                          left: 20,
                          right: 20,
                          child: Row(
                            children: [
                              GlassIconButton(
                                icon: FsIcons.chevronLeft,
                                label: 'Back',
                                onTap: () => AppRouter.back(context),
                              ),
                              const Spacer(),
                              Tappable(
                                onTap: () =>
                                    Navigator.of(context)
                                        .pushNamed(Routes.assistant),
                                child: Glass(
                                  height: 40,
                                  radius: 20,
                                  fill: 0.14,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 6,
                                    children: [
                                      const FsIcon(
                                        FsIcons.chat,
                                        size: 14,
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                      Text(
                                        'Ask AI',
                                        style: inter(
                                          13,
                                          weight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 122 + shift,
                          left: 22,
                          right: 22,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                header: true,
                                child: Text(
                                  'Your AI Agents',
                                  style: inter(
                                    32,
                                    weight: FontWeight.w500,
                                    spacing: -1.1,
                                    height: 1.1,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${state.activeAgents} active · ${state.data.tasksAutomated} tasks automated this month',
                                style: inter(14, color: glass(0.85)),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          child: PillButton(
                            label: 'Create Custom Agent',
                            icon: FsIcons.plus,
                            style: PillStyle.light,
                            height: 52,
                            onTap: () =>
                                Navigator.of(context)
                                    .pushNamed(Routes.createAgent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 132,
                  shrinkWrap: true,
                  primary: false,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final agent in state.agents) _AgentCard(agent: agent),
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

class _AgentCard extends StatelessWidget {
  const _AgentCard({required this.agent});

  final Agent agent;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.read(context);
    final route = agent.route;
    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: agent.tile,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: FsIcon(
                  FsIcons.byName(agent.icon),
                  size: 18,
                  strokeWidth: 1.9,
                  color: agent.ink,
                ),
              ),
              const Spacer(),
              _Toggle(
                on: agent.enabled,
                label: 'Toggle ${agent.name}',
                onTap: () => state.toggleAgent(agent.id),
              ),
            ],
          ),
          const Spacer(),
          Text(agent.name, style: inter(14, weight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
            agent.enabled ? agent.status : agent.pausedStatus,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: inter(12, color: Brand.muted),
          ),
        ],
      ),
    );
    if (route == null) return card;
    return Tappable(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: card,
    );
  }
}

/// iOS-style switch drawn to the design's 44 × 26 spec.
class _Toggle extends StatelessWidget {
  const _Toggle({required this.on, required this.label, required this.onTap});

  final bool on;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: on,
      label: label,
      button: true,
      excludeSemantics: true,
      // Grow the hit area to 44 pt tall while drawing at the design's spot.
      child: Transform.translate(
        offset: const Offset(0, -9),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44,
              height: 26,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: on ? Brand.ink : Brand.toggleOff,
                borderRadius: BorderRadius.circular(13),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: on ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

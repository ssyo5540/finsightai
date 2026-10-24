import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../models/finance.dart';
import '../router.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/fs_icon.dart';
import '../widgets/gradients.dart';
import '../widgets/sheets.dart';

/// 08 Savings Goals: the featured goal's ring and the other goals below.
/// Tapping another goal features it.
class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  Future<void> _addMoney(BuildContext context, SavingsGoal goal) async {
    final amount = await showFinSightSheet<double>(
      context,
      AddMoneySheet(goalName: goal.name),
    );
    if (amount == null || !context.mounted) return;
    AppScope.read(context).addToGoal(goal.id, amount);
    showToast(context, '${money(amount)} added to ${goal.name}');
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final goal = state.featuredGoal;
    final others = state.otherGoals;
    final othersSaved = others.fold<double>(0, (sum, g) => sum + g.saved);
    final shift = context.topShift;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: GradientLayers(
          layers: [
            cssGlow(
              const Color(0x6BFFA05F),
              cx: 0.5,
              cy: 0.28,
              rx: 0.7,
              ry: 0.35,
            ),
            const CssLinearGradient(
              180,
              colors: [
                Color(0xFF3A0D04),
                Brand.oxblood,
                Color(0xFFC24B17),
                Color(0xFFE57A36),
              ],
              stops: [0, 0.3, 0.6, 1],
            ),
          ],
          child: Stack(
            children: [
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
                    Expanded(
                      child: Text(
                        'Savings Goals',
                        textAlign: TextAlign.center,
                        style: inter(
                          17,
                          weight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GlassIconButton(
                      icon: FsIcons.plus,
                      label: 'New goal',
                      onTap: () => showToast(
                        context,
                        'Creating goals is coming after the MVP.',
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 120 + shift,
                left: 0,
                right: 0,
                child: Center(child: _GoalRing(goal: goal)),
              ),
              Positioned(
                top: 360 + shift,
                left: 20,
                right: 20,
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: _GoalStat(
                        label: 'Monthly',
                        value: money(goal.monthly, cents: false),
                      ),
                    ),
                    Expanded(
                      child: _GoalStat(
                        label: 'Target date',
                        value: goal.targetDate,
                      ),
                    ),
                    Expanded(
                      child: _GoalStat(label: 'Status', value: goal.status),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TipBanner(
                        icon: FsIcons.sparkle,
                        title: 'Savings Agent tip',
                        body: goal.tip,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: SectionHeader(
                          title: 'Other goals',
                          titleSize: 18,
                          trailing: '${money(othersSaved, cents: false)} saved',
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (final (i, g) in others.indexed)
                        Tappable(
                          onTap: () => state.featureGoal(g.id),
                          child: _GoalRow(
                            goal: g,
                            last: i == others.length - 1,
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: PillButton(
                              label: 'Add Money',
                              height: 52,
                              onTap: () => _addMoney(context, goal),
                            ),
                          ),
                          const SizedBox(width: 10),
                          RoundButton(
                            icon: FsIcons.arrowRight,
                            label: 'Next goal',
                            onTap: state.featureNextGoal,
                          ),
                        ],
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

class _GoalRing extends StatelessWidget {
  const _GoalRing({required this.goal});

  final SavingsGoal goal;

  @override
  Widget build(BuildContext context) {
    final percent = (goal.progress * 100).round();
    return Semantics(
      label:
          '${goal.name}: ${money(goal.saved, cents: false)} of '
          '${money(goal.target, cents: false)}, $percent percent',
      excludeSemantics: true,
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: cssConic(Colors.white, glass(0.16), goal.progress),
          boxShadow: [cssShadow(0, 24, 60, const Color(0x59320800))],
        ),
        alignment: Alignment.center,
        child: Container(
          width: 196,
          height: 196,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: cssRadial(
              colors: const [Color(0xFFB8461A), Brand.oxblood],
              stops: const [0, 1],
              cx: 0.4,
              cy: 0.3,
              rx: 0.922,
              ry: 0.922,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 2,
            children: [
              FsIcon(FsIcons.byName(goal.icon), size: 22, color: Colors.white),
              Text(goal.name, style: inter(13, color: glass(0.85))),
              Text(
                money(goal.saved, cents: false),
                style: inter(36, spacing: -1.4, color: Colors.white),
              ),
              Text(
                'of ${money(goal.target, cents: false)} · $percent%',
                style: inter(12, color: glass(0.75)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalStat extends StatelessWidget {
  const _GoalStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Glass(
      fill: 0.14,
      border: 0.26,
      radius: 18,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(label, style: inter(11, color: glass(0.85))),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: inter(16, weight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.goal, required this.last});

  final SavingsGoal goal;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Brand.hairline)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Brand.canvas,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: FsIcon(FsIcons.byName(goal.icon), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.name,
                        style: inter(14, weight: FontWeight.w500),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        text: money(goal.saved, cents: false),
                        children: [
                          TextSpan(
                            text: ' / ${compactMoney(goal.target)}',
                            style: const TextStyle(
                              color: Brand.muted,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      style: inter(14, weight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ProgressBar(value: goal.progress, highlight: goal.highlight),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

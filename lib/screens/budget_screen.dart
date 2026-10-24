import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../models/finance.dart';
import '../router.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/floating_nav.dart';
import '../widgets/fs_icon.dart';
import '../widgets/gradients.dart';

/// 06 Budgets: month gauge, the Budget Agent alert and category limits.
class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  /// Categories at or above this share of their limit are drawn as warnings.
  static const warnAt = 0.9;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final plan = state.data.budgets;
    final spent = state.monthSpent;
    final left = plan.monthlyLimit - spent;
    final tight = state.tightestBudget;
    final shift = context.topShift;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: TabChrome(
          active: NavTab.expenses,
          fadeHeight: 110,
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 54 + shift, 16, 120),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.month,
                            style: inter(13, color: Brand.muted),
                          ),
                          const SizedBox(height: 2),
                          Semantics(
                            header: true,
                            child: Text(
                              'Budgets',
                              style: inter(
                                28,
                                weight: FontWeight.w600,
                                spacing: -0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tappable(
                      label: 'New budget',
                      onTap: () => showToast(
                        context,
                        'New budget categories are coming after the MVP.',
                      ),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Brand.ink,
                        ),
                        alignment: Alignment.center,
                        child: const FsIcon(
                          FsIcons.plus,
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: GradientLayers(
                  layers: [
                    cssGlow(
                      const Color(0x73FFAA64),
                      cx: 0.5,
                      cy: 0.9,
                      rx: 0.7,
                      ry: 0.6,
                    ),
                    const CssLinearGradient(
                      160,
                      colors: [
                        Color(0xFF4A1206),
                        Brand.brick,
                        Color(0xFFDC6A2A),
                      ],
                      stops: [0, 0.5, 1],
                    ),
                  ],
                  child: SizedBox(
                    height: 230,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 26,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Semantics(
                              label:
                                  '${(spent / plan.monthlyLimit * 100).round()}% of monthly budget spent',
                              child: CustomPaint(
                                size: const Size(260, 140),
                                painter: _GaugePainter(
                                  spent / plan.monthlyLimit,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 86,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              Text(
                                'Spent of ${money(plan.monthlyLimit, cents: false)}',
                                style: inter(12, color: glass(0.85)),
                              ),
                              MoneyText(
                                spent,
                                style: inter(
                                  40,
                                  spacing: -1.6,
                                  height: 1.1,
                                  color: Colors.white,
                                ),
                                centsColor: glass(0.55),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Row(
                            spacing: 8,
                            children: [
                              Expanded(
                                child: _HeroStat(
                                  label: 'Left to spend',
                                  value: money(left),
                                ),
                              ),
                              Expanded(
                                child: _HeroStat(
                                  label: 'Safe daily spend',
                                  value:
                                      '${money(math.max(0, left) / plan.daysLeft)} · ${plan.daysLeft} days',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TipBanner(
                icon: FsIcons.alert,
                solidTile: true,
                bordered: true,
                title:
                    'Budget Agent: ${tight.shortName} at ${(tight.progress * 100).round()}%',
                body: tight.left >= 0
                    ? '${money(tight.left, cents: false)} left for ${plan.daysLeft} days. ${plan.agentAdvice}'
                    : '${money(-tight.left, cents: false)} over with ${plan.daysLeft} days left. Ask FinSight AI to rebalance.',
                onTap: () => Navigator.of(context).pushNamed(Routes.assistant),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    for (final (i, b) in state.budgets.indexed)
                      _BudgetRow(
                        budget: b,
                        last: i == state.budgets.length - 1,
                      ),
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

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: glass(0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: glass(0.26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: inter(11, color: glass(0.85))),
          Text(
            value,
            style: inter(15, weight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.budget, required this.last});

  final BudgetCategory budget;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final warn = budget.progress >= BudgetScreen.warnAt;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Brand.hairline)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  budget.name,
                  style: inter(14, weight: FontWeight.w500),
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: money(budget.spent, cents: false),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: warn ? Brand.rust : Brand.ink,
                      ),
                    ),
                    TextSpan(
                      text: ' / ${money(budget.limit, cents: false)}',
                      style: const TextStyle(color: Brand.muted),
                    ),
                  ],
                ),
                style: inter(14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ProgressBar(value: budget.progress, highlight: warn),
        ],
      ),
    );
  }
}

/// The half-ring gauge: a 110 pt arc with round caps.
class _GaugePainter extends CustomPainter {
  _GaugePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: const Offset(130, 130), radius: 110);
    Paint stroke(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, stroke(glass(0.18)));
    canvas.drawArc(
      rect,
      math.pi,
      math.pi * progress.clamp(0.0, 1.0),
      false,
      stroke(Colors.white),
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.progress != progress;
}

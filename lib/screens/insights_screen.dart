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

/// 09 AI Insights: health score, weekly spend and the agents' findings.
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final insights = state.data.insights;
    final shift = context.topShift;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: TabChrome(
          active: NavTab.insights,
          fadeHeight: 100,
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
                            insights.updatedLabel,
                            style: inter(13, color: Brand.muted),
                          ),
                          const SizedBox(height: 2),
                          Semantics(
                            header: true,
                            child: Text(
                              'AI Insights',
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
                      label: 'Ask FinSight AI',
                      onTap: () =>
                          Navigator.of(context).pushNamed(Routes.assistant),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: CssLinearGradient(
                            135,
                            colors: [Brand.ember, Brand.oxblood],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const FsIcon(
                          FsIcons.sparkles,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _HealthCard(insights: insights),
              const SizedBox(height: 14),
              Tappable(
                onTap: () => Navigator.of(context).pushNamed(Routes.cardPicker),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Brand.ink,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              insights.missedLabel,
                              style: inter(12, color: glass(0.7)),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x40E8601C),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              insights.missedAgent,
                              style: inter(11, color: Brand.apricot),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      MoneyText(
                        insights.missedAmount,
                        style: inter(
                          28,
                          weight: FontWeight.w500,
                          spacing: -1,
                          color: Colors.white,
                        ),
                        centsColor: glass(0.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        insights.missedBody,
                        style: inter(13, color: glass(0.8)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 10,
                  children: [
                    for (final h in insights.highlights)
                      Expanded(child: _HighlightCard(highlight: h)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
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
                      child: FsIcon(
                        FsIcons.byName(insights.suggestionIcon),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insights.suggestionTitle,
                            style: inter(14, weight: FontWeight.w600),
                          ),
                          Text(
                            state.suggestionApplied
                                ? insights.suggestionAppliedBody
                                : insights.suggestionBody,
                            style: inter(12, color: Brand.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Tappable(
                      onTap: state.suggestionApplied
                          ? null
                          : state.applySuggestion,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: state.suggestionApplied
                              ? Brand.greenTint
                              : Brand.ink,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          state.suggestionApplied ? 'Applied' : 'Apply',
                          style: inter(
                            12,
                            weight: FontWeight.w600,
                            color: state.suggestionApplied
                                ? Brand.green
                                : Colors.white,
                          ),
                        ),
                      ),
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

class _HealthCard extends StatelessWidget {
  const _HealthCard({required this.insights});

  final InsightsData insights;

  @override
  Widget build(BuildContext context) {
    final peak = insights.weekSpend
        .map((d) => d.amount)
        .reduce((a, b) => a > b ? a : b);
    final peakIndex = insights.weekSpend.indexWhere((d) => d.amount == peak);
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: GradientLayers(
        layers: [
          cssGlow(const Color(0x66FFAA64), cx: 0.8, cy: 0.2, rx: 0.7, ry: 0.6),
          const CssLinearGradient(
            160,
            colors: [Color(0xFF4A1206), Brand.brick, Color(0xFFDC6A2A)],
            stops: [0, 0.55, 1],
          ),
        ],
        child: SizedBox(
          height: 238,
          child: Stack(
            children: [
              Positioned(
                top: 18,
                left: 18,
                right: 18,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Financial health score',
                            style: inter(12, color: glass(0.85)),
                          ),
                          const SizedBox(height: 2),
                          Text.rich(
                            TextSpan(
                              text: '${insights.healthScore}',
                              children: [
                                TextSpan(
                                  text: ' / 100',
                                  style: inter(
                                    24,
                                    color: glass(0.55),
                                    spacing: -1.6,
                                  ),
                                ),
                              ],
                            ),
                            style: inter(
                              44,
                              spacing: -1.6,
                              height: 1.05,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: glass(0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: glass(0.28)),
                      ),
                      child: Text(
                        insights.healthDelta,
                        style: inter(12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 16,
                height: 108,
                child: Semantics(
                  label:
                      'Daily spending this week, highest on day ${peakIndex + 1}',
                  excludeSemantics: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 10,
                    children: [
                      for (final (i, d) in insights.weekSpend.indexed)
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            spacing: 6,
                            children: [
                              Container(
                                height: 88 * d.amount / peak,
                                decoration: BoxDecoration(
                                  color: i == peakIndex
                                      ? Colors.white
                                      : glass(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              Text(
                                d.day,
                                style: i == peakIndex
                                    ? inter(
                                        10,
                                        weight: FontWeight.w600,
                                        color: Colors.white,
                                      )
                                    : inter(10, color: glass(0.8)),
                              ),
                            ],
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

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.highlight});

  final InsightHighlight highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: highlight.positive ? Brand.greenTint : Brand.peach,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: FsIcon(
              FsIcons.byName(highlight.icon),
              size: 16,
              strokeWidth: 2,
              color: highlight.positive ? Brand.green : Brand.rust,
            ),
          ),
          const SizedBox(height: 10),
          Text(highlight.title, style: inter(14, weight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
            highlight.body,
            style: inter(12, color: Brand.muted, height: 1.4),
          ),
        ],
      ),
    );
  }
}

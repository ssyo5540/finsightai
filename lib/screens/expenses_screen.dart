import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../models/finance.dart';
import '../router.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/fs_icon.dart';
import '../widgets/gradients.dart';
import '../widgets/sheets.dart';

/// Where each category's bubble sits on the 390 pt artboard and how big
/// its text is. The largest category gets the highlighted ring.
class _BubbleSpec {
  const _BubbleSpec(
    this.left,
    this.top,
    this.size,
    this.iconSize,
    this.labelSize,
    this.valueSize,
  );

  final double left;
  final double top;
  final double size;
  final double iconSize;
  final double labelSize;
  final double valueSize;
}

const _bubbles = {
  'clothes': _BubbleSpec(14, 104, 150, 20, 12, 15),
  'health': _BubbleSpec(210, 100, 106, 18, 11, 14),
  'sport': _BubbleSpec(20, 268, 96, 18, 11, 14),
  'groceries': _BubbleSpec(132, 220, 170, 22, 13, 18),
  'cafes': _BubbleSpec(14, 386, 136, 20, 11, 15),
  'bills': _BubbleSpec(176, 410, 80, 16, 11, 13),
  'travel': _BubbleSpec(284, 420, 90, 16, 11, 13),
};

/// 05 Expense Tracker: category bubbles sized by share of spending.
class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final summary = state.data.expenses;
    final categories = state.expenseCategories;
    final total = state.monthSpent;
    final byAmount = [...categories]
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final largest = byAmount.first.id;
    final change = 1 - total / summary.previousMonthTotal;
    final shift = context.topShift;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: GradientLayers(
          layers: [
            cssGlow(
              const Color(0x59FF9650),
              cx: 0.6,
              cy: 0.4,
              rx: 0.6,
              ry: 0.35,
            ),
            const CssLinearGradient(
              180,
              colors: [
                Color(0xFF5E1607),
                Color(0xFF8E260B),
                Color(0xFFB23A12),
                Color(0xFFCE5A22),
              ],
              stops: [0, 0.35, 0.65, 1],
            ),
          ],
          child: Stack(
            children: [
              Positioned(
                top: 46 + shift,
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
                      child: Center(
                        child: Tappable(
                          onTap: () => showToast(
                            context,
                            'Only ${summary.month} is in this MVP.',
                          ),
                          child: Glass(
                            height: 40,
                            radius: 20,
                            fill: 0.14,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 6,
                              children: [
                                Text(
                                  summary.month,
                                  style: inter(
                                    14,
                                    weight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                const FsIcon(
                                  FsIcons.chevronDown,
                                  size: 14,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    GlassIconButton(
                      icon: FsIcons.calendar,
                      label: 'Pick dates',
                      onTap: () => showToast(
                        context,
                        'Custom date ranges are coming after the MVP.',
                      ),
                    ),
                  ],
                ),
              ),
              for (final category in categories)
                if (_bubbles[category.id] case final spec?)
                  Positioned(
                    left: context.designX(spec.left),
                    top: spec.top + shift,
                    child: _Bubble(
                      category: category,
                      spec: spec,
                      share: total == 0 ? 0 : category.amount / total,
                      highlighted: category.id == largest,
                    ),
                  ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: SectionHeader(
                          title: 'Expenses',
                          trailing: 'View All',
                          onTrailingTap: () =>
                              Navigator.of(context).pushNamed(Routes.budget),
                        ),
                      ),
                      const SizedBox(height: 12),
                      MoneyText(
                        total,
                        textAlign: TextAlign.center,
                        style: inter(
                          40,
                          weight: FontWeight.w500,
                          spacing: -1.6,
                          color: Brand.ink,
                        ),
                        centsColor: Brand.faint,
                      ),
                      Text(
                        change >= 0
                            ? '${(change * 100).round()}% less than ${summary.previousMonthName}'
                            : '${(-change * 100).round()}% more than ${summary.previousMonthName}',
                        textAlign: TextAlign.center,
                        style: inter(12, color: Brand.muted),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        spacing: 10,
                        children: [
                          for (final c in byAmount.take(2))
                            Expanded(child: _CategoryTile(category: c)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      PillButton(
                        label: 'Add Expense',
                        icon: FsIcons.plus,
                        height: 50,
                        onTap: () => openAddTransaction(context, income: false),
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

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.category,
    required this.spec,
    required this.share,
    required this.highlighted,
  });

  final ExpenseCategory category;
  final _BubbleSpec spec;
  final double share;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final percent = '${(share * 100).toStringAsFixed(1)}%';
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      spacing: category.icon == null ? 0 : 2,
      children: [
        if (category.icon != null)
          FsIcon(
            FsIcons.byName(category.icon!),
            size: spec.iconSize,
            color: Colors.white,
          ),
        Text(category.name, style: inter(spec.labelSize, color: Colors.white)),
        Text(
          percent,
          style: inter(
            spec.valueSize,
            weight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
    return Semantics(
      label: '${category.name}, $percent of spending',
      excludeSemantics: true,
      child: highlighted
          ? Container(
              width: spec.size,
              height: spec.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xB3FFD6AA)),
                gradient: cssConic(const Color(0xFFF4A35E), glass(0.14), share),
                boxShadow: [cssShadow(0, 20, 50, const Color(0x593C0A00))],
              ),
              alignment: Alignment.center,
              child: Container(
                width: spec.size - 20,
                height: spec.size - 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: cssRadial(
                    colors: const [Color(0xF2F08C46), Color(0xF2C44A16)],
                    stops: const [0, 1],
                    cx: 0.4,
                    cy: 0.35,
                    rx: 0.885,
                    ry: 0.885,
                  ),
                ),
                alignment: Alignment.center,
                child: content,
              ),
            )
          : Container(
              width: spec.size,
              height: spec.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: glass(0.32)),
                gradient: cssConic(glass(0.34), glass(0.1), share),
              ),
              alignment: Alignment.center,
              child: content,
            ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final ExpenseCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Brand.canvas,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: inter(12, color: Brand.muted),
                ),
              ),
              if (category.icon != null)
                FsIcon(
                  FsIcons.byName(category.icon!),
                  size: 16,
                  color: Brand.muted,
                ),
            ],
          ),
          const SizedBox(height: 18),
          MoneyText(
            category.amount,
            style: inter(
              20,
              weight: FontWeight.w600,
              spacing: -0.5,
              color: Brand.ink,
            ),
            centsColor: Brand.faint,
            centsStyle: inter(
              20,
              weight: FontWeight.w500,
              spacing: -0.5,
              color: Brand.faint,
            ),
          ),
        ],
      ),
    );
  }
}

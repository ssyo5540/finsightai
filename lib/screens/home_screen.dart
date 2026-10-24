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
import '../widgets/sheets.dart';

/// 02 Home: balance, quick actions, the rewards nudge and recent activity.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: TabChrome(
          active: NavTab.home,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              const _BalanceHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: _QuickAction(
                        label: 'Add Income',
                        icon: FsIcons.arrowDownLeft,
                        onTap: () => openAddTransaction(context, income: true),
                      ),
                    ),
                    _QuickAction(
                      label: 'Transfer',
                      icon: FsIcons.transfer,
                      iconOnly: true,
                      onTap: () =>
                          Navigator.of(context).pushNamed(Routes.savings),
                    ),
                    Expanded(
                      child: _QuickAction(
                        label: 'Add Expense',
                        icon: FsIcons.arrowDownRight,
                        onTap: () => openAddTransaction(context, income: false),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: TipBanner(
                  icon: FsIcons.sparkle,
                  title: state.data.overview.nudgeTitle,
                  body: state.data.overview.nudgeBody,
                  trailing: const FsIcon(
                    FsIcons.chevronRight,
                    size: 16,
                    color: Brand.rust,
                    strokeWidth: 2,
                  ),
                  onTap: () =>
                      Navigator.of(context).pushNamed(Routes.cardPicker),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: SectionHeader(
                  title: 'Recent Transactions',
                  trailing: 'View All',
                  onTrailingTap: () =>
                      Navigator.of(context).pushNamed(Routes.expenses),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: Column(
                  children: [
                    for (final t in state.transactions)
                      TransactionRow(
                        transaction: t,
                        today: state.data.overview.asOf,
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

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader();

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final user = state.user;
    final card = state.featuredCard;
    final shift = context.topShift;
    if (user == null) return SizedBox(height: 372 + shift);
    const radius = BorderRadius.vertical(bottom: Radius.circular(34));

    return ClipRRect(
      borderRadius: radius,
      child: GradientLayers(
        layers: [
          cssGlow(const Color(0x66FFA05F), cx: 0.5, cy: 0.55, rx: 0.8, ry: 0.5),
          const CssLinearGradient(
            180,
            colors: [
              Color(0xFF5A1607),
              Color(0xFF9A3010),
              Color(0xFFD2591D),
              Color(0xFFE8823F),
            ],
            stops: [0, 0.45, 0.8, 1],
          ),
        ],
        child: SizedBox(
          height: 372 + shift,
          child: Stack(
            children: [
              Positioned(
                top: 54 + shift,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    Tappable(
                      label: 'Account',
                      onTap: () => showFinSightSheet<void>(
                        context,
                        const ProfileSheet(),
                      ),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const CssLinearGradient(
                            135,
                            colors: [Color(0xFFFFD2B0), Color(0xFFF4A06A)],
                          ),
                          border: Border.all(color: glass(0.7), width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          user.initials,
                          style: inter(
                            15,
                            weight: FontWeight.w600,
                            color: const Color(0xFF6E1D08),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: inter(12, color: glass(0.8)),
                          ),
                          Text(
                            user.firstName,
                            style: inter(
                              15,
                              weight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GlassIconButton(
                      icon: FsIcons.bell,
                      label: 'Notifications',
                      badge: true,
                      onTap: () => showFinSightSheet<void>(
                        context,
                        const NotificationsSheet(),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 122 + shift,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text('Total Balance', style: inter(14, color: glass(0.85))),
                    const SizedBox(height: 6),
                    MoneyText(
                      state.totalBalance,
                      style: inter(
                        50,
                        spacing: -2,
                        height: 1,
                        color: Colors.white,
                      ),
                      centsColor: glass(0.55),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: glass(0.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: glass(0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 6,
                        children: [
                          const FsIcon(
                            FsIcons.arrowUpRight,
                            size: 12,
                            color: Colors.white,
                            strokeWidth: 2.4,
                          ),
                          Text(
                            '${state.data.overview.balanceChangePct}% this month',
                            style: inter(12, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 44,
                right: 44,
                bottom: 54,
                height: 40,
                child: _StackedCardEdge(fill: 0.12, border: 0.2),
              ),
              Positioned(
                left: 32,
                right: 32,
                bottom: 40,
                height: 44,
                child: _StackedCardEdge(fill: 0.16, border: 0.24),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: -20,
                height: 84,
                child: Tappable(
                  label: 'Open ${card.name} in wallet',
                  onTap: () => Navigator.of(context).pushNamed(Routes.wallet),
                  child: Glass(
                    fill: 0.2,
                    border: 0.35,
                    radius: 20,
                    blur: 16,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 18,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '•••• ${card.last4}    ${card.expiry}',
                            style: inter(13, spacing: 1, color: glass(0.9)),
                          ),
                        ),
                        Text(
                          card.network,
                          style: inter(
                            16,
                            weight: FontWeight.w700,
                            italic: true,
                            color: glass(0.85),
                          ),
                        ),
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

/// The edges of the cards stacked behind the featured one.
class _StackedCardEdge extends StatelessWidget {
  const _StackedCardEdge({required this.fill, required this.border});

  final double fill;
  final double border;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: glass(fill),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border.all(color: glass(border)),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconOnly = false,
  });

  final String label;
  final String icon;
  final VoidCallback onTap;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      label: iconOnly ? label : null,
      child: Container(
        height: 48,
        width: iconOnly ? 48 : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Brand.border),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            FsIcon(icon, size: 16, color: Brand.ink, strokeWidth: 2),
            if (!iconOnly)
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: inter(14, weight: FontWeight.w500, color: Brand.ink),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One row of the transaction list.
class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.transaction,
    required this.today,
  });

  final Transaction transaction;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final when = isSameDay(t.date, today)
        ? 'Today, ${clock(t.date)}'
        : '${monthDay(t.date)}, ${clock(t.date)}';
    final rewardNote = t.note.startsWith('+');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          MonogramBadge(monogram: t.avatar),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.merchant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: inter(15, weight: FontWeight.w500, color: Brand.ink),
                ),
                Text(
                  '$when · ${t.category}',
                  style: inter(12, color: Brand.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                money(t.amount, signed: true),
                style: inter(
                  15,
                  weight: FontWeight.w600,
                  color: t.isIncome ? Brand.green : Brand.ink,
                ),
              ),
              Text(
                t.note,
                style: inter(
                  11,
                  color: rewardNote && !t.isIncome ? Brand.rust : Brand.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

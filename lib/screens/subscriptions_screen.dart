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

/// 07 Subscriptions: monthly total, this week's renewals and the Subscription
/// Agent's cancel suggestion.
class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  var _showAll = false;

  Future<void> _review(Subscription subscription) async {
    final cancel = await showFinSightSheet<bool>(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Cancel ${subscription.name}?',
            style: inter(22, weight: FontWeight.w600, spacing: -0.6),
          ),
          const SizedBox(height: 6),
          Text(
            'Not used for ${subscription.lastUsedDaysAgo} days. Cancelling saves '
            '${money(subscription.price * 12)} a year. It stays active until '
            '${monthDay(subscription.renewsOn)}.',
            style: inter(14, height: 1.45, color: Brand.muted),
          ),
          const SizedBox(height: 18),
          Builder(
            builder: (context) => PillButton(
              label: 'Cancel subscription',
              height: 52,
              onTap: () => Navigator.of(context).pop(true),
            ),
          ),
          const SizedBox(height: 10),
          Builder(
            builder: (context) => PillButton(
              label: 'Keep it',
              style: PillStyle.outline,
              height: 52,
              onTap: () => Navigator.of(context).pop(false),
            ),
          ),
        ],
      ),
    );
    if (cancel != true || !mounted) return;
    AppScope.read(context).cancelSubscription(subscription.id);
    showToast(context, '${subscription.name} cancelled');
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final today = state.data.overview.asOf;
    final renewals = state.upcomingRenewals;
    final monthly = state.subscriptionsMonthly;
    final unused = state.unusedSubscription;
    final week = [for (var i = 0; i < 7; i++) today.add(Duration(days: i))];
    final nextRenewal = renewals
        .where((s) => !s.renewsOn.isBefore(today))
        .firstOrNull;
    final shown = _showAll ? renewals : renewals.take(4).toList();
    final shift = context.topShift;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: TabChrome(
          active: NavTab.expenses,
          fadeHeight: 110,
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
                      const Color(0x66FFA05F),
                      cx: 0.3,
                      cy: 0.6,
                      rx: 0.8,
                      ry: 0.5,
                    ),
                    const CssLinearGradient(
                      180,
                      colors: [
                        Color(0xFF4A1206),
                        Color(0xFF8E2A0C),
                        Color(0xFFCF561C),
                        Color(0xFFE27838),
                      ],
                      stops: [0, 0.45, 0.85, 1],
                    ),
                  ],
                  child: SizedBox(
                    height: 336 + shift,
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
                                  'Subscriptions',
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
                                label: 'Add subscription',
                                onTap: () => showToast(
                                  context,
                                  'The Subscription Agent finds new ones automatically.',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 118 + shift,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              Text(
                                'Monthly subscriptions',
                                style: inter(14, color: glass(0.85)),
                              ),
                              const SizedBox(height: 4),
                              MoneyText(
                                monthly,
                                style: inter(
                                  48,
                                  spacing: -2,
                                  height: 1.05,
                                  color: Colors.white,
                                ),
                                centsColor: glass(0.55),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${state.subscriptions.length} active · '
                                '\$${groupThousands((monthly * 12).floor())} per year',
                                style: inter(13, color: glass(0.85)),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 18,
                          child: Row(
                            spacing: 6,
                            children: [
                              for (final day in week)
                                Expanded(
                                  child: _DayTile(
                                    day: day,
                                    highlighted:
                                        nextRenewal != null &&
                                        isSameDay(nextRenewal.renewsOn, day),
                                    hasRenewal: renewals.any(
                                      (s) => isSameDay(s.renewsOn, day),
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
              ),
              if (unused != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Brand.ink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const CssLinearGradient(
                            135,
                            colors: [Brand.ember, Brand.brick],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const FsIcon(
                          FsIcons.repeat,
                          size: 18,
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${unused.name} unused for ${unused.lastUsedDaysAgo} days',
                              style: inter(
                                13,
                                weight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Cancel to save ${money(unused.price * 12)} a year',
                              style: inter(12, color: glass(0.75)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Tappable(
                        onTap: () => _review(unused),
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Review',
                            style: inter(
                              12,
                              weight: FontWeight.w600,
                              color: Brand.ink,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: SectionHeader(
                  title: 'Upcoming Renewals',
                  trailing: _showAll ? 'Show less' : 'See all',
                  onTrailingTap: () => setState(() => _showAll = !_showAll),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    for (final (i, s) in shown.indexed)
                      _RenewalRow(
                        subscription: s,
                        today: today,
                        next: identical(s, nextRenewal),
                        last: i == shown.length - 1,
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

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.highlighted,
    required this.hasRenewal,
  });

  final DateTime day;
  final bool highlighted;
  final bool hasRenewal;

  @override
  Widget build(BuildContext context) {
    final foreground = highlighted ? Brand.oxblood : Colors.white;
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: highlighted ? Colors.white : glass(0.12),
        borderRadius: BorderRadius.circular(16),
        border: highlighted ? null : Border.all(color: glass(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 2,
        children: [
          Text(
            weekdayShort(day),
            style: inter(10, color: highlighted ? foreground : glass(0.8)),
          ),
          Text(
            '${day.day}',
            style: inter(16, weight: FontWeight.w600, color: foreground),
          ),
          if (hasRenewal)
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: highlighted ? Brand.ember : Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

class _RenewalRow extends StatelessWidget {
  const _RenewalRow({
    required this.subscription,
    required this.today,
    required this.next,
    required this.last,
  });

  final Subscription subscription;
  final DateTime today;
  final bool next;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final date = subscription.renewsOn;
    final thisWeek = date.difference(today).inDays < 7;
    final when = thisWeek
        ? '${weekdayShort(date)}, ${monthDay(date)}'
        : monthDay(date);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Brand.hairline)),
      ),
      child: Row(
        children: [
          MonogramBadge(
            monogram: subscription.logo,
            radius: 12,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.name,
                  style: inter(15, weight: FontWeight.w500),
                ),
                Text(
                  next ? 'Renews $when' : when,
                  style: inter(12, color: next ? Brand.rust : Brand.muted),
                ),
              ],
            ),
          ),
          Text(
            money(subscription.price),
            style: inter(15, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

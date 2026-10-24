import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../models/cards.dart';
import '../router.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/floating_nav.dart';
import '../widgets/fs_icon.dart';
import '../widgets/gradients.dart';

/// 03 Smart Wallet: swipeable cards, credit health and the card list.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _pages = PageController();
  var _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final cards = state.data.cards;
    final stats = state.data.walletStats;
    final shift = context.topShift;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: TabChrome(
          active: NavTab.wallet,
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
                      const Color(0x73FFA05F),
                      cx: 0.7,
                      cy: 0.6,
                      rx: 0.7,
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
                    height: 330 + shift,
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
                                  'Smart Wallet',
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
                                label: 'Add card',
                                onTap: () => showToast(
                                  context,
                                  'Adding new cards is coming after the MVP.',
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Ghost of the next card peeking from the right.
                        Positioned(
                          top: 128 + shift,
                          left: context.designX(300),
                          width: 200,
                          height: 170,
                          child: Container(
                            decoration: BoxDecoration(
                              color: glass(0.12),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: glass(0.22)),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 120 + shift,
                          left: 0,
                          right: 0,
                          height: 180,
                          child: PageView(
                            controller: _pages,
                            clipBehavior: Clip.none,
                            onPageChanged: (page) =>
                                setState(() => _page = page),
                            children: [
                              for (final card in cards)
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 24),
                                    child: _WalletCard(card: card),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 14,
                          left: 0,
                          right: 0,
                          child: Semantics(
                            label: 'Card ${_page + 1} of ${cards.length}',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 6,
                              children: [
                                for (var i = 0; i < cards.length; i++)
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: i == _page ? 18 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: i == _page
                                          ? Colors.white
                                          : glass(0.45),
                                      borderRadius: BorderRadius.circular(3),
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
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: 'Credit utilization',
                        value: Text.rich(
                          TextSpan(
                            text: trimNumber(stats.utilizationPct),
                            children: const [
                              TextSpan(
                                text: '%',
                                style: TextStyle(color: Color(0xFF9A9A9A)),
                              ),
                            ],
                          ),
                          style: inter(
                            24,
                            weight: FontWeight.w500,
                            spacing: -0.8,
                          ),
                        ),
                        children: [
                          const SizedBox(height: 10),
                          ProgressBar(
                            value: stats.utilizationPct / 100,
                            gradient: const CssLinearGradient(
                              90,
                              colors: [Brand.ember, Brand.rust],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            stats.utilizationNote,
                            style: inter(11, color: Brand.green),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _StatTile(
                        label: 'Rewards balance',
                        value: Text(
                          groupThousands(stats.rewardsPoints),
                          style: inter(
                            24,
                            weight: FontWeight.w500,
                            spacing: -0.8,
                          ),
                        ),
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'points ≈ ${money(stats.rewardsValue)}',
                            style: inter(12, color: Brand.muted),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '+${groupThousands(stats.rewardsThisMonth)} this month',
                            style: inter(11, color: Brand.rust),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: SectionHeader(
                  title: 'All Cards',
                  trailing: '${cards.length} cards',
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
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
                    for (var i = 0; i < cards.length; i++)
                      Tappable(
                        onTap: () {
                          _pages.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                        child: _CardRow(
                          card: cards[i],
                          last: i == cards.length - 1,
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

class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.card});

  final PaymentCard card;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 290,
      height: 180,
      child: CardFace(
        card: card,
        radius: 22,
        accentRight: -40,
        accentTop: -30,
        accentWidth: 170,
        accentHeight: 240,
        shadows: [cssShadow(0, 24, 50, const Color(0x80280600))],
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      card.name,
                      style: inter(
                        13,
                        weight: FontWeight.w600,
                        color: glass(0.9),
                      ),
                    ),
                  ),
                  Tappable(
                    onTap: () => Navigator.of(context).pushNamed(
                      Routes.pay,
                      arguments: PayArgs(cardId: card.id),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 5,
                        children: [
                          const FsIcon(
                            FsIcons.contactless,
                            size: 12,
                            color: Brand.ink,
                            strokeWidth: 2.4,
                          ),
                          Text(
                            'Tap to Pay',
                            style: inter(
                              12,
                              weight: FontWeight.w600,
                              color: Brand.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const CardChip(width: 38, height: 28, radius: 6),
              const SizedBox(height: 20),
              Text(
                '•••• •••• •••• ${card.last4}',
                style: inter(15, spacing: 2, color: glass(0.85)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      card.expiry,
                      style: inter(12, color: glass(0.7)),
                    ),
                  ),
                  Text(
                    card.network,
                    style: inter(
                      17,
                      weight: FontWeight.w700,
                      italic: true,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.children,
  });

  final String label;
  final Widget value;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: inter(12, color: Brand.muted)),
          const SizedBox(height: 6),
          value,
          ...children,
        ],
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({required this.card, required this.last});

  final PaymentCard card;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Brand.hairline)),
      ),
      child: Row(
        children: [
          CardThumb(card: card),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${card.name} · ${card.last4}',
                  style: inter(14, weight: FontWeight.w500),
                ),
                Text(card.perks, style: inter(12, color: Brand.muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                money(card.balance, cents: false),
                style: inter(14, weight: FontWeight.w600),
              ),
              Text(
                card.limit == null
                    ? 'available'
                    : 'of ${money(card.limit!, cents: false)}',
                style: inter(11, color: Brand.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

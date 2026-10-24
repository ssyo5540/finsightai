import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../models/cards.dart';
import '../router.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/fs_icon.dart';
import '../widgets/gradients.dart';

/// 04 AI Best Card Picker: ranks your credit cards for the purchase.
class CardPickerScreen extends StatefulWidget {
  const CardPickerScreen({super.key});

  @override
  State<CardPickerScreen> createState() => _CardPickerScreenState();
}

class _CardPickerScreenState extends State<CardPickerScreen> {
  late final TextEditingController _merchant;
  late String _category;

  @override
  void initState() {
    super.initState();
    final payment = AppScope.read(context).data.payment;
    _merchant = TextEditingController(
      text: '${payment.merchant} · ${payment.merchantType}',
    );
    _category = payment.rewardCategory;
  }

  @override
  void dispose() {
    _merchant.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final payment = state.data.payment;
    final pointValue = state.data.walletStats.pointValue;
    final amount = payment.amount;
    final quotes = rankCards(
      state.data.cards.where((c) => c.isCredit),
      _category,
      amount,
      pointValue,
    );
    final best = quotes.first;
    final debit = state.data.cards.where((c) => !c.isCredit).firstOrNull;
    final debitValue = debit == null
        ? 0.0
        : RewardQuote.of(debit, _category, amount, pointValue).value;
    final noun = payment.categoryById(_category).noun;
    final perk = best.card.rewardType == RewardType.cashback
        ? '${best.card.rateLabel(_category)} cashback on $noun'
        : '${best.card.rateLabel(_category)} points on $noun';
    final earned = best.card.rewardType == RewardType.points
        ? '${groupThousands(best.points)} points'
        : '${money(best.value)} cashback';
    final pinned = state.pinnedCards[_category] == best.card.id;
    final shift = context.topShift;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: GradientLayers(
            layers: [
              cssGlow(
                const Color(0x66FFA05F),
                cx: 0.5,
                cy: 0.3,
                rx: 0.8,
                ry: 0.4,
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
                          'Best Card Picker',
                          textAlign: TextAlign.center,
                          style: inter(
                            17,
                            weight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      GlassIconButton(
                        icon: FsIcons.scan,
                        label: 'Scan receipt',
                        onTap: () => showToast(
                          context,
                          'Receipt scanning arrives with the camera release.',
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 116 + shift,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Where are you paying?',
                        style: inter(12, color: glass(0.8)),
                      ),
                      const SizedBox(height: 8),
                      Glass(
                        height: 52,
                        radius: 26,
                        blur: 14,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          children: [
                            const FsIcon(
                              FsIcons.search,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Semantics(
                                label: 'Where are you paying?',
                                textField: true,
                                child: TextField(
                                  controller: _merchant,
                                  cursorColor: Colors.white,
                                  style: inter(
                                    15,
                                    weight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              money(amount),
                              style: inter(
                                15,
                                weight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        spacing: 6,
                        children: [
                          for (final c in payment.rewardCategories)
                            _CategoryChip(
                              label: c.label,
                              selected: c.id == _category,
                              onTap: () => setState(() => _category = c.id),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 262 + shift,
                  left: 20,
                  right: 20,
                  child: Glass(
                    fill: 0.14,
                    border: 0.3,
                    radius: 26,
                    blur: 18,
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        _MiniCard(card: best.card),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: glass(0.22),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 5,
                                  children: [
                                    const FsIcon(
                                      FsIcons.sparkle,
                                      size: 11,
                                      color: Colors.white,
                                      strokeWidth: 2.2,
                                    ),
                                    Text(
                                      'AI Recommended',
                                      style: inter(11, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                best.card.name,
                                style: inter(
                                  20,
                                  weight: FontWeight.w600,
                                  spacing: -0.4,
                                  color: Colors.white,
                                ),
                              ),
                              Text(perk, style: inter(13, color: glass(0.85))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 386 + shift,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text("You'll earn", style: inter(13, color: glass(0.85))),
                      MoneyText(
                        best.value,
                        style: inter(
                          46,
                          spacing: -1.8,
                          height: 1.1,
                          color: Colors.white,
                        ),
                        centsColor: glass(0.55),
                      ),
                      Text(
                        '$earned · ${money(best.value - debitValue)} more than your debit card',
                        style: inter(12, color: glass(0.85)),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: Text(
                                'Compare your cards',
                                style: inter(
                                  17,
                                  weight: FontWeight.w600,
                                  spacing: -0.3,
                                ),
                              ),
                            ),
                            Text(
                              'for ${money(amount)}',
                              style: inter(12, color: Brand.muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        for (final (i, quote) in quotes.indexed) ...[
                          if (i > 0) const SizedBox(height: 6),
                          _CompareRow(
                            quote: quote,
                            category: _category,
                            best: i == 0,
                          ),
                        ],
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: PillButton(
                                label: 'Pay with ${best.card.name}',
                                onTap: () => Navigator.of(context).pushNamed(
                                  Routes.pay,
                                  arguments: PayArgs(cardId: best.card.id),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            RoundButton(
                              icon: FsIcons.bookmark,
                              label:
                                  'Set as default for ${payment.categoryById(_category).label.toLowerCase()}',
                              size: 54,
                              selected: pinned,
                              onTap: () {
                                state.togglePinnedCard(_category, best.card.id);
                                final label = payment
                                    .categoryById(_category)
                                    .label;
                                showToast(
                                  context,
                                  pinned
                                      ? '${best.card.name} is no longer your $label default'
                                      : '${best.card.name} set as default for $label',
                                );
                              },
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
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      selected: selected,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : glass(0.14),
          borderRadius: BorderRadius.circular(16),
          border: selected ? null : Border.all(color: glass(0.25)),
        ),
        child: Text(
          label,
          style: selected
              ? inter(12, weight: FontWeight.w600, color: Brand.oxblood)
              : inter(12, color: Colors.white),
        ),
      ),
    );
  }
}

/// 112 × 72 rendering of the recommended card.
class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.card});

  final PaymentCard card;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 72,
      child: CardFace(
        card: card,
        radius: 12,
        accentRight: -16,
        accentTop: -10,
        accentWidth: 64,
        accentHeight: 100,
        accentOpacity: 1,
        shadows: [cssShadow(0, 12, 24, const Color(0x66280600))],
        child: Stack(
          children: [
            const Positioned(
              top: 12,
              left: 12,
              child: CardChip(width: 18, height: 14, radius: 3),
            ),
            Positioned(
              bottom: 8,
              right: 10,
              child: Text(
                card.network,
                style: inter(
                  10,
                  weight: FontWeight.w700,
                  italic: true,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.quote,
    required this.category,
    required this.best,
  });

  final RewardQuote quote;
  final String category;
  final bool best;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: best ? Brand.peach : Brand.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: best ? Brand.peachBorder : Brand.canvas),
      ),
      child: Row(
        children: [
          CardThumb(card: quote.card, width: 36, height: 24, radius: 5),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              quote.card.name,
              style: inter(14, weight: FontWeight.w500),
            ),
          ),
          Text(
            quote.card.rateLabel(category),
            style: inter(12, color: best ? Brand.mutedWarm : Brand.muted),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 58,
            child: Text(
              money(quote.value),
              textAlign: TextAlign.right,
              style: inter(
                14,
                weight: FontWeight.w600,
                color: best ? Brand.rust : Brand.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

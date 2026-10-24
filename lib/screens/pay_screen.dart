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

/// 03a Tap to Pay: the chosen card, what it earns here, and the other cards
/// stacked below to switch to.
class PayScreen extends StatefulWidget {
  const PayScreen({super.key, required this.args});

  final PayArgs args;

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  String? _selectedId;
  var _paying = false;

  Future<void> _pay(PaymentCard card) async {
    setState(() => _paying = true);
    // Stand-in for the Face ID prompt and the terminal handshake.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final receipt = AppScope.read(context).completePayment(card);
    Navigator.of(context)
        .pushReplacementNamed(Routes.payDone, arguments: receipt);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final payment = state.data.payment;
    final ranked = rankCards(
      state.data.cards,
      payment.rewardCategory,
      payment.amount,
      state.data.walletStats.pointValue,
    );
    final best = ranked.first;
    final selectedId = _selectedId ?? widget.args.cardId ?? best.card.id;
    final selected = ranked.firstWhere((q) => q.card.id == selectedId);
    final others = state.data.cards.where((c) => c.id != selectedId).toList();
    final shift = context.topShift;
    final (headline, reward) = _describe(
      selected,
      best,
      payment.rewardCategory,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: GradientLayers(
          layers: [
            cssGlow(
              const Color(0x59FF8C46),
              cx: 0.5,
              cy: 0.62,
              rx: 0.8,
              ry: 0.4,
            ),
            const CssLinearGradient(
              180,
              colors: [
                Color(0xFF1A0602),
                Color(0xFF4A1206),
                Color(0xFF8E2A0C),
                Color(0xFFC24B17),
              ],
              stops: [0, 0.35, 0.7, 1],
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
                      icon: FsIcons.close,
                      label: 'Close',
                      iconSize: 18,
                      strokeWidth: 2,
                      fill: 0.1,
                      border: 0.25,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            payment.merchant,
                            style: inter(
                              16,
                              weight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${payment.merchantType} · detected nearby',
                            style: inter(12, color: glass(0.75)),
                          ),
                        ],
                      ),
                    ),
                    const GlassIconButton(
                      icon: FsIcons.pin,
                      label: 'Location',
                      iconSize: 18,
                      fill: 0.1,
                      border: 0.25,
                      onTap: null,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 120 + shift,
                left: 24,
                right: 24,
                height: 214,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _BigCard(
                    key: ValueKey(selected.card.id),
                    card: selected.card,
                  ),
                ),
              ),
              Positioned(
                top: 350 + shift,
                left: 24,
                right: 24,
                child: Glass(
                  fill: 0.12,
                  border: 0.24,
                  radius: 18,
                  blur: 14,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          color: selected == best
                              ? null
                              : const Color(0xFF5A5A5A),
                          gradient: selected == best
                              ? const CssLinearGradient(
                                  135,
                                  colors: [Brand.ember, Brand.brick],
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: const FsIcon(
                          FsIcons.sparkle,
                          size: 16,
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
                              headline,
                              style: inter(
                                13,
                                weight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(reward, style: inter(12, color: glass(0.8))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 438 + shift,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    const _ContactlessPulse(),
                    const SizedBox(height: 14),
                    Text(
                      'Hold Near Reader',
                      style: inter(
                        20,
                        weight: FontWeight.w500,
                        spacing: -0.4,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${money(payment.amount)} · tap a card below to switch',
                      style: inter(13, color: glass(0.75)),
                    ),
                  ],
                ),
              ),
              for (final (i, card) in others.indexed)
                Positioned(
                  top: 604 + shift + i * 30,
                  left: 24,
                  right: 24,
                  height: 120,
                  child: Tappable(
                    label: 'Switch to ${card.name}',
                    onTap: _paying
                        ? null
                        : () => setState(() => _selectedId = card.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: CssLinearGradient(
                          135,
                          colors: card.art.background,
                          stops: const [0, 0.6],
                        ),
                        boxShadow: [
                          cssShadow(0, -6, 18, const Color(0x4D000000)),
                        ],
                      ),
                      alignment: Alignment.topCenter,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              card.name,
                              style: inter(
                                13,
                                weight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            '•••• ${card.last4}',
                            style: inter(
                              13,
                              weight: FontWeight.w500,
                              color: glass(0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 150,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: CssLinearGradient(
                        180,
                        colors: [Color(0x00C24B17), Color(0xFFB8461A)],
                        stops: [0, 0.5],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 34,
                child: PillButton(
                  label: _paying
                      ? 'Confirming with Face ID…'
                      : 'Pay ${money(payment.amount)} with Face ID',
                  icon: FsIcons.faceId,
                  iconSize: 22,
                  style: PillStyle.light,
                  height: 58,
                  fontSize: 16,
                  busy: _paying,
                  onTap: () => _pay(selected.card),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Headline and reward line for the selected card, relative to the best.
  (String, String) _describe(
    RewardQuote selected,
    RewardQuote best,
    String category,
  ) {
    final card = selected.card;
    final rate = card.rateLabel(category);
    if (card.rewardType == RewardType.none) {
      return (
        'No rewards on this card',
        'You miss ${money(best.value)} by paying with debit',
      );
    }
    final reward = card.rewardType == RewardType.points
        ? identical(selected, best)
              ? '$rate points · +${groupThousands(selected.points)} pts ≈ ${money(selected.value)} back'
              : '$rate points · ≈ ${money(selected.value)} back'
        : '$rate cashback · ${money(selected.value)} back';
    if (identical(selected, best)) return ('AI picked your best card', reward);
    return (
      'You lose ${money(best.value - selected.value)} vs ${best.card.name}',
      reward,
    );
  }
}

/// 342 × 214 card face shown while paying.
class _BigCard extends StatelessWidget {
  const _BigCard({super.key, required this.card});

  final PaymentCard card;

  @override
  Widget build(BuildContext context) {
    return CardFace(
      card: card,
      radius: 22,
      accentRight: -40,
      accentTop: -30,
      accentWidth: 190,
      accentHeight: 290,
      shadows: [cssShadow(0, 30, 60, const Color(0x80000000))],
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
                      15,
                      weight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                FsIcon(
                  FsIcons.contactless,
                  size: 22,
                  color: glass(0.9),
                  strokeWidth: 2,
                ),
              ],
            ),
            const SizedBox(height: 22),
            const CardChip(width: 42, height: 32, radius: 7),
            const SizedBox(height: 26),
            Text(
              '•••• •••• •••• ${card.last4}',
              style: inter(16, spacing: 2, color: glass(0.88)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    card.kindLabel,
                    style: inter(12, color: glass(0.7)),
                  ),
                ),
                Text(
                  card.network,
                  style: inter(
                    18,
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
    );
  }
}

/// Contactless glyph with two rings pulsing outwards (CSS `fsPulse`).
class _ContactlessPulse extends StatefulWidget {
  const _ContactlessPulse();

  @override
  State<_ContactlessPulse> createState() => _ContactlessPulseState();
}

class _ContactlessPulseState extends State<_ContactlessPulse>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _ring(double phase) {
    final t = Curves.easeOut.transform((_controller.value + phase) % 1);
    return Transform.scale(
      scale: 0.7 + 0.8 * t,
      child: Opacity(
        opacity: 0.7 * (1 - t),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: glass(0.6), width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: _ring(0)),
            Positioned.fill(child: _ring(0.5)),
            child!,
          ],
        ),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: glass(0.16),
            border: Border.all(color: glass(0.35)),
          ),
          alignment: Alignment.center,
          child: const FsIcon(
            FsIcons.contactlessWide,
            size: 28,
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

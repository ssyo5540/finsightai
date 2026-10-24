import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/cards.dart';
import '../models/payment.dart';
import '../router.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/fs_icon.dart';
import '../widgets/gradients.dart';

/// 03b Payment Complete: amount, rewards earned and the budget follow-up.
class PayDoneScreen extends StatelessWidget {
  const PayDoneScreen({super.key, required this.receipt});

  final PaymentReceipt receipt;

  @override
  Widget build(BuildContext context) {
    final shift = context.topShift;
    final quote = receipt.quote;
    final card = quote.card;
    final earned = switch (card.rewardType) {
      RewardType.points =>
        '+${groupThousands(quote.points)} points with ${card.name}',
      RewardType.cashback =>
        '+${money(quote.value)} cashback with ${card.name}',
      RewardType.none => 'No rewards with ${card.name}',
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: GradientLayers(
          layers: [
            cssGlow(
              const Color(0x73FFA05F),
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
              _centered(
                top: 120 + shift,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: glass(0.14)),
                  ),
                ),
              ),
              _centered(
                top: 160 + shift,
                child: Container(
                  width: 180,
                  height: 180,
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
              _centered(
                top: 200 + shift,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [cssShadow(0, 20, 50, const Color(0x663C0A00))],
                  ),
                  alignment: Alignment.center,
                  child: const FsIcon(
                    FsIcons.check,
                    size: 44,
                    color: Brand.rust,
                    strokeWidth: 2.4,
                  ),
                ),
              ),
              Positioned(
                top: 400 + shift,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'Paid at ${receipt.merchant}',
                      style: inter(15, color: glass(0.85)),
                    ),
                    const SizedBox(height: 4),
                    MoneyText(
                      receipt.amount,
                      style: inter(
                        52,
                        spacing: -2,
                        height: 1.05,
                        color: Colors.white,
                      ),
                      centsColor: glass(0.55),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: glass(0.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: glass(0.28)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 6,
                        children: [
                          const FsIcon(
                            FsIcons.sparkle,
                            size: 13,
                            color: Colors.white,
                            strokeWidth: 2.2,
                          ),
                          Text(earned, style: inter(13, color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DetailRow(
                        label: 'Card',
                        value: '${card.name} · ${card.last4}',
                      ),
                      _DetailRow(
                        label: 'Category',
                        value: receipt.categoryName,
                      ),
                      _DetailRow(
                        label: 'Rewards value',
                        value: money(quote.value),
                        accent: true,
                        last: true,
                      ),
                      const SizedBox(height: 8),
                      TipBanner(
                        icon: FsIcons.pie,
                        iconTile: 34,
                        iconSize: 16,
                        solidTile: true,
                        title:
                            '${receipt.budgetName} budget now at '
                            '${(receipt.budgetProgress * 100).round()}%',
                        body: receipt.budgetOffer,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: PillButton(
                              label: 'Done',
                              onTap: () => Navigator.of(context).popUntil(
                                (r) =>
                                    r.settings.name == Routes.home || r.isFirst,
                              ),
                            ),
                          ),
                          Expanded(
                            child: PillButton(
                              label: 'Adjust budget',
                              style: PillStyle.outline,
                              onTap: () => Navigator.of(context)
                                  .pushNamedAndRemoveUntil(
                                    Routes.budget,
                                    (r) =>
                                        r.settings.name == Routes.home ||
                                        r.isFirst,
                                  ),
                            ),
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

  Widget _centered({required double top, required Widget child}) => Positioned(
    top: top,
    left: 0,
    right: 0,
    child: Center(child: child),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.accent = false,
    this.last = false,
  });

  final String label;
  final String value;
  final bool accent;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Brand.hairline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: inter(14, color: Brand.muted)),
          ),
          Text(
            value,
            style: inter(
              14,
              weight: accent ? FontWeight.w600 : FontWeight.w500,
              color: accent ? Brand.rust : Brand.ink,
            ),
          ),
        ],
      ),
    );
  }
}

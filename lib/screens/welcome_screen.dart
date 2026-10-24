import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../router.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/fs_icon.dart';
import '../widgets/gradients.dart';

/// 01 Welcome: brand intro with the tilted card and AI callouts.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const background = [
    CssLinearGradient(
      180,
      colors: [
        Color(0xFF2E0A03),
        Color(0xFF6E1D08),
        Color(0xFFB23F12),
        Color(0xFFE06A26),
        Color(0xFFF39A5C),
      ],
      stops: [0, 0.28, 0.58, 0.82, 1],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final shift = context.topShift;
    void start() => Navigator.of(context).pushNamed(Routes.signIn);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: GradientLayers(
          layers: [
            cssGlow(
              const Color(0x73FF9650),
              cx: 0.5,
              cy: 0.3,
              rx: 0.9,
              ry: 0.45,
            ),
            ...background,
          ],
          child: Stack(
            children: [
              Positioned(
                top: 58 + shift,
                left: 24,
                right: 24,
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: glass(0.16),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: glass(0.3)),
                      ),
                      alignment: Alignment.center,
                      child: const FsIcon(
                        FsIcons.logo,
                        size: 18,
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'FinSight',
                      style: inter(
                        18,
                        weight: FontWeight.w600,
                        spacing: -0.3,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Tappable(
                      onTap: start,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 4,
                        ),
                        child: Text(
                          'Skip',
                          style: inter(14, color: glass(0.85)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 120 + shift,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: glass(0.14)),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 165 + shift,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: glass(0.2)),
                      gradient: cssGlow(
                        const Color(0x40FFBE8C),
                        cx: 0.5,
                        cy: 0.5,
                        rx: 0.707,
                        ry: 0.707,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 205 + shift,
                left: 0,
                right: 0,
                child: const Center(child: _TiltedCard()),
              ),
              Positioned(
                top: 150 + shift,
                right: 22,
                child: _Callout(
                  leading: const FsIcon(
                    FsIcons.sparkle,
                    size: 16,
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                  gap: 8,
                  caption: 'AI pick',
                  value: '4× on dining',
                ),
              ),
              Positioned(
                top: 398 + shift,
                left: 22,
                child: _Callout(
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const FsIcon(
                      FsIcons.arrowUpRight,
                      size: 14,
                      color: Brand.rust,
                      strokeWidth: 2.4,
                    ),
                  ),
                  gap: 10,
                  caption: 'Rewards this month',
                  value: '+\$48.20 earned',
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 132,
                child: Column(
                  children: [
                    Semantics(
                      header: true,
                      child: Text.rich(
                        TextSpan(
                          style: inter(
                            44,
                            weight: FontWeight.w500,
                            spacing: -1.6,
                            height: 1.04,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Every Financial\n',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: 'Decision,\n',
                              style: TextStyle(color: glass(0.82)),
                            ),
                            TextSpan(
                              text: 'Smarter.',
                              style: TextStyle(color: glass(0.6)),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Smarter spending. Better rewards.\nIntelligent finances with AI agents.',
                      textAlign: TextAlign.center,
                      style: inter(15, height: 1.5, color: glass(0.88)),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 44,
                child: Row(
                  children: [
                    Expanded(
                      child: PillButton(
                        label: 'Get Started',
                        style: PillStyle.light,
                        height: 56,
                        fontSize: 16,
                        onTap: start,
                      ),
                    ),
                    const SizedBox(width: 10),
                    RoundButton(
                      icon: FsIcons.arrowRight,
                      label: 'Continue',
                      size: 56,
                      light: false,
                      onTap: start,
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

class _TiltedCard extends StatelessWidget {
  const _TiltedCard();

  @override
  Widget build(BuildContext context) {
    final white = TextStyle(color: glass(0.9));
    return Transform.rotate(
      angle: -9 * 3.1415926535 / 180,
      child: Container(
        width: 266,
        height: 168,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [cssShadow(0, 30, 60, const Color(0x8C280600))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: CssLinearGradient(
                135,
                colors: [
                  Color(0xFF2B2B2B),
                  Color(0xFF121212),
                  Color(0xFF1E1E1E),
                ],
                stops: [0, 0.55, 1],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  bottom: -40,
                  width: 150,
                  height: 170,
                  child: Opacity(
                    opacity: 0.85,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.skewX(-22 * 3.1415926535 / 180),
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: CssLinearGradient(
                            160,
                            colors: [Brand.ember, Color(0xFF8E240A)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Inset top highlight (CSS `inset 0 1px 0`).
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 1,
                  child: ColoredBox(color: glass(0.12)),
                ),
                const Positioned(
                  top: 22,
                  left: 22,
                  child: CardChip(width: 40, height: 30, radius: 7),
                ),
                Positioned(
                  top: 24,
                  right: 22,
                  child: Text(
                    'FinSight',
                    style: inter(
                      13,
                      weight: FontWeight.w600,
                      spacing: 0.4,
                    ).merge(white),
                  ),
                ),
                Positioned(
                  bottom: 22,
                  left: 22,
                  child: Text(
                    '•••• 4821',
                    style: inter(13, spacing: 2, color: glass(0.7)),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 22,
                  child: Text(
                    'VISA',
                    style: inter(
                      16,
                      weight: FontWeight.w700,
                      italic: true,
                      color: Colors.white,
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

/// Frosted callout floating next to the card.
class _Callout extends StatelessWidget {
  const _Callout({
    required this.leading,
    required this.gap,
    required this.caption,
    required this.value,
  });

  final Widget leading;
  final double gap;
  final String caption;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Glass(
      blur: 14,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          SizedBox(width: gap),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(caption, style: inter(11, color: glass(0.8))),
              Text(
                value,
                style: inter(13, weight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

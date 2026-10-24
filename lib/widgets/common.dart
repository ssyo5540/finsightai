import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/cards.dart';
import '../models/finance.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'fs_icon.dart';
import 'gradients.dart';

/// Tap target with the subtle press feedback used across the app (the
/// design has no ripples). Exposes itself to accessibility as a button.
class Tappable extends StatefulWidget {
  const Tappable({
    super.key,
    required this.onTap,
    required this.child,
    this.label,
    this.selected,
  });

  final VoidCallback? onTap;
  final Widget child;

  /// Accessibility label for icon-only buttons.
  final String? label;
  final bool? selected;

  @override
  State<Tappable> createState() => _TappableState();
}

class _TappableState extends State<Tappable> {
  var _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      selected: widget.selected,
      label: widget.label,
      excludeSemantics: widget.label != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: () => _setPressed(false),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          opacity: _pressed ? 0.7 : 1,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Translucent white surface laid over the orange gradients, optionally
/// blurring what is behind it (CSS `backdrop-filter: blur()`).
class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.fill = 0.16,
    this.border = 0.3,
    this.radius = 16,
    this.blur = 0,
    this.padding,
    this.width,
    this.height,
  });

  final Widget child;
  final double fill;
  final double border;
  final double radius;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: glass(fill),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: glass(border)),
      ),
      child: child,
    );
    if (blur == 0) return box;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: box,
      ),
    );
  }
}

/// The 44 pt round glass button used for Back, Add and similar actions on
/// the gradient headers.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconSize = 20,
    this.strokeWidth = 1.8,
    this.fill = 0.14,
    this.border = 0.3,
    this.filled = false,
    this.badge = false,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;
  final double iconSize;
  final double strokeWidth;
  final double fill;
  final double border;
  final bool filled;

  /// Shows the small notification dot.
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: glass(fill),
        border: Border.all(color: glass(border)),
      ),
      alignment: Alignment.center,
      child: FsIcon(
        icon,
        size: iconSize,
        color: Colors.white,
        strokeWidth: strokeWidth,
        filled: filled,
      ),
    );
    final content = badge
        ? Stack(
            children: [
              circle,
              const Positioned(
                top: 10,
                right: 11,
                child: SizedBox(
                  width: 8,
                  height: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFFFD08A),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          )
        : circle;
    if (onTap == null) return ExcludeSemantics(child: content);
    return Tappable(onTap: onTap, label: label, child: content);
  }
}

/// Large figure with lighter cents: `$12,680` `.42`.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.amount, {
    super.key,
    required this.style,
    required this.centsColor,
    this.centsStyle,
    this.textAlign,
  });

  final double amount;
  final TextStyle style;
  final Color centsColor;

  /// Overrides the cents style when it differs by more than colour.
  final TextStyle? centsStyle;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final parts = splitMoney(amount);
    return Text.rich(
      TextSpan(
        text: (amount < 0 ? '-' : '') + parts.whole,
        style: style,
        children: [
          TextSpan(
            text: parts.cents,
            style: centsStyle ?? style.copyWith(color: centsColor),
          ),
        ],
      ),
      textAlign: textAlign,
    );
  }
}

/// Title row above a list, with an optional link on the right.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onTrailingTap,
    this.titleSize = 19,
  });

  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final link = trailing == null
        ? null
        : Text(trailing!, style: inter(13, color: Brand.muted));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: inter(titleSize, weight: FontWeight.w600, spacing: -0.4),
            ),
          ),
        ),
        if (link != null)
          onTrailingTap == null
              ? link
              : Tappable(onTap: onTrailingTap, child: link),
      ],
    );
  }
}

/// Thin rounded progress bar; [highlight] uses the warm gradient.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.highlight = false,
    this.gradient,
    this.track = Brand.hairline,
  });

  final double value;
  final bool highlight;
  final Gradient? gradient;
  final Color track;

  @override
  Widget build(BuildContext context) {
    final fillGradient =
        gradient ??
        (highlight
            ? const CssLinearGradient(
                90,
                colors: [Color(0xFFF09050), Brand.ember],
              )
            : null);
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: track,
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        heightFactor: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fillGradient == null ? Brand.ink : null,
            gradient: fillGradient,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

/// Peach callout with a gradient icon tile, used for agent tips.
class TipBanner extends StatelessWidget {
  const TipBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.iconTile = 36,
    this.iconSize = 18,
    this.solidTile = false,
    this.bordered = false,
    this.trailing,
    this.onTap,
  });

  final String icon;
  final String title;
  final String body;
  final double iconTile;
  final double iconSize;

  /// Flat ember tile instead of the ember → brick gradient.
  final bool solidTile;
  final bool bordered;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final banner = Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Brand.peach,
        borderRadius: BorderRadius.circular(18),
        border: bordered ? Border.all(color: Brand.peachBorder) : null,
      ),
      child: Row(
        children: [
          Container(
            width: iconTile,
            height: iconTile,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(iconTile == 36 ? 12 : 11),
              color: solidTile ? Brand.ember : null,
              gradient: solidTile
                  ? null
                  : const CssLinearGradient(
                      135,
                      colors: [Brand.ember, Brand.brick],
                    ),
            ),
            alignment: Alignment.center,
            child: FsIcon(
              icon,
              size: iconSize,
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
                  title,
                  style: inter(13, weight: FontWeight.w600, color: Brand.ink),
                ),
                Text(body, style: inter(12, color: Brand.mutedWarm)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
    return onTap == null ? banner : Tappable(onTap: onTap, child: banner);
  }
}

/// Round or rounded-square badge with initials or an icon.
class MonogramBadge extends StatelessWidget {
  const MonogramBadge({
    super.key,
    required this.monogram,
    this.size = 40,
    this.radius,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w700,
  });

  final Monogram monogram;
  final double size;

  /// Corner radius; null draws a circle.
  final double? radius;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: monogram.background,
        shape: radius == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: radius == null ? null : BorderRadius.circular(radius!),
      ),
      alignment: Alignment.center,
      child: monogram.icon != null
          ? FsIcon(
              FsIcons.byName(monogram.icon!),
              size: 18,
              color: monogram.foreground,
            )
          : Text(
              monogram.text ?? '',
              style: inter(
                fontSize,
                weight: fontWeight,
                color: monogram.foreground,
              ),
            ),
    );
  }
}

/// Small card swatch used in lists (46 × 30 in the wallet).
class CardThumb extends StatelessWidget {
  const CardThumb({
    super.key,
    required this.card,
    this.width = 46,
    this.height = 30,
    this.radius = 6,
  });

  final PaymentCard card;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: CssLinearGradient(135, colors: card.art.thumb),
      ),
    );
  }
}

/// Face of a credit card: dark gradient with the slanted accent band.
/// The accent band is placed with CSS-style right/top offsets and size.
class CardFace extends StatelessWidget {
  const CardFace({
    super.key,
    required this.card,
    required this.radius,
    required this.accentRight,
    required this.accentTop,
    required this.accentWidth,
    required this.accentHeight,
    this.accentOpacity = 0.9,
    this.skewDegrees = -20,
    this.shadows = const [],
    this.child,
  });

  final PaymentCard card;
  final double radius;
  final double accentRight;
  final double accentTop;
  final double accentWidth;
  final double accentHeight;
  final double accentOpacity;
  final double skewDegrees;
  final List<BoxShadow> shadows;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: CssLinearGradient(
              135,
              colors: card.art.background,
              stops: const [0, 0.6],
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: accentRight,
                top: accentTop,
                width: accentWidth,
                height: accentHeight,
                child: Opacity(
                  opacity: accentOpacity,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.skewX(skewDegrees * math.pi / 180),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: CssLinearGradient(
                          160,
                          colors: card.art.accent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (child != null) Positioned.fill(child: child!),
            ],
          ),
        ),
      ),
    );
  }
}

/// The gold EMV chip printed on the cards.
class CardChip extends StatelessWidget {
  const CardChip({
    super.key,
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const CssLinearGradient(
          135,
          colors: [Color(0xFFF6D58E), Color(0xFFC79A3F)],
        ),
      ),
    );
  }
}

/// Full-width pill button: black by default, outlined or white variants.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.height = 54,
    this.icon,
    this.iconSize = 18,
    this.style = PillStyle.dark,
    this.fontSize = 15,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onTap;
  final double height;
  final String? icon;
  final double iconSize;
  final PillStyle style;
  final double fontSize;

  /// Shows a spinner in place of the icon.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, border) = switch (style) {
      PillStyle.dark => (Brand.ink, Colors.white, null),
      PillStyle.light => (Colors.white, Brand.ink, null),
      PillStyle.outline => (Colors.white, Brand.ink, Brand.border),
    };
    return Tappable(
      onTap: busy ? null : onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(height / 2),
          border: border == null ? null : Border.all(color: border),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (busy)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  width: iconSize - 2,
                  height: iconSize - 2,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foreground,
                  ),
                ),
              )
            else if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FsIcon(
                  icon!,
                  size: iconSize,
                  color: foreground,
                  strokeWidth: 2,
                ),
              ),
            Text(
              label,
              style: inter(
                fontSize,
                weight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum PillStyle { dark, light, outline }

/// Round 52–56 pt companion button next to a [PillButton].
class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.size = 52,
    this.light = true,
    this.selected = false,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;
  final double size;

  /// White with a border; otherwise solid white without border (welcome).
  final bool light;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      label: label,
      selected: selected,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? Brand.ink : Colors.white,
          border: light
              ? Border.all(color: selected ? Brand.ink : Brand.border)
              : null,
        ),
        alignment: Alignment.center,
        child: FsIcon(
          icon,
          size: 20,
          color: selected ? Colors.white : Brand.ink,
          strokeWidth: light ? 1.8 : 2,
        ),
      ),
    );
  }
}

/// Shows a short message in the app's floating snackbar style.
void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      ),
    );
}

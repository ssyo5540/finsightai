import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme.dart';

/// SVG markup of every icon in the design, copied from its 24 × 24 stroke
/// icons so they render identically.
abstract final class FsIcons {
  static const logo = '<path d="M4 19V9M10 19V5M16 19v-7M22 19H2"/>';
  static const sparkle =
      '<path d="M12 3l1.8 4.7 4.7 1.8-4.7 1.8L12 16l-1.8-4.7L5.5 9.5l4.7-1.8z"/>';
  static const sparkles =
      '$sparkle'
      '<path d="M19 15l.8 2.2 2.2.8-2.2.8L19 21l-.8-2.2L16 18l2.2-.8z"/>';
  static const arrowUpRight = '<path d="M7 17 17 7M8 7h9v9"/>';
  static const arrowDownLeft = '<path d="M17 7 7 17M16 17H7V8"/>';
  static const arrowDownRight = '<path d="M7 7l10 10M17 8v9H8"/>';
  static const arrowRight = '<path d="M5 12h14M13 6l6 6-6 6"/>';
  static const arrowUp = '<path d="M12 19V5M5 12l7-7 7 7"/>';
  static const transfer =
      '<path d="M7 4v16M3 8l4-4 4 4M17 20V4M13 16l4 4 4-4"/>';
  static const bell =
      '<path d="M6 8a6 6 0 1 1 12 0c0 7 3 8 3 8H3s3-1 3-8"/>'
      '<path d="M10.3 21a1.9 1.9 0 0 0 3.4 0"/>';
  static const chevronLeft = '<path d="M15 18l-6-6 6-6"/>';
  static const chevronRight = '<path d="M9 6l6 6-6 6"/>';
  static const chevronDown = '<path d="M6 9l6 6 6-6"/>';
  static const plus = '<path d="M12 5v14M5 12h14"/>';
  static const close = '<path d="M18 6 6 18M6 6l12 12"/>';
  static const check = '<path d="M20 6 9 17l-5-5"/>';
  static const home =
      '<path d="M3 10.5 12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z"/>';
  static const wallet =
      '<rect x="2.5" y="5" width="19" height="14" rx="2.5"/><path d="M2.5 10h19"/>';
  static const expenses =
      '<path d="M21 12A9 9 0 1 1 12 3v9z"/>'
      '<path d="M15 3.5A9 9 0 0 1 20.5 9H15z"/>';
  static const pie = '<path d="M21 12A9 9 0 1 1 12 3v9z"/>';
  static const grid =
      '<rect x="3" y="3" width="7" height="7" rx="2"/>'
      '<rect x="14" y="3" width="7" height="7" rx="2"/>'
      '<rect x="3" y="14" width="7" height="7" rx="2"/>'
      '<rect x="14" y="14" width="7" height="7" rx="2"/>';
  static const coffee =
      '<path d="M17 8h1a4 4 0 0 1 0 8h-1M3 8h14v9a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4z"/>'
      '<path d="M6 2v3M10 2v3M14 2v3"/>';
  static const contactless =
      '<path d="M8.5 8.5a5 5 0 0 1 0 7M12 5a10 10 0 0 1 0 14M5 11a1.5 1.5 0 0 1 0 2"/>';
  static const contactlessWide =
      '<path d="M8.5 8.5a5 5 0 0 1 0 7M12 5a10 10 0 0 1 0 14M15.5 2a14 14 0 0 1 0 20M5 11a1.5 1.5 0 0 1 0 2"/>';
  static const scan =
      '<path d="M3 7V5a2 2 0 0 1 2-2h2M17 3h2a2 2 0 0 1 2 2v2M21 17v2a2 2 0 0 1-2 2h-2M7 21H5a2 2 0 0 1-2-2v-2M7 12h10"/>';
  static const search =
      '<circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/>';
  static const bookmark =
      '<path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/>';
  static const pin =
      '<path d="M12 22s7-6.2 7-12a7 7 0 1 0-14 0c0 5.8 7 12 7 12z"/>'
      '<circle cx="12" cy="10" r="2.5"/>';
  static const faceId =
      '<path d="M3 8V5a2 2 0 0 1 2-2h3M16 3h3a2 2 0 0 1 2 2v3M21 16v3a2 2 0 0 1-2 2h-3M8 21H5a2 2 0 0 1-2-2v-3M9 9v1M15 9v1M12 9v4h-1M9 16a4 4 0 0 0 6 0"/>';
  static const calendar =
      '<rect x="3" y="5" width="18" height="16" rx="2"/>'
      '<path d="M3 10h18M8 3v4M16 3v4"/>';
  static const shirt =
      '<path d="M8 3 4 6v4h3v11h10V10h3V6l-4-3c0 2-2 3-4 3S8 5 8 3z"/>';
  static const heart =
      '<path d="M20.8 5.6a5.5 5.5 0 0 0-7.8 0L12 6.7l-1-1.1a5.5 5.5 0 0 0-7.8 7.8L12 22l8.8-8.6a5.5 5.5 0 0 0 0-7.8z"/>';
  static const dumbbell =
      '<path d="M6.5 6.5v11M17.5 6.5v11M3 9.5v5M21 9.5v5M6.5 12h11"/>';
  static const cart =
      '<circle cx="9" cy="20" r="1.4"/><circle cx="18" cy="20" r="1.4"/>'
      '<path d="M2 3h3l2.6 12.2a2 2 0 0 0 2 1.6h8.2a2 2 0 0 0 2-1.5L21.5 8H6"/>';
  static const plane =
      '<path d="M17.8 19.2 16 11l3.5-3.5C21 6 21.5 4 21 3c-1-.5-3 0-4.5 1.5L13 8 4.8 6.2c-.5-.1-.9.1-1.1.5l-.3.5c-.2.5-.1 1 .3 1.3L9 12l-2 3H4l-1 1 3 2 2 3 1-1v-3l3-2 3.5 5.3c.3.4.8.5 1.3.3l.5-.2c.4-.3.6-.7.5-1.2z"/>';
  static const alert =
      '<path d="M12 9v4M12 17h.01M10.3 3.9 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/>';
  static const repeat =
      '<path d="M17 2l4 4-4 4"/>'
      '<path d="M3 11V9a3 3 0 0 1 3-3h15M7 22l-4-4 4-4"/>'
      '<path d="M21 13v2a3 3 0 0 1-3 3H3"/>';
  static const shield =
      '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>';
  static const laptop =
      '<rect x="3" y="4" width="18" height="12" rx="2"/><path d="M2 20h20"/>';
  static const bolt = '<path d="M13 2 3 14h9l-1 8 10-12h-9z"/>';
  static const chat =
      '<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>';
  static const gift =
      '<path d="M20 12v10H4V12M2 7h20v5H2zM12 22V7M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7zM12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z"/>';
  static const target =
      '<path d="M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20zM12 18a6 6 0 1 0 0-12 6 6 0 0 0 0 12zM12 14a2 2 0 1 0 0-4 2 2 0 0 0 0 4z"/>';
  static const more =
      '<circle cx="5" cy="12" r="1.8"/><circle cx="12" cy="12" r="1.8"/><circle cx="19" cy="12" r="1.8"/>';
  static const mic =
      '<rect x="9" y="2" width="6" height="12" rx="3"/>'
      '<path d="M5 10a7 7 0 0 0 14 0M12 17v5"/>';

  // Used by screens the design doesn't include (sign-in, profile).
  static const mail =
      '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3 7 9 6 9-6"/>';
  static const lock =
      '<rect x="4" y="11" width="16" height="10" rx="2"/>'
      '<path d="M8 11V7a4 4 0 0 1 8 0v4"/>';
  static const eye =
      '<path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/>'
      '<circle cx="12" cy="12" r="3"/>';
  static const eyeOff =
      '<path d="M10.6 5.1A10.7 10.7 0 0 1 12 5c6.5 0 10 7 10 7a17.6 17.6 0 0 1-2.2 3.2M6.6 6.6C3.9 8.4 2 12 2 12s3.5 7 10 7a9.7 9.7 0 0 0 5.4-1.6M9.9 9.9a3 3 0 0 0 4.2 4.2M2 2l20 20"/>';
  static const logOut =
      '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9"/>';

  /// Icons referenced by name from the JSON data.
  static String byName(String name) => switch (name) {
    'alert' => alert,
    'bell' => bell,
    'bolt' => bolt,
    'cart' => cart,
    'check' => check,
    'coffee' => coffee,
    'dumbbell' => dumbbell,
    'gift' => gift,
    'heart' => heart,
    'home' => home,
    'laptop' => laptop,
    'pie' => pie,
    'plane' => plane,
    'repeat' => repeat,
    'shield' => shield,
    'shirt' => shirt,
    'target' => target,
    'trendUp' => arrowUpRight,
    _ => sparkle,
  };
}

/// One of the design's stroke icons at [size] in [color].
class FsIcon extends StatelessWidget {
  const FsIcon(
    this.markup, {
    super.key,
    this.size = 20,
    this.color = Brand.ink,
    this.strokeWidth = 1.8,
    this.filled = false,
  });

  final String markup;
  final double size;
  final Color color;
  final double strokeWidth;

  /// Fill the shapes instead of stroking them (the "more" dots).
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final paint = filled
        ? 'fill="#000" stroke="none"'
        : 'fill="none" stroke="#000" stroke-width="$strokeWidth" '
              'stroke-linecap="round" stroke-linejoin="round"';
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" $paint>'
      '$markup</svg>',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      excludeFromSemantics: true,
    );
  }
}

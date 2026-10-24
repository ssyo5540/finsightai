import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// CSS `linear-gradient(<angle>deg, …)`. Unlike [LinearGradient] with
/// corner alignments, the gradient line keeps its angle on any aspect ratio,
/// exactly like the browser draws it.
class CssLinearGradient extends LinearGradient {
  const CssLinearGradient(this.angle, {required super.colors, super.stops});

  /// Degrees clockwise from "to top"; 180 runs top to bottom.
  final double angle;

  @override
  Shader createShader(Rect rect, {TextDirection? textDirection}) {
    final radians = angle * math.pi / 180;
    final direction = Offset(math.sin(radians), -math.cos(radians));
    final halfLength =
        (rect.width * direction.dx.abs() + rect.height * direction.dy.abs()) /
        2;
    return ui.Gradient.linear(
      rect.center - direction * halfLength,
      rect.center + direction * halfLength,
      colors,
      stops,
    );
  }
}

/// CSS `radial-gradient(<rx> <ry> at <cx> <cy>, …)` where every value is a
/// fraction of the painted box, so ellipses stretch with it.
RadialGradient cssRadial({
  required List<Color> colors,
  required List<double> stops,
  double cx = 0.5,
  double cy = 0.5,
  required double rx,
  required double ry,
}) {
  return RadialGradient(
    colors: colors,
    stops: stops,
    transform: _EllipseTransform(cx, cy, rx, ry),
  );
}

/// The design's soft glow: [color] fading to transparent at 70 %.
RadialGradient cssGlow(
  Color color, {
  required double cx,
  required double cy,
  required double rx,
  required double ry,
}) {
  return cssRadial(
    colors: [color, color.withValues(alpha: 0)],
    stops: const [0, 0.7],
    cx: cx,
    cy: cy,
    rx: rx,
    ry: ry,
  );
}

class _EllipseTransform extends GradientTransform {
  const _EllipseTransform(this.cx, this.cy, this.rx, this.ry);

  final double cx;
  final double cy;
  final double rx;
  final double ry;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    // RadialGradient draws a circle of radius shortestSide / 2 around the
    // centre; map that circle onto the requested ellipse.
    final baseRadius = bounds.shortestSide / 2;
    final center = bounds.center;
    return Matrix4.identity()
      ..translateByDouble(
        bounds.left + cx * bounds.width,
        bounds.top + cy * bounds.height,
        0,
        1,
      )
      ..scaleByDouble(
        rx * bounds.width / baseRadius,
        ry * bounds.height / baseRadius,
        1,
        1,
      )
      ..translateByDouble(-center.dx, -center.dy, 0, 1);
  }
}

/// CSS `conic-gradient(fill 0deg <sweep>deg, track <sweep>deg 360deg)`:
/// a progress ring that starts at 12 o'clock.
SweepGradient cssConic(Color fill, Color track, double fraction) {
  final f = fraction.clamp(0.0, 1.0);
  return SweepGradient(
    colors: [fill, fill, track, track],
    stops: [0, f, f, 1],
    transform: const GradientRotation(-math.pi / 2),
  );
}

/// CSS `box-shadow: <dx> <dy> <blur> <color>`. Flutter's blur radius is
/// converted so the shadow spreads the same distance as in the browser.
BoxShadow cssShadow(double dx, double dy, double blur, Color color) {
  return BoxShadow(
    color: color,
    offset: Offset(dx, dy),
    blurRadius: math.max(0, (blur / 2 - 0.5) / 0.57735),
  );
}

/// Paints several gradients on top of each other, like a CSS `background`
/// with multiple layers. [layers] are in CSS order: the first is on top.
class GradientLayers extends StatelessWidget {
  const GradientLayers({
    super.key,
    required this.layers,
    this.borderRadius = BorderRadius.zero,
    this.child,
  });

  final List<Gradient> layers;
  final BorderRadius borderRadius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LayersPainter(layers, borderRadius),
      child: child,
    );
  }
}

class _LayersPainter extends CustomPainter {
  _LayersPainter(this.layers, this.borderRadius);

  final List<Gradient> layers;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = borderRadius.toRRect(rect);
    for (final gradient in layers.reversed) {
      canvas.drawRRect(shape, Paint()..shader = gradient.createShader(rect));
    }
  }

  @override
  bool shouldRepaint(_LayersPainter old) =>
      old.layers != layers || old.borderRadius != borderRadius;
}

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../router.dart';
import '../theme.dart';
import 'common.dart';
import 'fs_icon.dart';
import 'gradients.dart';

/// Screen body with the floating navigation pill and the fade that lets
/// content scroll away beneath it. Once the content scrolls, a frosted bar
/// covers the status bar so text never runs under the clock.
class TabChrome extends StatefulWidget {
  const TabChrome({
    super.key,
    required this.active,
    required this.child,
    this.fadeHeight = 120,
  });

  final NavTab active;
  final Widget child;
  final double fadeHeight;

  @override
  State<TabChrome> createState() => _TabChromeState();
}

class _TabChromeState extends State<TabChrome> {
  var _scrolled = false;

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth == 0 && notification.metrics.axis == Axis.vertical) {
      final scrolled = notification.metrics.pixels > 8;
      if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
    }
    return false;
  }

  static final Widget _scrim = ClipRect(
    child: BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: ColoredBox(color: Brand.canvas.withValues(alpha: 0.88)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final statusBar = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        Positioned.fill(
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: widget.child,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: statusBar,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _scrolled ? 1 : 0,
              // Only claim the status bar while the scrim is showing, so each
              // screen's own light/dark style applies at rest.
              child: _scrolled
                  ? AnnotatedRegion<SystemUiOverlayStyle>(
                      value: SystemUiOverlayStyle.dark,
                      child: _scrim,
                    )
                  : _scrim,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: widget.fadeHeight,
          child: const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: CssLinearGradient(
                  180,
                  colors: [Color(0x00F6F5F3), Brand.canvas],
                  stops: [0, 0.55],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 26,
          child: Center(child: FloatingNavBar(active: widget.active)),
        ),
      ],
    );
  }
}

/// The frosted pill with five round destinations.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key, required this.active});

  final NavTab active;

  static const _icons = {
    NavTab.home: FsIcons.home,
    NavTab.wallet: FsIcons.wallet,
    NavTab.expenses: FsIcons.expenses,
    NavTab.agents: FsIcons.sparkles,
    NavTab.insights: FsIcons.grid,
  };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        boxShadow: [cssShadow(0, 12, 30, const Color(0x1F3C1400))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(6),
            color: Brand.navBackground,
            child: Semantics(
              container: true,
              label: 'Main navigation',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  for (final tab in NavTab.values)
                    Tappable(
                      label: tab.label,
                      selected: tab == active,
                      onTap: () => AppRouter.openTab(context, tab),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tab == active ? Brand.ink : null,
                        ),
                        alignment: Alignment.center,
                        child: FsIcon(
                          _icons[tab]!,
                          size: 21,
                          color: tab == active ? Colors.white : Brand.navInk,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Port of src/components/anim.tsx.
import 'package:flutter/material.dart';

import 'package:elhareef/core/navigation/nav.dart';

/// The design's signature curve — cubic-bezier(.16,1,.3,1).
const easeOutExpo = Cubic(0.16, 1, 0.3, 1);
const easeStandard = Cubic(0.4, 0, 0.2, 1);

/// Marks whether the enclosing bottom tab is the active one, so screens can
/// replay their entrance when their tab gains focus (RN `useIsFocused`).
class TabActive extends InheritedWidget {
  const TabActive({super.key, required this.active, required super.child});
  final bool active;
  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TabActive>()?.active ?? true;
  @override
  bool updateShouldNotify(TabActive old) => old.active != active;
}

/// Calls [onFocus] whenever the screen gains focus: first show, returning to
/// it via back, and its tab becoming active.
mixin FocusReplay<T extends StatefulWidget> on State<T> implements RouteAware {
  ModalRoute<void>? _route;
  bool? _tabActive;

  void onFocus();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != _route) {
      if (_route != null) routeObserver.unsubscribe(this);
      _route = route;
      if (route != null) routeObserver.subscribe(this, route);
    }
    final active = TabActive.of(context);
    if (_tabActive != active) {
      final first = _tabActive == null;
      _tabActive = active;
      if (active && !first) onFocus();
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    if (TabActive.of(context)) onFocus();
  }

  @override
  void didPopNext() {
    if (TabActive.of(context)) onFocus();
  }

  @override
  void didPop() {}
  @override
  void didPushNext() {}
}

/// `ehScreen` entrance (fade + 14px rise, 450ms, easeOutExpo) replayed on
/// every focus. The fade is compressed into the first 35% of the timeline.
class ScreenEntrance extends StatefulWidget {
  const ScreenEntrance({super.key, required this.child});
  final Widget child;
  @override
  State<ScreenEntrance> createState() => _ScreenEntranceState();
}

class _ScreenEntranceState extends State<ScreenEntrance>
    with SingleTickerProviderStateMixin, FocusReplay {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 450), value: 1);

  @override
  void onFocus() => _c.forward(from: 0);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (context, child) {
          final v = easeOutExpo.transform(_c.value);
          return Opacity(
            opacity: (v / 0.35).clamp(0.0, 1.0),
            child: Transform.translate(offset: Offset(0, 14 * (1 - v)), child: child),
          );
        },
      );
}

/// Gentle selection transition: [over] (the selected look) cross-fades on
/// top of [off], which defines the size.
class SelectFade extends StatelessWidget {
  const SelectFade({
    super.key,
    required this.on,
    required this.off,
    required this.over,
    this.duration = 260,
  });
  final bool on;
  final Widget off, over;
  final int duration;

  @override
  Widget build(BuildContext context) => Stack(
        // RN: `off` stretches like a normal flex child (e.g. a segment).
        fit: StackFit.passthrough,
        children: [
          off,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: on ? 1 : 0,
                duration: Duration(milliseconds: duration),
                curve: easeStandard,
                child: over,
              ),
            ),
          ),
        ],
      );
}

/// One-shot mount entrance: fade + [rise]px rise (+ optional scale-up).
class _MountIn extends StatefulWidget {
  const _MountIn({required this.child, required this.rise, this.scaleFrom = 1, this.ms = 450, this.delay = 0});
  final Widget child;
  final double rise, scaleFrom;
  final int ms, delay;
  @override
  State<_MountIn> createState() => _MountInState();
}

class _MountInState extends State<_MountIn> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: Duration(milliseconds: widget.ms));

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (context, child) {
          final v = easeOutExpo.transform(_c.value);
          return Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, widget.rise * (1 - v)),
              child: Transform.scale(scale: widget.scaleFrom + (1 - widget.scaleFrom) * v, child: child),
            ),
          );
        },
      );
}

/// Chat-message entrance (`ehMsgIn`): fade + 12px rise + slight scale-up.
class MsgIn extends StatelessWidget {
  const MsgIn({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => _MountIn(rise: 12, scaleFrom: 0.94, child: child);
}

/// Staggered section entrance (fade + 16px rise, 700ms).
class FadeInUp extends StatelessWidget {
  const FadeInUp({super.key, required this.child, this.delay = 0});
  final Widget child;
  final int delay;
  @override
  Widget build(BuildContext context) => _MountIn(rise: 16, ms: 700, delay: delay, child: child);
}

/// Scroll-tied reveal: wrap the scrollable's children with [RevealOnScroll]
/// and pass the same [ScrollController] to the scroll view. Items already on
/// screen at first paint render fully visible; others rise 20px, fade and
/// scale 0.97→1 over the first 140px of scroll after entering the viewport.
class RevealOnScroll extends StatefulWidget {
  const RevealOnScroll({super.key, required this.controller, required this.child});
  final ScrollController controller;
  final Widget child;
  @override
  State<RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<RevealOnScroll> {
  /// Scroll offset at which the item's top touches the viewport bottom;
  /// null = visible at first paint (no reveal).
  double? _start;
  bool _measured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final top = box.localToGlobal(Offset.zero).dy;
      final winH = MediaQuery.sizeOf(context).height;
      final offset = widget.controller.hasClients ? widget.controller.offset : 0.0;
      setState(() {
        _measured = true;
        _start = top < winH - 40 ? null : top - winH + offset;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_measured || _start == null) return widget.child;
    return AnimatedBuilder(
      animation: widget.controller,
      child: widget.child,
      builder: (context, child) {
        final y = widget.controller.hasClients ? widget.controller.offset : 0.0;
        final p = ((y - _start!) / 140).clamp(0.0, 1.0);
        return Opacity(
          opacity: p,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - p)),
            child: Transform.scale(scale: 0.97 + 0.03 * p, child: child),
          ),
        );
      },
    );
  }
}

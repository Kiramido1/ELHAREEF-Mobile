// Transient confirmation message drawn in the root overlay (the app uses
// no Scaffold, so SnackBar isn't available).
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/widgets/txt.dart';

OverlayEntry? _current;

void showToast(String message, {bool error = false}) {
  final overlay = navKey.currentState?.overlay;
  if (overlay == null) return;
  _current?.remove();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _Toast(
      message: message,
      error: error,
      onDone: () {
        if (_current == entry) _current = null;
        entry.remove();
      },
    ),
  );
  _current = entry;
  overlay.insert(entry);
}

class _Toast extends StatefulWidget {
  const _Toast({required this.message, required this.error, required this.onDone});
  final String message;
  final bool error;
  final VoidCallback onDone;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 220))..forward();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2600), () async {
      if (!mounted) return;
      await _c.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + 96;
    final curve = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return Positioned(
      left: 20,
      right: 20,
      bottom: bottom,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, .25), end: Offset.zero).animate(curve),
            child: Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                decoration: BoxDecoration(
                  color: widget.error ? Brand.danger : Brand.navy,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [BoxShadow(color: Color.fromRGBO(3, 8, 20, .25), blurRadius: 16, offset: Offset(0, 6))],
                ),
                child: Txt(widget.message, w: 600, size: 13.5, color: Brand.white, center: true),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

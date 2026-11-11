// Ports of src/components/Skeleton.tsx and src/components/PitchArt.tsx.
import 'package:flutter/material.dart';

import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/core/theme/colors.dart';

/// Shimmering skeleton block (`ehShimmer`): tint↔shim2 pulse, 650ms each way.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.width, this.height, this.radius = 0, this.margin});
  final double? width, height;
  final double radius;
  final EdgeInsetsGeometry? margin;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 650))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: Color.lerp(c.tint, c.shim2, _c.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Pitch visual: photo (cover) over the brand gradient, with optional inset
/// pitch lines and centre circle. Size it from the parent.
class PitchArt extends StatelessWidget {
  const PitchArt({
    super.key,
    required this.gradIndex,
    this.photo,
    this.lines = false,
    this.circle = false,
    this.inset = 10,
    this.radius = BorderRadius.zero,
    this.width,
    this.height,
    this.children = const [],
  });
  final int gradIndex;

  /// Asset path, e.g. `pitchPhotos[id]`.
  final String? photo;
  final bool lines, circle;
  final double inset;
  final BorderRadiusGeometry radius;
  final double? width, height;

  /// Overlays, laid out in a Stack (use Positioned / Align).
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final g = pitchGradients[gradIndex % pitchGradients.length];
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: g),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (photo != null) Image.asset(photo!, fit: BoxFit.cover),
            if (lines)
              Positioned.fill(
                left: inset,
                right: inset,
                top: inset,
                bottom: inset,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color.fromRGBO(251, 252, 250, .35), width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            if (circle)
              Center(
                child: IgnorePointer(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color.fromRGBO(251, 252, 250, .4), width: 1.5),
                    ),
                  ),
                ),
              ),
            ...children,
          ],
        ),
      ),
    );
  }
}

// Port of src/components/ui.tsx. RN's manual RTL handling (row-reverse,
// left/right swaps) is replaced by the app-wide Directionality, so plain
// Row / *Directional widgets flip automatically in Arabic.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/theme/tokens.dart';
import 'package:elhareef/core/widgets/anim.dart';
import 'package:elhareef/core/widgets/txt.dart';

/// RN `Pressable` with the design's press-scale feedback.
class Press extends StatefulWidget {
  const Press({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.94,
    this.label,
    this.selected,
    this.button = true,
  });
  final Widget child;
  final VoidCallback? onTap;

  /// Scale while pressed (1 = no feedback).
  final double scale;
  final String? label;
  final bool? selected;
  final bool button;

  @override
  State<Press> createState() => _PressState();
}

class _PressState extends State<Press> {
  bool _down = false;
  void _set(bool v) {
    if (widget.onTap != null && _down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) => Semantics(
        button: widget.button,
        label: widget.label,
        selected: widget.selected,
        enabled: widget.onTap != null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: (_) => _set(true),
          onTapUp: (_) => _set(false),
          onTapCancel: () => _set(false),
          child: Transform.scale(scale: _down ? widget.scale : 1, child: widget.child),
        ),
      );
}

/* -------------------------------------------------------------- Screen */

/// Screen background + `ScreenEntrance`; pads below the status bar unless
/// [edgeToEdge] (screens drawing under it, e.g. the pitch hero).
class Screen extends StatelessWidget {
  const Screen({super.key, required this.child, this.edgeToEdge = false, this.padding});
  final Widget child;
  final bool edgeToEdge;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final top = edgeToEdge ? 0.0 : MediaQuery.paddingOf(context).top + Layout.headerTop;
    return ColoredBox(
      color: context.colors.bg,
      child: ScreenEntrance(
        child: Padding(
          padding: EdgeInsets.only(top: top).add(padding ?? EdgeInsets.zero),
          child: child,
        ),
      ),
    );
  }
}

/* ---------------------------------------------------------- BackButton */

class EhBackButton extends StatelessWidget {
  const EhBackButton({super.key, required this.onPressed, this.size = 38});
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Press(
      onTap: onPressed,
      label: context.i18n.isRTL ? 'رجوع' : 'Back',
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.card,
          border: Border.all(color: c.ink12, width: 1.5),
        ),
        // '‹' is bidi-mirrored automatically in RTL, same as the design.
        child: Transform.translate(offset: const Offset(0, -2), child: Txt('‹', size: 18, center: true)),
      ),
    );
  }
}

/* -------------------------------------------------------------- Button */

/// [variant]: 'green' | 'navy' | 'outline' | 'ghost' | 'danger-outline'.
class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = 'green',
    this.disabled = false,
    this.disabledLabelColor,
    this.size = 15.5,
    this.weight = 700,
    this.paddingV = 16,
    this.child,
  });
  final String label;
  final VoidCallback? onPressed;
  final String variant;
  final bool disabled;
  final Color? disabledLabelColor;
  final double size;
  final int weight;
  final double paddingV;

  /// Optional custom content replacing the label text (e.g. a spinner).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bg = disabled
        ? c.disabled
        : variant == 'green'
            ? Brand.green
            : variant == 'navy'
                ? c.navyBtn
                : c.card;
    final fg = disabled
        ? (disabledLabelColor ?? c.ink35)
        : variant == 'outline'
            ? c.ink
            : variant == 'danger-outline'
                ? Brand.danger
                : Brand.white;
    final outlined = variant == 'outline' || variant == 'danger-outline';
    return Press(
      onTap: disabled ? null : onPressed,
      label: label,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: paddingV),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: variant == 'ghost' ? Colors.transparent : bg,
          borderRadius: BorderRadius.circular(Radii.card14),
          border: outlined
              ? Border.all(color: variant == 'outline' ? c.ink14 : Brand.dangerBd, width: 1.5)
              : null,
        ),
        child: child ??
            Txt(label, w: weight, size: size, color: variant == 'ghost' ? c.ink55 : fg, center: true),
      ),
    );
  }
}

/* ---------------------------------------------------------------- Chip */

class EhChip extends StatelessWidget {
  const EhChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onPressed,
    this.paddingV = 8,
    this.paddingH = 14,
    this.size = 13,
  });
  final String label;
  final bool selected;
  final VoidCallback? onPressed;
  final double paddingV, paddingH, size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget box(bool on) => Container(
          padding: EdgeInsets.symmetric(vertical: paddingV, horizontal: paddingH),
          // Only the overlay centers (it is stretched over `off`); `off`
          // sizes to its label like the RN chip.
          alignment: on ? Alignment.center : null,
          decoration: BoxDecoration(
            color: on ? c.chipOn : c.card,
            border: Border.all(color: on ? c.chipOn : c.ink14, width: 1.5),
            borderRadius: BorderRadius.circular(Radii.pill),
          ),
          child: Txt(label, w: 600, size: size, color: on ? c.chipOnFg : null),
        );
    return Press(
      onTap: onPressed,
      scale: 0.96,
      selected: selected,
      child: SelectFade(on: selected, off: box(false), over: box(true)),
    );
  }
}

/* ----------------------------------------------------------- Segmented */

class Segmented extends StatelessWidget {
  const Segmented({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
    this.paddingV = 10,
  });
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final double paddingV;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: c.tint, borderRadius: BorderRadius.circular(Radii.input)),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: Press(
                onTap: () => onSelect(i),
                scale: 1,
                selected: i == selectedIndex,
                child: SelectFade(
                  on: i == selectedIndex,
                  off: Padding(
                    padding: EdgeInsets.symmetric(vertical: paddingV),
                    child: Txt(options[i], w: 600, size: 13, color: c.ink55, center: true),
                  ),
                  over: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.segOn,
                      borderRadius: BorderRadius.circular(Radii.md),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF030814).withValues(alpha: .12),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Txt(options[i], w: 600, size: 13, center: true),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/* -------------------------------------------------------- ToggleSwitch */

class ToggleSwitch extends StatelessWidget {
  const ToggleSwitch({super.key, required this.value, required this.onToggle});
  final bool value;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      toggled: value,
      child: GestureDetector(
        onTap: onToggle,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: value ? 1 : 0),
          duration: const Duration(milliseconds: 320),
          curve: easeOutExpo,
          builder: (context, v, _) => Container(
            width: 46,
            height: 27,
            decoration: BoxDecoration(
              color: Color.lerp(c.ink15, Brand.green, v),
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
            child: Stack(
              textDirection: TextDirection.ltr, // the RN knob slides left→right in both languages
              children: [
                Positioned(
                  top: 3,
                  left: 3 + 19 * v,
                  child: Container(
                    width: 21,
                    height: 21,
                    decoration: BoxDecoration(
                      color: c.card,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF030814).withValues(alpha: .25),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
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

/* ----------------------------------------------------- RadioOptionCard */

class RadioOptionCard extends StatelessWidget {
  const RadioOptionCard({
    super.key,
    required this.label,
    required this.sub,
    required this.selected,
    required this.onPressed,
  });
  final String label, sub;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Press(
      onTap: onPressed,
      scale: 1,
      selected: selected,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
        decoration: BoxDecoration(
          color: selected ? c.tint : c.card,
          border: Border.all(color: selected ? Brand.green : c.ink12, width: 1.5),
          borderRadius: BorderRadius.circular(Radii.card14),
        ),
        child: Row(
          children: [
            Container(
              width: 19,
              height: 19,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? Brand.green : c.ink3, width: 2),
              ),
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? Brand.green : Colors.transparent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Txt(label, w: 700, size: 14),
                  Txt(sub, size: 12, color: c.ink55),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* --------------------------------------------------------- ProgressBar */

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.pct, this.height = 6});
  final double pct;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.pill),
      child: Container(
        height: height,
        color: c.tint,
        alignment: AlignmentDirectional.centerStart,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: pct.clamp(0, 100) / 100),
          duration: const Duration(milliseconds: 900),
          curve: easeOutExpo,
          builder: (context, v, _) => FractionallySizedBox(
            widthFactor: v,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Brand.green, borderRadius: BorderRadius.circular(Radii.pill)),
            ),
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------- Avatar */

/// [palette]: 'navy' | 'tint' | 'green' | 'lime' | 'open' | 'needed'.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.initial,
    required this.palette,
    this.size = 40,
    this.fontSize = 14,
    this.borderColor,
  });
  final String initial, palette;
  final double size, fontSize;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (Color bg, Color fg, bool dashed) = switch (palette) {
      'navy' => (c.avatarNavy, Brand.lime, false),
      'tint' => (c.tint, Brand.green, false),
      'green' => (Brand.green, Brand.white, false),
      'lime' => (Brand.lime, Brand.navy, false),
      'open' => (c.card, c.ink35, true),
      _ => (c.card, c.ink3, true), // 'needed'
    };
    final circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: !dashed && borderColor != null ? Border.all(color: borderColor!, width: 3) : null,
      ),
      child: Txt(initial, w: 800, size: fontSize, color: fg, center: true),
    );
    return dashed ? CustomPaint(foregroundPainter: _DashedCircle(c.ink25, 2), child: circle) : circle;
  }
}

class _DashedCircle extends CustomPainter {
  _DashedCircle(this.color, this.width);
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final r = (size.width - width) / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final center = size.center(Offset.zero);
    final dash = width * 3; // RN dashed pattern ≈ 3× stroke width
    final n = (2 * math.pi * r / (dash * 2)).floor();
    final sweep = 2 * math.pi / n;
    for (var i = 0; i < n; i++) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: r), i * sweep, sweep / 2, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedCircle old) => old.color != color;
}

/* ---------------------------------------------------------- StatusPill */

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    this.size = 11,
    this.weight = 700,
  });
  final String label;
  final Color bg, fg;
  final double size;
  final int weight;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Radii.pill)),
        child: Txt(label, w: weight, size: size, color: fg),
      );
}

/* ---------------------------------------------------------------- Card */

class EhCard extends StatelessWidget {
  const EhCard({
    super.key,
    required this.child,
    this.radius = Radii.card,
    this.lime = false,
    this.padding,
    this.margin,
  });
  final Widget child;
  final double radius;
  final bool lime;
  final EdgeInsetsGeometry? padding, margin;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: lime ? c.limeBd : c.ink08, width: lime ? 1.5 : 1),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: Shadows.card,
      ),
      child: child,
    );
  }
}

/* -------------------------------------------------------- SectionHeader */

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Layout.screenX),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Txt(title, w: 700, size: 17),
            if (actionLabel != null && onAction != null)
              Press(
                onTap: onAction,
                scale: 1,
                child: Txt('$actionLabel ›', w: 600, size: 13, color: Brand.green),
              ),
          ],
        ),
      );
}

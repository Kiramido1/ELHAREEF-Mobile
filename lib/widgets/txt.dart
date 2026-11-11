// Port of src/components/Txt.tsx.
import 'package:flutter/widgets.dart';

import '../scope.dart';
import '../theme/tokens.dart';

/// Text primitive mapping design font-weights (400–800) onto Archivo, and
/// switching to IBM Plex Sans Arabic when Arabic is active (or [ar] is set).
/// [lineHeight] is absolute px, as in the RN source.
class Txt extends StatelessWidget {
  const Txt(
    this.text, {
    super.key,
    this.w = 400,
    this.size = 14,
    this.color,
    this.ar = false,
    this.lineHeight,
    this.letterSpacing,
    this.center = false,
    this.align,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.italic = false,
  });

  final String text;
  final int w;
  final double size;
  final Color? color;
  final bool ar;
  final double? lineHeight;
  final double? letterSpacing;
  final bool center;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final bool italic;

  static TextStyle style(
    BuildContext context, {
    int w = 400,
    double size = 14,
    Color? color,
    bool ar = false,
    double? lineHeight,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    final arabic = ar || context.i18n.isRTL;
    return TextStyle(
      fontFamily: arabic ? Fonts.arabic : Fonts.archivo,
      fontWeight: arabic ? (w >= 600 ? FontWeight.w600 : FontWeight.w400) : FontWeight.values[w ~/ 100 - 1],
      fontSize: size,
      color: color ?? context.colors.ink,
      height: lineHeight == null ? null : lineHeight / size,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: color ?? context.colors.ink,
    );
  }

  @override
  Widget build(BuildContext context) => Text(
        text,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: align ?? (center ? TextAlign.center : TextAlign.start),
        style: style(
          context,
          w: w,
          size: size,
          color: color,
          ar: ar,
          lineHeight: lineHeight,
          letterSpacing: letterSpacing,
          decoration: decoration,
        ).copyWith(fontStyle: italic ? FontStyle.italic : null),
      );
}

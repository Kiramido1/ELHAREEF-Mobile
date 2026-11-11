// Port of src/components/icons/index.tsx — same viewBoxes, paths, strokes.
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

class _Icon extends StatelessWidget {
  const _Icon(this.size, this.color, this.body, {this.slashColor});
  final double size;
  final Color color;
  final Color? slashColor;
  final String Function(String c, String o, String s, String so) body;

  @override
  Widget build(BuildContext context) {
    final s = slashColor ?? color;
    final svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none">'
        '${body(_hex(color), '${color.a}', _hex(s), '${s.a}')}</svg>';
    return SvgPicture.string(svg, width: size, height: size);
  }
}

// Attribute helpers: stroke with color + opacity, round caps.
String _st(String c, String o, num w, {bool join = false}) =>
    'stroke="$c" stroke-opacity="$o" stroke-width="$w" stroke-linecap="round"${join ? ' stroke-linejoin="round"' : ''}';
String _sq(String c, String o, num w) => 'stroke="$c" stroke-opacity="$o" stroke-width="$w"';

class SearchIcon extends StatelessWidget {
  const SearchIcon({super.key, this.size = 18, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => _Icon(size, color, (c, o, _, _) =>
      '<circle cx="11" cy="11" r="7" ${_st(c, o, 2)}/><path d="M16.5 16.5 21 21" ${_st(c, o, 2)}/>');
}

class FilterIcon extends StatelessWidget {
  const FilterIcon({super.key, this.size = 17, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      _Icon(size, color, (c, o, _, _) => '<path d="M4 6h16M7 12h10M10 18h4" ${_st(c, o, 2)}/>');
}

class HomeIcon extends StatelessWidget {
  const HomeIcon({super.key, this.size = 22, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => _Icon(size, color, (c, o, _, _) =>
      '<path d="M3 10.5 12 3l9 7.5" ${_st(c, o, 2, join: true)}/><path d="M5.5 9.5V21h13V9.5" ${_st(c, o, 2, join: true)}/>');
}

class CalendarIcon extends StatelessWidget {
  const CalendarIcon({super.key, this.size = 22, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => _Icon(size, color, (c, o, _, _) =>
      '<rect x="3" y="5" width="18" height="17" rx="3" ${_sq(c, o, 2)}/><path d="M3 10h18M8 3v4M16 3v4" ${_st(c, o, 2)}/>');
}

class PlayersIcon extends StatelessWidget {
  const PlayersIcon({super.key, this.size = 22, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => _Icon(size, color, (c, o, _, _) =>
      '<circle cx="9" cy="8" r="3.5" ${_sq(c, o, 2)}/><path d="M3 20c0-3.3 2.7-6 6-6s6 2.7 6 6" ${_st(c, o, 2)}/>'
      '<circle cx="17" cy="9" r="2.5" ${_sq(c, o, 2)}/><path d="M16 14.6c2.5.4 4.5 2.6 4.5 5.4" ${_st(c, o, 2)}/>');
}

class ProfileIcon extends StatelessWidget {
  const ProfileIcon({super.key, this.size = 22, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => _Icon(size, color, (c, o, _, _) =>
      '<circle cx="12" cy="8" r="4" ${_sq(c, o, 2)}/><path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8" ${_st(c, o, 2)}/>');
}

class SendIcon extends StatelessWidget {
  const SendIcon({super.key, this.size = 19, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      _Icon(size, color, (c, o, _, _) => '<path d="M4 12h14M13 6l6 6-6 6" ${_st(c, o, 2.2, join: true)}/>');
}

class CheckIcon extends StatelessWidget {
  const CheckIcon({super.key, this.size = 44, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      _Icon(size, color, (c, o, _, _) => '<path d="M4.5 12.5 10 18 19.5 7" ${_st(c, o, 3, join: true)}/>');
}

class CrossIcon extends StatelessWidget {
  const CrossIcon({super.key, this.size = 38, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      _Icon(size, color, (c, o, _, _) => '<path d="M6 6l12 12M18 6 6 18" ${_st(c, o, 3)}/>');
}

class EyeIcon extends StatelessWidget {
  const EyeIcon({super.key, this.size = 19, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => _Icon(size, color, (c, o, _, _) =>
      '<path d="M2.5 12c2.2-4.6 5.9-7 9.5-7s7.3 2.4 9.5 7c-2.2 4.6-5.9 7-9.5 7s-7.3-2.4-9.5-7Z" ${_st(c, o, 2, join: true)}/>'
      '<circle cx="12" cy="12" r="3" ${_sq(c, o, 2)}/>');
}

class EyeOffIcon extends StatelessWidget {
  const EyeOffIcon({super.key, this.size = 19, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => _Icon(size, color, (c, o, _, _) =>
      '<path d="M4.5 8.6C3.7 9.5 3 10.7 2.5 12c2.2 4.6 5.9 7 9.5 7 1.6 0 3.2-.5 4.7-1.4M9.5 5.4C10.3 5.1 11.1 5 12 5c3.6 0 7.3 2.4 9.5 7-.5 1.1-1.1 2.1-1.8 2.9" ${_st(c, o, 2, join: true)}/>'
      '<path d="M4 4l16 16" ${_st(c, o, 2)}/>');
}

class WifiOffIcon extends StatelessWidget {
  const WifiOffIcon({super.key, this.size = 40, required this.color, required this.slashColor});
  final double size;
  final Color color, slashColor;
  @override
  Widget build(BuildContext context) => _Icon(size, color, slashColor: slashColor, (c, o, s, so) =>
      '<path d="M2 9c5.5-5 14.5-5 20 0M5.5 12.5c3.6-3.2 9.4-3.2 13 0M9 16c1.7-1.5 4.3-1.5 6 0" ${_st(c, o, 2)}/>'
      '<circle cx="12" cy="19" r="1.3" fill="$c" fill-opacity="$o"/><path d="M4 4l16 16" ${_st(s, so, 2.4)}/>');
}

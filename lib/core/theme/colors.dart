// ELHAREEF design tokens — ported verbatim from src/theme/colors.ts.
import 'package:flutter/painting.dart';

class Brand {
  static const navy = Color(0xFF061533);
  static const green = Color(0xFF24A551);
  static const greenHover = Color(0xFF1E8F46);
  static const lime = Color(0xFFBDF961);
  static const tint = Color(0xFFF0F9E4);
  static const cloud = Color(0xFFFBFCFA);
  static const danger = Color(0xFFD64545);
  static const dangerBg = Color.fromRGBO(214, 69, 69, .1);
  static const dangerBd = Color.fromRGBO(214, 69, 69, .35);
  static const phoneShell = Color(0xFF0A0D16);
  static const white = Color(0xFFFFFFFF);
}

class ThemeColors {
  const ThemeColors({
    required this.bg,
    required this.card,
    required this.tint,
    required this.bar,
    required this.ink,
    required this.navyBtn,
    required this.chipOn,
    required this.chipOnFg,
    required this.segOn,
    required this.disabled,
    required this.chipGray,
    required this.shim2,
    required this.avatarNavy,
    required this.limeBd,
    required this.limeChip,
    required this.limeChipFg,
    required this.limeTint,
    required this.ink06,
    required this.ink08,
    required this.ink1,
    required this.ink12,
    required this.ink14,
    required this.ink15,
    required this.ink25,
    required this.ink3,
    required this.ink35,
    required this.ink4,
    required this.ink45,
    required this.ink5,
    required this.ink55,
    required this.ink6,
    required this.ink65,
    required this.ink7,
    required this.ink75,
  });

  final Color bg, card, tint, bar, ink, navyBtn, chipOn, chipOnFg, segOn;
  final Color disabled, chipGray, shim2, avatarNavy, limeBd, limeChip;
  final Color limeChipFg, limeTint;
  final Color ink06, ink08, ink1, ink12, ink14, ink15, ink25, ink3, ink35;
  final Color ink4, ink45, ink5, ink55, ink6, ink65, ink7, ink75;
}

Color _ink(double a) => Color.fromRGBO(6, 21, 51, a);
Color _inkD(double a) => Color.fromRGBO(226, 233, 246, a);

final lightColors = ThemeColors(
  bg: const Color(0xFFFBFCFA),
  card: const Color(0xFFFFFFFF),
  tint: const Color(0xFFF0F9E4),
  bar: const Color.fromRGBO(251, 252, 250, .95),
  ink: const Color(0xFF061533),
  navyBtn: const Color(0xFF061533),
  chipOn: const Color(0xFF061533),
  chipOnFg: const Color(0xFFFFFFFF),
  segOn: const Color(0xFFFFFFFF),
  disabled: const Color(0xFFE4E9E2),
  chipGray: const Color(0xFFEEF1F5),
  shim2: const Color(0xFFE2EED2),
  avatarNavy: const Color(0xFF061533),
  limeBd: const Color(0xFFBDF961),
  limeChip: const Color(0xFFBDF961),
  limeChipFg: const Color(0xFF061533),
  limeTint: const Color.fromRGBO(189, 249, 97, .21),
  ink06: _ink(.06),
  ink08: _ink(.08),
  ink1: _ink(.1),
  ink12: _ink(.12),
  ink14: _ink(.14),
  ink15: _ink(.15),
  ink25: _ink(.25),
  ink3: _ink(.3),
  ink35: _ink(.35),
  ink4: _ink(.4),
  ink45: _ink(.45),
  ink5: _ink(.5),
  ink55: _ink(.55),
  ink6: _ink(.6),
  ink65: _ink(.65),
  ink7: _ink(.7),
  ink75: _ink(.75),
);

final darkColors = ThemeColors(
  bg: const Color(0xFF0C1220),
  card: const Color(0xFF131A2C),
  tint: const Color(0xFF1A2338),
  bar: const Color.fromRGBO(12, 18, 32, .93),
  ink: const Color(0xFFE6ECF7),
  navyBtn: const Color(0xFF243356),
  chipOn: const Color(0xFFDFE7F4),
  chipOnFg: const Color(0xFF0F172A),
  segOn: const Color(0xFF253251),
  disabled: const Color(0xFF1D2740),
  chipGray: const Color(0xFF1A2338),
  shim2: const Color(0xFF222F4E),
  avatarNavy: const Color(0xFF2B3A61),
  limeBd: const Color.fromRGBO(189, 249, 97, .35),
  limeChip: const Color.fromRGBO(189, 249, 97, .14),
  limeChipFg: const Color(0xFFBDF961),
  limeTint: const Color.fromRGBO(189, 249, 97, .07),
  ink06: _inkD(.07),
  ink08: _inkD(.09),
  ink1: _inkD(.11),
  ink12: _inkD(.13),
  ink14: _inkD(.15),
  ink15: _inkD(.17),
  ink25: _inkD(.28),
  ink3: _inkD(.33),
  ink35: _inkD(.38),
  ink4: _inkD(.44),
  ink45: _inkD(.5),
  ink5: _inkD(.55),
  ink55: _inkD(.6),
  ink6: _inkD(.66),
  ink65: _inkD(.7),
  ink7: _inkD(.74),
  ink75: _inkD(.78),
);

/// Pitch-card gradient pairs, in design order.
const pitchGradients = [
  [Color(0xFF2FAE5C), Color(0xFF187A3D)],
  [Color(0xFF3CB96A), Color(0xFF1D8746)],
  [Color(0xFF28A155), Color(0xFF0F6C33)],
  [Color(0xFF45C076), Color(0xFF24A551)],
];

/// Onboarding hero gradients, per slide.
const onboardingGradients = [
  [Color(0xFF24A551), Color(0xFF0F6C33)],
  [Color(0xFF061533), Color(0xFF0D2A5E)],
  [Color(0xFF187A3D), Color(0xFF061533)],
];

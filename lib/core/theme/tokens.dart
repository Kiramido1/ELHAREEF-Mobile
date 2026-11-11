// Layout, radius, shadow and type-scale tokens — from src/theme/spacing.ts
// and src/theme/typography.ts.
import 'package:flutter/painting.dart';

class Layout {
  static const double screenX = 20;
  static const double screenXWide = 24;
  static const double headerTop = 10;
  static const double tabBarClearance = 110;
  static const double backButton = 38;
}

class Radii {
  static const double xs = 6, sm = 8, chip9 = 9, md = 10, action = 11;
  static const double input12 = 12, input = 13, card14 = 14, card15 = 15;
  static const double box = 16, card17 = 17, card = 18, hero = 20;
  static const double onboarding = 24, sheet = 26, pill = 999;
}

BoxShadow _shadow(Color c, double opacity, double blur, double dy) =>
    BoxShadow(color: c.withValues(alpha: opacity), blurRadius: blur, offset: Offset(0, dy));

class Shadows {
  static final card = [_shadow(const Color(0xFF061533), .05, 3, 1)];
  static final confirmPop = [_shadow(const Color(0xFF24A551), .4, 34, 14)];
  static final confirmCta = [_shadow(const Color(0xFF24A551), .35, 24, 10)];
  static final timeSelected = [_shadow(const Color(0xFF061533), .28, 22, 8)];
}

class FontSize {
  static const double micro = 10.5, tiny = 11, caption = 11.5, small = 12;
  static const double smallPlus = 12.5, body = 13, bodyPlus = 13.5, base = 14;
  static const double basePlus = 14.5, medium = 15, mediumPlus = 15.5;
  static const double subtitle = 16, subtitlePlus = 16.5, sectionTitle = 17;
  static const double headerTitle = 18, price = 19, statValue = 20;
  static const double greeting = 21, pitchName = 22, pageTitle = 23;
  static const double stateTitle = 24, confirmTitle = 25, obTitle = 27;
  static const double authTitle = 28;
}

class Fonts {
  static const archivo = 'Archivo';
  static const arabic = 'IBMPlexSansArabic';
}

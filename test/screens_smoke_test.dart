// Opens every route at a 412×915 phone size, in English/light and
// Arabic/dark, with the real fonts loaded — any overflow or exception fails.
import 'dart:io';

import 'package:elhareef/i18n/i18n.dart';
import 'package:elhareef/main.dart';
import 'package:elhareef/navigation/nav.dart';
import 'package:elhareef/scope.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const routes = <(String, Object?)>[
  ('Onboarding', null), ('Login', null), ('Signup', null), ('ForgotPassword', null),
  ('Tabs', null), ('Search', null), ('Search', true), ('Pitch', 0), ('Pitch', 3),
  ('Booking', null), ('Summary', null), ('Confirmed', null), ('FindPlayers', null),
  ('CreateMatch', null), ('MatchDetails', 0), ('MatchDetails', 2), ('MatchFull', 2),
  ('PlayerProfile', 0), ('Chat', null), ('BookingDetails', null), ('Notifications', null),
  ('Settings', null), ('PaymentFailed', null), ('Offline', null),
];

Future<void> _loadFonts() async {
  for (final (family, files) in [
    ('Archivo', ['400Regular', '500Medium', '600SemiBold', '700Bold', '800ExtraBold']),
    ('IBMPlexSansArabic', ['400Regular', '600SemiBold']),
  ]) {
    final loader = FontLoader(family);
    for (final f in files) {
      final bytes = File('assets/fonts/${family}_$f.ttf').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
}

void main() {
  setUpAll(_loadFonts);

  for (final arabicDark in [false, true]) {
    testWidgets('all screens render (${arabicDark ? 'ar/dark' : 'en/light'})', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const AppScopes(child: ElhareefApp()));
      final ctx = tester.element(find.byType(ElhareefApp));
      if (arabicDark) {
        ctx.read<I18n>().setLang('ar');
        ctx.read<ThemeController>().toggleDark();
      }
      await tester.pump(const Duration(seconds: 3)); // splash → onboarding

      for (final (name, args) in routes) {
        navKey.currentState!.pushNamed(name, arguments: args);
        for (var i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 250));
        }
        expect(tester.takeException(), isNull, reason: '$name($args)');
        if (name == 'Tabs') {
          for (var t = 1; t < tabNames.length; t++) {
            tabIndex.value = t;
            for (var i = 0; i < 6; i++) {
              await tester.pump(const Duration(milliseconds: 250));
            }
            expect(tester.takeException(), isNull, reason: 'tab ${tabNames[t]}');
          }
          tabIndex.value = 0;
        }
      }
      // Let pending mock-network timers finish before teardown.
      await tester.pump(const Duration(seconds: 5));
    });
  }
}

// Port of src/screens/OfflineScreen.tsx.
import 'package:flutter/material.dart';

import '../navigation/nav.dart';
import '../scope.dart';
import '../services/network.dart';
import '../theme/colors.dart';
import '../widgets/icons.dart';
import '../widgets/txt.dart';
import '../widgets/ui.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  void _retry() {
    setOffline(false);
    Nav.back();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = context.watch<ThemeController>().dark;
    final i18n = context.i18n;
    final retryLabel = i18n.t('retry');

    return Screen(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: c.tint, shape: BoxShape.circle),
              child: WifiOffIcon(size: 40, color: dark ? c.ink : Brand.navy, slashColor: Brand.danger),
            ),
            const SizedBox(height: 20),
            Txt(i18n.t('offline'), w: 800, size: 19, center: true),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: Txt(i18n.t('offlineSub'), size: 13.5, lineHeight: 21, color: c.ink55, center: true),
            ),
            const SizedBox(height: 20),
            // RN <Button> with style overrides (paddingHorizontal 30, borderRadius 13),
            // sized to its content inside the centered column.
            Press(
              onTap: _retry,
              label: retryLabel,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                decoration: BoxDecoration(color: Brand.green, borderRadius: BorderRadius.circular(13)),
                child: Txt(retryLabel, w: 700, size: 14.5, color: Brand.white, center: true),
              ),
            ),
            const SizedBox(height: 10),
            Semantics(
              button: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Nav.navigate('Tabs', 'Bookings'),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Txt(i18n.t('savedBk'), w: 600, size: 13.5, color: Brand.green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

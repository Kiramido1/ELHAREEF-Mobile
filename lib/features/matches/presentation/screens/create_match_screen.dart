// Port of src/screens/CreateMatchScreen.tsx.
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:elhareef/core/i18n/i18n.dart';
import 'package:elhareef/core/navigation/nav.dart';
import 'package:elhareef/core/di/scope.dart';
import 'package:elhareef/core/widgets/toast.dart';
import 'package:elhareef/features/auth/presentation/controllers/session_controller.dart';
import 'package:elhareef/features/booking/domain/entities/booking.dart';
import 'package:elhareef/features/booking/presentation/controllers/bookings_controller.dart';
import 'package:elhareef/features/pitches/presentation/controllers/pitches_controller.dart';
import 'package:elhareef/features/matches/presentation/controllers/matches_controller.dart';
import 'package:elhareef/core/theme/colors.dart';
import 'package:elhareef/core/theme/tokens.dart';
import 'package:elhareef/core/widgets/anim.dart';
import 'package:elhareef/core/widgets/input.dart';
import 'package:elhareef/core/widgets/txt.dart';
import 'package:elhareef/core/widgets/ui.dart';

const _levels = ['Beginner', 'Intermediate', 'Advanced', 'Any level'];

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key, this.bookingId});
  final String? bookingId;

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  late final TextEditingController _desc;

  @override
  void initState() {
    super.initState();
    _desc = TextEditingController(text: context.read<MatchesController>().draft.description);
  }

  @override
  void dispose() {
    _desc.dispose();
    super.dispose();
  }

  Future<void> _post(Booking booking) async {
    final pitch = context.read<PitchesController>().byId(booking.pitchId);
    final t = context.read<I18n>().t;
    final squadSize = int.tryParse(pitch.type.split('-').first) ?? 10;
    final posted = await context.read<MatchesController>().host(
      pitchId: pitch.id,
      pitch: pitch.name,
      area: pitch.area,
      kickoff: booking.start,
      durHours: booking.hours,
      squadSize: squadSize,
      hostName: context.read<SessionController>().session?.name ?? 'Youssef Adel',
    );
    if (!mounted) return;
    if (posted == null) {
      showToast(t('postFailed'), error: true);
      return;
    }
    _desc.clear();
    Nav.navigate('Tabs', 'Discover');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final i18n = context.i18n;
    final t = i18n.t;
    final fmt = i18n.fmt;
    final bookings = context.watch<BookingsController>();
    final booking = bookings.byId(widget.bookingId) ?? bookings.nextUpcoming;
    if (booking == null) {
      return Screen(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Txt(t('bookFirst'), size: 14, color: c.ink6, center: true),
                const SizedBox(height: 16),
                Button(label: t('bookPitchBtn'), onPressed: () => Nav.navigate('Search')),
              ],
            ),
          ),
        ),
      );
    }
    final matches = context.watch<MatchesController>();
    final draft = matches.draft;

    final squadSize = int.tryParse(context.watch<PitchesController>().byId(booking.pitchId).type.split('-').first) ?? 10;
    final needOptions = [for (final n in [1, 2, 3, 4, 5]) if (n < squadSize) n];
    final needStr = i18n.lang == 'ar'
        ? (draft.need == 1 ? 'لاعيب واحد' : '${draft.need} لاعيبة')
        : '${draft.need} player${draft.need == 1 ? '' : 's'}';

    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Txt(text, w: 700, size: 13, color: c.ink65),
        );

    Widget needBox(int n, bool on) => Container(
          padding: on ? null : const EdgeInsets.symmetric(vertical: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? Brand.green : c.card,
            borderRadius: BorderRadius.circular(Radii.input12),
            border: Border.all(color: on ? Brand.green : c.ink12, width: 1.5),
          ),
          child: Txt('$n', w: 800, size: 15, color: on ? Brand.white : null, center: true),
        );

    return Screen(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: LayoutBuilder(
          builder: (context, viewport) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: math.max(0, viewport.maxHeight - 40)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          EhBackButton(onPressed: Nav.back),
                          const SizedBox(width: 12),
                          Txt(t('createMatch'), w: 800, size: 18),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
                        decoration: BoxDecoration(
                          color: c.tint,
                          border: Border.all(color: c.ink08),
                          borderRadius: BorderRadius.circular(Radii.card14),
                        ),
                        child: Text.rich(
                          TextSpan(
                            style: Txt.style(context, size: 13, lineHeight: 19.5),
                            children: [
                              TextSpan(text: booking.pitchName, style: Txt.style(context, w: 700, size: 13)),
                              TextSpan(text: ' · ${fmt.dateLong(booking.start)} · ${fmt.hourRange(booking.startHour, booking.hours)}'),
                            ],
                          ),
                        ),
                      ),

                      label(t('playersNeeded')),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          for (final n in needOptions) ...[
                            if (n > 1) const SizedBox(width: 8),
                            Expanded(
                              child: Press(
                                onTap: () => matches.setDraft(need: n),
                                scale: 1,
                                selected: draft.need == n,
                                child: SelectFade(
                                  on: draft.need == n,
                                  off: needBox(n, false),
                                  over: needBox(n, true),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      label(t('skill')),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final level in _levels)
                            EhChip(
                              label: i18n.pick(level, levelAr[level] ?? level),
                              selected: draft.level == level,
                              onPressed: () => matches.setDraft(level: level),
                              paddingV: 10,
                              paddingH: 16,
                              size: 13.5,
                            ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text.rich(
                          TextSpan(
                            style: Txt.style(context, w: 700, size: 13, color: c.ink65),
                            children: [
                              TextSpan(text: '${t('desc')} '),
                              TextSpan(text: t('optional'), style: Txt.style(context, w: 500, size: 13, color: c.ink4)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      // RN: fixed 76px multiline box (13px vertical padding),
                      // so three 50/3px lines fill it exactly.
                      Semantics(
                        label: t('desc'),
                        child: Input(
                          controller: _desc,
                          placeholder: t('descPh'),
                          onChanged: (v) => matches.setDraft(description: v),
                          maxLines: 3,
                          minLines: 3,
                          maxLength: 280,
                          keyboardType: TextInputType.multiline,
                          fontSize: 14,
                          style: const TextStyle(height: 50 / 3 / 14),
                          contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
                        ),
                      ),

                      label(t('whoJoin')),
                      const SizedBox(height: 9),
                      Segmented(
                        options: [i18n.pick('Public', 'عام'), i18n.pick('Friends only', 'الأصحاب بس')],
                        selectedIndex: draft.privacy == 'public' ? 0 : 1,
                        onSelect: (i) => matches.setDraft(privacy: i == 0 ? 'public' : 'friends'),
                        paddingV: 11,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 28),
                    child: Button(label: '${t('postMatch')} $needStr', onPressed: matches.posting ? null : () => _post(booking)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

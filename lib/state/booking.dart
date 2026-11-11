// Port of src/state/BookingContext.tsx.
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../i18n/i18n.dart';
import '../services/pitches.dart';
import '../types.dart';

/// Booking months exposed to the calendar (Aug/Sep 2026, as designed).
/// `monthIndex` is 0-based like JS.
const bookingMonths = [
  (nameEn: 'August 2026', nameAr: 'أغسطس 2026', monthIndex: 7, length: 31),
  (nameEn: 'September 2026', nameAr: 'سبتمبر 2026', monthIndex: 8, length: 30),
];

/// Bookable start hours and the busy ones (line-through in the design).
const slotHours = [16, 17, 18, 19, 20, 21, 22];
const busyHours = [17, 19];
const durations = [1, 2, 3, 4];

const _weekdaysEn = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
const _weekdaysAr = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
const _monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _monthsAr = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
const weekdayShortEn = ['Sa', 'Su', 'Mo', 'Tu', 'We', 'Th', 'Fr'];
const weekdayShortAr = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];

class BookingController extends ChangeNotifier {
  int selPitchId = 0;
  int calMonth = 0; // 0 | 1
  int selMonth = 0; // 0 | 1
  int selDay = 21;
  int? selTime;
  int selDur = 2; // 1..4
  bool recur = false;
  String payMode = 'full'; // 'full' | 'deposit'
  String payMethod = 'card'; // 'card' | 'wallet'

  void _set(void Function() f) {
    f();
    notifyListeners();
  }

  void selectPitch(int id) => _set(() => selPitchId = id);
  void setCalMonth(int m) => _set(() => calMonth = m);
  void selectDay(int month, int day) => _set(() {
        selMonth = month;
        selDay = day;
      });
  void selectTime(int hour) => _set(() => selTime = hour);
  void selectDur(int hours) => _set(() => selDur = hours);
  void toggleRecur() => _set(() {
        payMode = !recur ? 'deposit' : 'full';
        recur = !recur;
      });
  void setPayMode(String mode) => _set(() => payMode = mode);
  void setPayMethod(String method) => _set(() => payMethod = method);
  void resetSelections() => _set(() {
        selPitchId = 0;
        calMonth = 0;
        selMonth = 0;
        selDay = 21;
        selTime = null;
        selDur = 2;
        recur = false;
        payMode = 'full';
        payMethod = 'card';
      });

  /// All derived booking values (price math identical to the design script).
  BookingDerived derive(I18n i18n) => BookingDerived._(this, i18n);
}

class BookingDerived {
  BookingDerived._(BookingController b, I18n i18n)
      : pitch = getPitch(b.selPitchId),
        _b = b,
        _i18n = i18n {
    final monthDef = bookingMonths[b.selMonth];
    final t0 = b.selTime ?? 20;
    sessions = b.recur ? 4 : 1;
    price = b.selDur * pitch.price * sessions;
    fee = bookingFee;
    total = price + fee;
    deposit = math.max(50, ((total * 0.25) / 5).round() * 5);
    remaining = total - deposit;
    dueNow = b.payMode == 'deposit' ? deposit : total;
    dateStr = _fdate(DateTime(2026, monthDef.monthIndex + 1, b.selDay));
    rangeStr = '${fmtHour(t0)} – ${fmtHour(t0 + b.selDur)}';
    startStr = fmtHour(t0);
    timePicked = b.selTime != null;
    recurDates = [for (var k = 0; k < 4; k++) shortDate(k)];
    final en = !i18n.isRTL;
    durStr = en
        ? '${b.selDur} ${b.selDur == 1 ? 'hour' : 'hours'}'
        : b.selDur == 1
            ? 'ساعة'
            : b.selDur == 2
                ? 'ساعتين'
                : '${b.selDur} ساعات';
  }

  final BookingController _b;
  final I18n _i18n;
  final Pitch pitch;
  late final String dateStr, rangeStr, durStr, startStr;
  late final bool timePicked;
  late final int sessions, price, fee, total, deposit, remaining, dueNow;
  late final List<String> recurDates;

  bool get _en => !_i18n.isRTL;

  /// 12-hour clock formatter, localized AM/PM.
  String fmtHour(int h) => '${((h + 11) % 12) + 1}:00 ${h % 24 >= 12 ? _i18n.t('pm') : _i18n.t('am')}';

  String _fdate(DateTime dt) {
    final wd = (_en ? _weekdaysEn : _weekdaysAr)[dt.weekday % 7];
    final mo = (_en ? _monthsEn : _monthsAr)[dt.month - 1];
    return _en ? '$wd, $mo ${dt.day}' : '$wd، ${dt.day} $mo';
  }

  String _fshort(DateTime dt) {
    final mo = (_en ? _monthsEn : _monthsAr)[dt.month - 1];
    return _en ? '$mo ${dt.day}' : '${dt.day} $mo';
  }

  String shortDate(int offsetWeeks) =>
      _fshort(DateTime(2026, bookingMonths[_b.selMonth].monthIndex + 1, _b.selDay + 7 * offsetWeeks));
}

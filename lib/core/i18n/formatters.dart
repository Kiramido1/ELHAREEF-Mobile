// Locale-aware formatting for dates, hours and counts (EN / Egyptian AR).
// Pure Dart, so it is unit-testable without widgets.

class Formatters {
  const Formatters({required this.arabic});
  final bool arabic;

  static const _weekdaysEn = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const _weekdaysAr = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
  static const _monthsShortEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _monthsEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const _monthsAr = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  /// Calendar header initials, week starting Saturday (Egyptian convention).
  List<String> get weekdayInitials =>
      arabic ? const ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'] : const ['Sa', 'Su', 'Mo', 'Tu', 'We', 'Th', 'Fr'];

  String weekday(DateTime d) => (arabic ? _weekdaysAr : _weekdaysEn)[d.weekday - 1];

  /// "Friday, Aug 21" / "الجمعة، 21 أغسطس".
  String dateLong(DateTime d) =>
      arabic ? '${weekday(d)}، ${d.day} ${_monthsAr[d.month - 1]}' : '${weekday(d)}, ${_monthsShortEn[d.month - 1]} ${d.day}';

  /// "Aug 21" / "21 أغسطس".
  String dateShort(DateTime d) => arabic ? '${d.day} ${_monthsAr[d.month - 1]}' : '${_monthsShortEn[d.month - 1]} ${d.day}';

  /// "August 2026" / "أغسطس 2026".
  String monthYear(DateTime d) => '${(arabic ? _monthsAr : _monthsEn)[d.month - 1]} ${d.year}';

  /// 12-hour clock for a whole hour; 24 is midnight.
  String hour(int h) => '${((h + 11) % 12) + 1}:00 ${h % 24 >= 12 ? (arabic ? 'م' : 'PM') : (arabic ? 'ص' : 'AM')}';

  /// "4:00 PM – 6:00 PM".
  String hourRange(int start, int hours) => '${hour(start)} – ${hour(start + hours)}';

  /// "1 hour" · "2 hours" / "ساعة" · "ساعتين" · "3 ساعات".
  String hours(int n) {
    if (!arabic) return '$n ${n == 1 ? 'hour' : 'hours'}';
    if (n == 1) return 'ساعة';
    if (n == 2) return 'ساعتين';
    return n <= 10 ? '$n ساعات' : '$n ساعة';
  }

  /// "1 pitch" · "4 pitches" / "ملعب واحد" · "ملعبين" · "3 ملاعب".
  String pitches(int n) {
    if (!arabic) return '$n ${n == 1 ? 'pitch' : 'pitches'}';
    if (n == 1) return 'ملعب واحد';
    if (n == 2) return 'ملعبين';
    return n <= 10 ? '$n ملاعب' : '$n ملعب';
  }

  /// Greeting for the hour of day.
  String greeting(DateTime now, String name) {
    final h = now.hour;
    if (arabic) return h < 12 ? 'صباح الخير يا $name' : 'مساء الخير يا $name';
    final part = h < 12 ? 'Morning' : (h < 17 ? 'Afternoon' : 'Evening');
    return '$part, $name';
  }

  /// "9:47" countdown.
  String countdown(Duration d) {
    final s = d.isNegative ? 0 : d.inSeconds;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }
}
